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
#include <thrust/host_vector.h>
//#include <thrust/copy.h>
//#include <thrust/fill.h>
//#include <thrust/replace.h>
//#include <thrust/functional.h>

using namespace std;

struct path_generation
{
	const int steps;
	const double initial;
	const double factor;
	const counterParties* cp;

    path_generation(int _steps,double _initial,double _factor,counterParties *_cp)
    : steps(_steps),initial(_initial),factor(_factor),cp(_cp) {}

    __host__ __device__
	double operator()(const double& x) const {
    	double CVA=0;
//		double current=initial;
//		float normal=0;
//		//check for seed number?
//		//move outside struct to avoid duplicates?
//		thrust::random::minstd_rand rng(x);
//		//thrust::random::experimental::normal_distribution<float> dist(2.0, 3.5);
//		thrust::uniform_real_distribution<float> dist(0,1.0);
//		double PI=3.14159265359;
//		double timeStep=YEARS/double(NUM_TIMESTEPS);
//		double time=0;
//		double tempCVA=0;
//		for (int i=1;i<steps;i++)
//		{
//			time+=timeStep;
//			//use box-muller to get a normal (Thrust normal is not working)
//			normal=(1/sqrt(2.0*dist(rng)))*cos(2*PI*dist(rng));
//			//evolve the price path one step
//			current=current+current*normal*factor;
//			tempCVA=0;
//			for (int j=0;j<PARTIES_NUM;j++)
//			{
////				CVA+=((1.0/exp(cp[j].hazardRate*time))-(1.0/exp(cp[j].hazardRate*(time-timeStep))))*
////						cp[j].netDeal*current;
////				CVA+=cp[j].netDeal/PARTIES_NUM;
////				double exposure=current;
////				defCurr=exp(-cp[i].hazardRate*time);
////				cp[i].CVAVal+=(defCurr-defLast)*exposure*exp(-time*DISCOUNT);
////				CVA+=exp(cp[j])
//			}
//			CVA+=tempCVA*(1.0/exp(time*DISCOUNT));
//		}
//		cout<<CVA<<endl;
		return CVA;
    }
};

double genPaths(long _steps,float _initial,float _factor,vector<counterParties>& cp)
{
	thrust::host_vector<float> hX(PARTIES_NUM);
    thrust::sequence(hX.begin(), hX.end());
	thrust::device_vector<float> X=hX;
	thrust::device_vector<counterParties> dcp(cp.begin(),cp.end());

	counterParties *raw_ptr = thrust::raw_pointer_cast(&dcp[0]);

	double average=0;
    thrust::plus<double> binary_op;
    return thrust::transform_reduce(X.begin(), X.end(),path_generation(_steps,_initial,_factor,raw_ptr),average,binary_op);
    return 1;
}

int main(){
	cout<<"starting..."<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;
	vector<counterParties> cp(PARTIES_NUM);
	setupCounterparties(cp);
	allocateDeals(cp);
	cout<<"Parties setup complete; "<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;

	float factor=sqrt(VARIANCE)*(YEARS/float(NUM_TIMESTEPS));

	float average=genPaths(NUM_TIMESTEPS,STARTING_PRICE,factor,cp);
	cout<<"average: "<<(average/NUM_SIMULATIONS)<<endl;

	cout<<"ending..."<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;

	return 0;
}


