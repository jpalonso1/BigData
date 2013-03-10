#include "parameters.h"
#include "setup.h"

#include <thrust/device_vector.h>
#include <thrust/transform.h>
#include <thrust/sequence.h>
#include <thrust/copy.h>
#include <thrust/fill.h>
#include <thrust/replace.h>
#include <thrust/functional.h>
#include <thrust/random.h>
#include <thrust/random/linear_congruential_engine.h>
#include <thrust/random/normal_distribution.h>

using namespace std;

struct path_generation
{
	const int steps;
	const double initial;
	const double factor;

    path_generation(int _steps,double _initial,double _factor)
    : steps(_steps),initial(_initial),factor(_factor) {}

    __host__ __device__
	double operator()(const double& x) const {
    	double average=0;
		double current=initial;
		float normal=0;
		//check for seed number?
		//move outside struct to avoid duplicates?
		thrust::random::minstd_rand rng(x);
		//thrust::random::experimental::normal_distribution<float> dist(2.0, 3.5);
		thrust::uniform_real_distribution<float> dist(0,1.0);
		double PI=3.14159265359;
		for (int i=0;i<steps;i++)
		{
			//use box-muller to get a normal (Thrust normal is not working)
			normal=(1/sqrt(2.0*dist(rng)))*cos(2*PI*dist(rng));
			current=current+current*normal*factor;
			average+=current/double(steps);
		}
    	cout<<"interm average: "<<average<<endl;
		return average;
    }
};

double genPaths(long _steps,double _initial,double _factor)
{
	thrust::device_vector<double> X(NUM_SIMULATIONS);
	double average=0;
    thrust::plus<double> binary_op;
    thrust::sequence(X.begin(), X.end());
    return thrust::transform_reduce(X.begin(), X.end(),path_generation(_steps,_initial,_factor),average,binary_op);
}


int main(){
	cout<<"starting..."<<endl;
	counterParties cp[PARTIES_NUM];
	setupCounterparties(cp);
	allocateDeals(cp);
	double factor=sqrt(VARIANCE)*(YEARS/double(NUM_TIMESTEPS));

	double average=genPaths(NUM_TIMESTEPS,STARTING_PRICE,factor);
	cout<<"average: "<<(average/NUM_SIMULATIONS);

	cout<<"ending..."<<endl;



	return 0;
}


