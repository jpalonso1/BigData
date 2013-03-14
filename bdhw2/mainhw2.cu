#include "parameters.h"
#include "setup.h"
#include <vector>

//x6y
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/random.h>
#include <thrust/transform.h>
#include <thrust/reduce.h>
#include <thrust/host_vector.h>
#include <thrust/iterator/counting_iterator.h>


using namespace std;

//holds the normalized simulation results for each type of counterpary
struct counterpartyCVA
{
	float normalizedCVA[5];

//	counterpartyCVA operator+(const counterpartyCVA &cvaR)
//	{
//		counterpartyCVA tempCVA;
//		for(int i=0;i<5;i++)
//		{
//			tempCVA.normalizedCVA[i]=normalizedCVA[i]+cvaR.normalizedCVA[i];
//		}
//		return tempCVA;
//	}

};

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
	//hazard rate
	const float hr;

	//initialize
	get_CVA(float _hr):hr(_hr){}

	__host__ __device__
	counterpartyCVA operator()(unsigned int seed)
	{
		//intialize counterparties and set to 0
		counterpartyCVA sumCVA;
		for (int i=0;i<5;i++)
		{
			sumCVA.normalizedCVA[i]=0;
		}
		// seed a random number generator
		thrust::default_random_engine rng(seed);

		// create a mapping from random numbers to [0,1)
		thrust::uniform_real_distribution<float> u01(0,1);

		float timeStep=YEARS/float(NUM_TIMESTEPS);
		float time=0;
		float defProb=0;
		double price=STARTING_PRICE;

		float factor=sqrt(VARIANCE)*(YEARS/float(NUM_TIMESTEPS));
		float normalRandom=0;
		;
		float discount=1;
		//run the required number of steps
		for(unsigned int i = 0; i < NUM_TIMESTEPS-1; ++i)
		{
			time=time+timeStep;
			//get new price
			normalRandom=(1/sqrt(2.0*u01(rng)))*cos(2*PI*u01(rng));
			price+=price*normalRandom*factor;
			//find default probability
			defProb=1.0f/exp((time-timeStep)*hr)-1.0f/exp(time*hr);
			//update discount
			discount=1.0/exp(DISCOUNT*time);

			sumCVA.normalizedCVA[0]+=defProb*discount*price;
		}
		return sumCVA;
	}
};


float genPaths(vector<counterParties>& _cp)
{
	thrust::plus<counterpartyCVA> binary_op;
	counterpartyCVA cpCVA;
	cpCVA = thrust::transform_reduce(thrust::counting_iterator<int>(0),
			thrust::counting_iterator<int>(NUM_SIMULATIONS),get_CVA(0.2),cpCVA,binary_op);
	return cpCVA.normalizedCVA[0]/NUM_SIMULATIONS;
}

int main(){
	cout<<"starting..."<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;
	vector<counterParties> cp(PARTIES_NUM);
	setupCounterparties(cp);
	allocateDeals(cp);
	cout<<"Parties setup complete; "<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;

	cout<<"average: "<<genPaths(cp)<<endl;

	cout<<"ending..."<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;

	return 0;
}


