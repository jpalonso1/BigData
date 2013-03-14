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

struct get_CVA : public thrust::unary_function<unsigned int,float>
{
	//hazard rate
	const float hr;

	//initialize
	get_CVA(float _hr):hr(_hr){}

	__host__ __device__
	float operator()(unsigned int seed)
	{
		float sumCVA = 0;
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

			sumCVA+=defProb*discount*price;
			//cout<<i<<" price: "<<price<<" disc: "<<discount<<" defProb: "<<defProb<<endl;

		}
		cout<<sumCVA<<endl;
		return sumCVA;
	}
};


float genPaths(vector<counterParties>& _cp)
{
	//thrust::device_vector<counterParties> dcp(_cp.begin(),_cp.end());

	float CVA = thrust::transform_reduce(thrust::counting_iterator<int>(0),
			thrust::counting_iterator<int>(NUM_SIMULATIONS),get_CVA(0.2),0.0f,thrust::plus<float>());
	return CVA/NUM_SIMULATIONS;
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


