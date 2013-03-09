#include "parameters.h"
#include "setup.h"

//#include <thrust/device_vector.h>
//#include <thrust/transform.h>
//#include <thrust/sequence.h>
//#include <thrust/copy.h>
//#include <thrust/fill.h>
//#include <thrust/replace.h>
//#include <thrust/functional.h>

using namespace std;

//struct saxpy_functor
//{
//    const float a;
//
//    saxpy_functor(float _a) : a(_a) {}
//
//    __host__ __device__
//        float operator()(const float& x, const float& y) const {
//            return a * x + y;
//        }
//};
//
//void saxpy_fast(float A, thrust::device_vector<float>& X, thrust::device_vector<float>& Y)
//{
//    // Y <- A * X + Y
//    thrust::transform(X.begin(), X.end(), Y.begin(), Y.begin(), saxpy_functor(A));
//}
//
//void wdasd(float A, thrust::device_vector<float>& X, thrust::device_vector<float>& Y)
//{
//    // Y <- A * X + Y
//    thrust::transform(X.begin(), X.end(), Y.begin(), Y.begin(), saxpy_functor(A));
//}

int main(){
	cout<<"starting..."<<endl;
	counterParties cp[PARTIES_NUM];
	setupCounterparties(cp);
	allocateDeals(cp);
	for (int i=0;i<PARTIES_NUM;i++)
	{
		cout<<cp[i].netDeal<<endl;
	}

	cout<<"ending..."<<endl;

	return 0;
}


