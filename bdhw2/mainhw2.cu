//Juan Pablo Alonso

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

struct counterpartyCVA
{
	//DESC: holds the normalized simulation results for each type of counterparty
	float normalizedCVA[5];
	//intialize counterparties and set to 0
	__host__ __device__
	counterpartyCVA()
	{
		for (int i=0;i<5;i++){normalizedCVA[i]=0;}
	}
};

__host__ __device__
counterpartyCVA operator+(const counterpartyCVA &cvaL, const counterpartyCVA &cvaR){
	//DESC: operator to be called in thrust binary operation to aggregate the results of each simulation
	//IN: two counterpartyCVA object to be added
	//OUT: a counterpartyCVA object containing the sum of both input objects
	counterpartyCVA tempCVA;
	for(int i=0;i<5;i++){
		tempCVA.normalizedCVA[i]=cvaL.normalizedCVA[i]+cvaR.normalizedCVA[i];
	}
	return tempCVA;
}

struct get_CVA : public thrust::unary_function<unsigned int,counterpartyCVA>
{
	paramStruct pard;
	get_CVA(paramStruct _pard):pard(_pard){}

	__host__ __device__
	counterpartyCVA operator()(unsigned int seed)
	{
		//DESC: functor to run each simulation
		//IN: seed for random number generation
		//OUT: CVA object to be aggregated

		//initialize output counterparty results
		counterpartyCVA sumCVA;

		// seed a random number generator
		thrust::default_random_engine rng(seed);

		// create a mapping from random numbers to [0,1)
		thrust::random::experimental::normal_distribution<float> ndist(0, 1.0f);

		//initialize parameters for simulation
		float timeStep=pard.YEARS/float(pard.NUM_TIMESTEPS);
		float time=0;
		float defProb=0;
		float price=pard.STARTING_PRICE;
		float discount=1;
		//factor used in random evolution of price
		float priceFactor=sqrt(pard.VARIANCE)*(timeStep);

		//to hold the random normal generated each step
		float normal=ndist(rng);

		//initialize hazard rate factors (TO BE PARAMETRIZED?
		float hazard[5];
		for (int i=0;i<5;i++){
			hazard[i]=pard.BASE_HAZARD+pard.BASE_HAZARD*float(i);
		}

		//run the required number of steps
		//NOTE: TO BE OPTIMIZED
		for(unsigned int i = 0; i < pard.NUM_TIMESTEPS-1; ++i){
			time=time+timeStep;
			//get new price

			normal=ndist(rng);
			price+=price*normal*priceFactor;
			//get discount for current step
			discount=1.0/exp(pard.DISCOUNT*time);
			//find default probability for each and copy result to output CVA struct
			for (int j=0;j<5;j++){
				defProb=1.0f/exp((time-timeStep)*hazard[j])-1.0f/exp(time*hazard[j]);
				sumCVA.normalizedCVA[j]+=defProb*discount*price;
			}
			normal=ndist(rng);
		}
		return sumCVA;
	}
};

counterpartyCVA genPaths();
float getCumulativeCVA(counterpartyCVA& cpCVA,vector<counterParties>& cp);

int main(){
	XLog logMain("CVA Main");

	//-----------------Setup
	//initialize counterparties vector
	XLog logAlloc("Setup");
	vector<counterParties> cp(parh.PARTIES_NUM);
	//intialize counterparties CVA
	setupCounterparties(cp);
	//assign deals to counterparties randomly based on ratio
	allocateDeals(cp);
	logAlloc.end();

	//----------------Simulation
	XLog logPath("Path simulation");
	counterpartyCVA cpCVA;
	cpCVA=genPaths();
	logPath.end();

	//---------------Aggregation
	XLog logSum("Aggregate CVA");
	float totalCVA;
	totalCVA=getCumulativeCVA(cpCVA,cp);
	logSum.log("total CVA:",totalCVA);

	logMain.end();
	return 0;
}

counterpartyCVA genPaths(){
	//DESC: simulates the CVA and obtains the average
	//OUT: Counterparty factor object

	//CVA aggregator for simulations run
    thrust::plus<counterpartyCVA> binary_op;
    counterpartyCVA cpCVA;
    //run the simulation using thrust reduction
    cpCVA = thrust::transform_reduce(thrust::counting_iterator<int>(0),
			thrust::counting_iterator<int>(parh.NUM_SIMULATIONS),get_CVA(parh),cpCVA,binary_op);

	for (int i=0;i<5;i++)
	{cpCVA.normalizedCVA[i]=cpCVA.normalizedCVA[i]/float(parh.NUM_SIMULATIONS);}
	return cpCVA;
}

float getCumulativeCVA(counterpartyCVA& cpCVA,vector<counterParties>& cp){
	//DESC: uses the normalized CVA factors to get the total CVA for each counterparty
	//and aggregates it
	//IN: normalized CVA factor, vector containing all counterParties
	float sumCVA=0;
	int partiesFifth = parh.PARTIES_NUM / 5;
	for (int j = 0; j < 5; j++) {
		int startCount = partiesFifth * j;
		for (long i = 0; i < partiesFifth; i++) {
			sumCVA+=cpCVA.normalizedCVA[j]*cp[startCount + i].netDeal;
		}
	}
	return sumCVA;
}
