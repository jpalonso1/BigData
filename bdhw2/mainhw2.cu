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

//holds properties/parameters updated from parameter file
const paramStruct parh=initParameters();

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
	paramStruct par;
	get_CVA(paramStruct _par):par(_par){}

	__host__ __device__
	counterpartyCVA operator()(unsigned int seed)
	{
		//initialize output counterparty results
		counterpartyCVA sumCVA;

		// seed a random number generator
		thrust::default_random_engine rng(seed);

		// create a mapping from random numbers to [0,1)
		thrust::random::experimental::normal_distribution<float> ndist(0, 1.0f);

		//initialize parameters for simulation
		float timeStep=YEARS/float(par.NUM_TIMESTEPS);
		float time=0;
		float defProb=0;
		float price=par.STARTING_PRICE;
		float discount=1;
		//factor used in random evolution of price
		float priceFactor=sqrt(par.VARIANCE)*(timeStep);

		//to hold the random normal generated each step
		float normal=ndist(rng);

		//initialize hazard rate factors (TO BE PARAMETRIZED?
		float hazard[5];
		for (int i=0;i<5;i++)
		{
			hazard[i]=par.BASE_HAZARD+par.BASE_HAZARD*float(i);
		}

		//run the required number of steps
		//NOTE: TO BE OPTIMIZED
		for(unsigned int i = 0; i < par.NUM_TIMESTEPS-1; ++i)
		{
			time=time+timeStep;
			//get new price

			normal=ndist(rng);
			price+=price*normal*priceFactor;
			//get discount for current step
			discount=1.0/exp(par.DISCOUNT*time);
			//find default probability for each and copy result to output CVA struct
			for (int j=0;j<5;j++)
			{
				defProb=1.0f/exp((time-timeStep)*hazard[j])-1.0f/exp(time*hazard[j]);
				sumCVA.normalizedCVA[j]+=defProb*discount*price;
			}
			normal=ndist(rng);
		}
		return sumCVA;
	}
};

counterpartyCVA genPaths()
{
//	//update parameters from parameter file
//	paramStruct parh;
//	parh=initParameters();

    thrust::plus<counterpartyCVA> binary_op;
    counterpartyCVA cpCVA;
    XLog logInTr("Inside Transform");
    logInTr.start();
	cpCVA = thrust::transform_reduce(thrust::counting_iterator<int>(0),
			thrust::counting_iterator<int>(NUM_SIMULATIONS),get_CVA(parh),cpCVA,binary_op);
	logInTr.end();
	cout<<"Transform end"<<endl;
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
//			cout<<cp[startCount + i].netDeal<<endl;
			sumCVA+=cpCVA.normalizedCVA[j]*cp[startCount + i].netDeal;
		}
	}
	return sumCVA;
}

int main(){
	XLog logMain("CVA Main");
	logMain.start();


	//-----------------Setup-----------------------
	//initialize counterparties vector
	XLog logAlloc("Setup");
	vector<counterParties> cp(PARTIES_NUM);
	//intialize counterparties CVA
	setupCounterparties(cp);
	logAlloc.log("Counterparties Setup");
	//assign deals to counterparties randomly based on ratio
	allocateDeals(cp);
	logAlloc.log("Deal allocation complete");
	logAlloc.end();

	counterpartyCVA cpCVA;
	XLog logPath("Path simulation");
	cpCVA=genPaths();
	logPath.end();

	float totalCVA;
	{
		XLog logSum("Sum CVA");
		totalCVA=getCumulativeCVA(cpCVA,cp);
		logSum.log("total CVA:",totalCVA);
	}
	logMain.end();
	return 0;
}
