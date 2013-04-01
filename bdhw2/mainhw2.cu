#include <string>
#include <vector>

#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/random.h>
#include <thrust/transform.h>
#include <thrust/reduce.h>
#include <thrust/host_vector.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/random/normal_distribution.h>
#include <thrust/device_malloc.h>

#include "parameters.h"
#include "setup.h"
#include "xlog.h"

using namespace std;

const XParams param("paramhw2.txt");

paramStruct initParameters(){
	paramStruct tempPar;
	tempPar.NUM_SIMULATIONS= param.getLong("NUM_SIMULATIONS",10000);
	tempPar.NUM_TIMESTEPS= param.getLong("NUM_TIMESTEPS",1000);
	return tempPar;
}

//holds the normalized simulation results for each type of counterparty
struct counterpartyCVA
{
	float normalizedCVA[5];
	//intialize counterparties and set to 0
	__host__ __device__
	counterpartyCVA()
	{
		for (int i=0;i<5;i++){normalizedCVA[i]=0;}
	}
};

//operator to be called in thrust binary operation
__host__ __device__
counterpartyCVA operator+(const counterpartyCVA &cvaL, const counterpartyCVA &cvaR)
{
	counterpartyCVA tempCVA;
	for(int i=0;i<5;i++)
	{
		tempCVA.normalizedCVA[i]=cvaL.normalizedCVA[i]+cvaR.normalizedCVA[i];
	}
	return tempCVA;
}

struct get_CVA : public thrust::unary_function<unsigned int,counterpartyCVA>
{
	thrust::device_ptr<paramStruct> raw_par;
	get_CVA(thrust::device_ptr<paramStruct> _raw_par):raw_par(_raw_par){}

	__host__ __device__
	counterpartyCVA operator()(unsigned int seed)
	{
		paramStruct * par = thrust::raw_pointer_cast(raw_par);
//		paramStruct * raw_ptr = thrust::raw_pointer_cast(pardi);

		//initialize output counterparty results
		counterpartyCVA sumCVA;

		// seed a random number generator
		thrust::default_random_engine rng(seed);

		// create a mapping from random numbers to [0,1)
		//thrust::uniform_real_distribution<float> u01(0,1);
		thrust::random::experimental::normal_distribution<float> ndist(0, 1.0f);

		//initialize parameters for simulation
		float timeStep=YEARS/float(NUM_TIMESTEPS);
		float time=0;
		float defProb=0;
		double price=STARTING_PRICE;
		float discount=1;

		//factor used in random evolution of price
		float priceFactor=sqrt(VARIANCE)*(YEARS/float(NUM_TIMESTEPS));

		//to hold the random normal generated each step

		float normal=0;

		//initialize hazard rate factors (TO BE PARAMETRIZED?
		float hazard[5];
		for (int i=0;i<5;i++)
		{
			hazard[i]=BASE_HAZARD+BASE_HAZARD*float(i);
		}

		//run the required number of steps
		//NOTE: TO BE OPTIMIZED
		for(unsigned int i = 0; i < NUM_TIMESTEPS-1; ++i)
		{
			time=time+timeStep;
			//get new price
			normal=ndist(rng);
			price+=price*normal*priceFactor;
			//get discount for current step
			discount=1.0/exp(DISCOUNT*time);
			//find default probability for each and copy result to output CVA struct
			for (int j=0;j<5;j++)
			{
				defProb=1.0f/exp((time-timeStep)*hazard[j])-1.0f/exp(time*hazard[j]);
//				cout<<j<<" defprob: "<<defProb<<" discount: "<<discount<<" price: "<<price<<endl;
				sumCVA.normalizedCVA[j]+=defProb*discount*price;
//				cout<<i<<" type: "<<j<<" CVA norm: "<<(defProb*discount*price)<<endl;
			}
		}
		return sumCVA;
	}
};

counterpartyCVA genPaths()
{
	paramStruct parh;
	parh=initParameters();

	thrust::device_ptr<paramStruct> dev_ptr = thrust::device_malloc<paramStruct>(1);
	dev_ptr[0]=parh;
//	paramStruct * par_ptr;
//	cudaMalloc((void **) &par_ptr,sizeof(parh));
//	cudaMemcpy(par_ptr,&parh,sizeof(parh), cudaMemcpyHostToDevice);
//	thrust::device_ptr<paramStruct> dev_ptr(par_ptr);

	thrust::plus<counterpartyCVA> binary_op;
	counterpartyCVA cpCVA;
	cpCVA = thrust::transform_reduce(thrust::counting_iterator<int>(0),
			thrust::counting_iterator<int>(NUM_SIMULATIONS),get_CVA(dev_ptr),cpCVA,binary_op);
	for (int i=0;i<5;i++)
	{cpCVA.normalizedCVA[i]=cpCVA.normalizedCVA[i]/float(NUM_SIMULATIONS);}
	return cpCVA;
}

float getCumulativeCVA(counterpartyCVA& cpCVA,vector<counterParties>& cp)
{
	float sumCVA=0;
	int partiesFifth = PARTIES_NUM / 5;
	for (int j = 0; j < 5; j++) {
		int startCount = partiesFifth * j;
		for (long i = 0; i < partiesFifth; i++) {
			sumCVA+=cpCVA.normalizedCVA[j]*cp[startCount + i].netDeal;
		}
	}
	return sumCVA;
}

int main(){
	XLog logMain("CVA Main");
	logMain.start();


//	paramStruct* pard;
//	cudaMalloc((void**)&pard,sizeof(parh));
//	cudaMemcpy(pard,&parh,sizeof(parh),cudaMemcpyHostToDevice);
//	thrust::device_ptr<paramStruct> dev_ptr2(pard);
//	dev_ptr=dev_ptr2;

//	thrust::device_ptr<paramStruct> dev_ptr = thrust::device_malloc<paramStruct>(1);
//    paramStruct* pard=thrust::raw_pointer_cast(dev_ptr);

//	cout<<"NUM_TIMESTEPS: "<<parh.NUM_TIMESTEPS<<endl;
	vector<counterParties> cp(PARTIES_NUM);
	{
		XLog logAlloc("Setup");
		setupCounterparties(cp);
		logAlloc.log("Counterparties Setup");
		allocateDeals(cp);
		logAlloc.log("Deal allocation complete");
	}

	counterpartyCVA cpCVA;
	{
		XLog logPath("Path simulation");
		cpCVA=genPaths();
		logPath.end();
	}

	float totalCVA;
	{
		XLog logSum("Sum CVA");
		totalCVA=getCumulativeCVA(cpCVA,cp);
		logSum.log("total CVA:",totalCVA);
	}
	logMain.end();
	return 0;
}
