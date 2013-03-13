#include "parameters.h"
#include "setup.h"
#include <vector>

//x6y
//#include <thrust/fill.h>
//#include <cuda.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/random.h>
#include <thrust/transform.h>
#include <thrust/reduce.h>
#include <thrust/host_vector.h>
#include <thrust/iterator/counting_iterator.h>
//#include <thrust/copy.h>
//#include <thrust/fill.h>
//#include <thrust/replace.h>
//#include <thrust/functional.h>

using namespace std;

//struct path_generation
//{
//	const int steps;
//	const double initial;
//	const double factor;
//	const counterParties* cp;
//
//    path_generation(int _steps,double _initial,double _factor,counterParties *_cp)
//    : steps(_steps),initial(_initial),factor(_factor),cp(_cp) {}
//
//    __host__ __device__
//	double operator()(const double& x) const {
//    	double CVA=0;
////		double current=initial;
////		float normal=0;
////		//check for seed number?
////		//move outside struct to avoid duplicates?
////		thrust::random::minstd_rand rng(x);
////		//thrust::random::experimental::normal_distribution<float> dist(2.0, 3.5);
////		thrust::uniform_real_distribution<float> dist(0,1.0);
////		double PI=3.14159265359;
////		double timeStep=YEARS/double(NUM_TIMESTEPS);
////		double time=0;
////		double tempCVA=0;
////		for (int i=1;i<steps;i++)
////		{
////			time+=timeStep;
////			//use box-muller to get a normal (Thrust normal is not working)
////			normal=(1/sqrt(2.0*dist(rng)))*cos(2*PI*dist(rng));
////			//evolve the price path one step
////			current=current+current*normal*factor;
////			tempCVA=0;
////			for (int j=0;j<PARTIES_NUM;j++)
////			{
//////				CVA+=((1.0/exp(cp[j].hazardRate*time))-(1.0/exp(cp[j].hazardRate*(time-timeStep))))*
//////						cp[j].netDeal*current;
//////				CVA+=cp[j].netDeal/PARTIES_NUM;
//////				double exposure=current;
//////				defCurr=exp(-cp[i].hazardRate*time);
//////				cp[i].CVAVal+=(defCurr-defLast)*exposure*exp(-time*DISCOUNT);
//////				CVA+=exp(cp[j])
////			}
////			CVA+=tempCVA*(1.0/exp(time*DISCOUNT));
////		}
////		cout<<CVA<<endl;
//		return CVA;
//    }
//};

struct get_CVA : public thrust::unary_function<unsigned int,float>
{
  __host__ __device__
  float operator()(unsigned int thread_id)
  {
    float sum = 0;
    unsigned int N = 100; // samples per thread

//    unsigned int seed = thread_id;

    // seed a random number generator
//    thrust::default_random_engine rng(seed);

    // create a mapping from random numbers to [0,1)
  //  thrust::uniform_real_distribution<float> u01(0,1);

    //float timeStep=YEARS/float(NUM_TIMESTEPS);
    //float time=0;
    //float defProb=0;

    // take N samples
    for(unsigned int i = 0; i < N; ++i)
    {
    //	time=time+timeStep;
    	defProb=0.0001;
    	sum+=defProb;
    }

    // divide by N
    return sum / N;
  }
};

double genPaths(float _factor,vector<counterParties>& _cp)
{
	thrust::host_vector<counterParties> hcp(_cp.begin(),_cp.end());

	float estimate = thrust::transform_reduce(thrust::counting_iterator<int>(0),
	                                            thrust::counting_iterator<int>(NUM_SIMULATIONS),
	                                            get_CVA(),
	                                            0.0f,
	                                            thrust::plus<float>());
	return estimate/NUM_SIMULATIONS;
}


int main(){
	cout<<"starting..."<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;
	vector<counterParties> cp(PARTIES_NUM);
	setupCounterparties(cp);
	allocateDeals(cp);
	cout<<"Parties setup complete; "<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;

	float factor=sqrt(VARIANCE)*(YEARS/float(NUM_TIMESTEPS));

	float average=genPaths(factor,cp);
	cout<<"average: "<<(average/NUM_SIMULATIONS)<<endl;

	cout<<"ending..."<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;

	return 0;
}


