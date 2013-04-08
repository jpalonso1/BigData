#include <string>
#include <vector>

#include "parameters4.h"
#include "setup4.h"
#include "xlog.h"

#include <thrust/random.h>
#include <thrust/transform.h>
#include <thrust/random/normal_distribution.h>

using namespace std;

//holds the normalized simulation results for each type of counterparty
struct counterpartyCVA
{
	float normalizedCashCVA[5];
	float normalizedSwapFloatCVA[5][SWAP_PERIODS];
	float normalizedSwapFixedCVA[5][SWAP_PERIODS];
	//intialize counterparties and set to 0
	__host__ __device__
	counterpartyCVA()
	{
		for (int i=0;i<5;i++){
			normalizedCashCVA[i]=0;
			for (long j=0;j<SWAP_PERIODS;j++){
				normalizedSwapFloatCVA[i][j]=0;
				normalizedSwapFixedCVA[i][j]=0;
			}
		}
	}
};

//operator to be called in thrust binary operation
__host__ __device__
counterpartyCVA operator+(const counterpartyCVA &cvaL, const counterpartyCVA &cvaR)
{
	counterpartyCVA tempCVA;
	for(int i=0;i<5;i++)
	{
		tempCVA.normalizedCashCVA[i]=cvaL.normalizedCashCVA[i]+cvaR.normalizedCashCVA[i];
		for (long j=0;j<SWAP_PERIODS;j++){
			tempCVA.normalizedSwapFloatCVA[i][j]=
					cvaL.normalizedSwapFloatCVA[i][j]+cvaR.normalizedSwapFloatCVA[i][j];
			tempCVA.normalizedSwapFixedCVA[i][j]=
					cvaL.normalizedSwapFixedCVA[i][j]+cvaR.normalizedSwapFixedCVA[i][j];
		}
	}
	return tempCVA;
}

struct get_CVA4 : public thrust::unary_function<unsigned int,counterpartyCVA>
{
	__host__ __device__
	counterpartyCVA operator()(unsigned long seed)
	{
		//initialize output counterparty results
		counterpartyCVA sumCVA;

		// seed a random number generator
		thrust::default_random_engine rng(seed);

		//Standard Normal distribution
		thrust::random::experimental::normal_distribution<float> ndist(0, 1.0f);

		//Normal distribution for siegel curve
		thrust::random::experimental::normal_distribution<float> ndistns(DISCOUNT, 1.0f);

		//initialize parameters for simulation
		float timeStep=float(YEARS)/float(SWAP_PERIODS);
		float defProb=0;
		double price=STARTING_PRICE;

		//factor used in random evolution of price
		float priceFactor=sqrt(VARIANCE)*(timeStep);

		//to hold the random normal generated each step for asset
		float normal=0;
		//to hold normal for NS curve
		float normalNS=0;

		//initialize hazard rate factors
		float hazard[5];
		for (int i=0;i<5;i++)
		{
			hazard[i]=BASE_HAZARD+BASE_HAZARD*float(i);
		}

		float time=0;
		//used for nelson siegel
		float x0=DISCOUNT;
		float x1=DISCOUNT;
		float thisDisc=0;
		float discount=1;
		float rateSD=sqrt(RATE_VARIANCE);
		float sqTimeStep=sqrt(timeStep);
		float stepDisc=0;
		//eliminate first random number
		normal=ndist(rng);
		//probability of default this and last period
		//run the required number of steps
//		if(seed==6)cout<<"start price: "<<price<<endl;
		for(unsigned long i = 0; i < SWAP_PERIODS-1; ++i)
		{
			time=time+timeStep;
			//get new price
			normal=ndist(rng);
//			if(i==1)cout<<"seed: "<<seed<<" normal 1: "<<normal<<endl;
//			if(seed==7 && i==0)cout<<"price factor: "<<priceFactor<<endl;
			price+=price*normal*priceFactor;
			//generate discount for current step using nelson siegel
			normalNS=ndistns(rng);
//			if (seed==8)cout<<i<<",norm: "<<normalNS<<",timest: "<<timeStep<<",";
			x1=ALPHA*(DISCOUNT-x0)+rateSD*sqTimeStep*normalNS;
			x0=x1;
			stepDisc=exp(-timeStep*x1);
			discount=discount*stepDisc;
//			if(seed==8)cout<<i<<','<<price<<','<<x1<<','<<discount<<endl;
			//find default probability for each and copy result to output CVA struct
			for (int j=0;j<5;j++)
			{
				defProb=1.0f/exp((time-timeStep)*hazard[j])-1.0f/exp(time*hazard[j]);
//				cout<<j<<" defprob: "<<defProb<<" discount: "<<discount<<" price: "<<price<<endl;
				sumCVA.normalizedCashCVA[j]+=defProb*discount*price;
				sumCVA.normalizedSwapFixedCVA[j][i]=defProb*discount;
				sumCVA.normalizedSwapFloatCVA[j][i]=defProb*stepDisc*x1*1.0/12.0;
//				if(seed==10)cout<<i<<" j: "<<j<<","<<sumCVA.normalizedSwapFixedCVA[j][i]<<endl;

			}
		}
		return sumCVA;
	}
};

counterpartyCVA genPaths()
{
	thrust::plus<counterpartyCVA> binary_op;
	counterpartyCVA cpCVA;
	cpCVA = thrust::transform_reduce(thrust::counting_iterator<int>(0),
			thrust::counting_iterator<int>(NUM_SIMULATIONS),get_CVA4(),cpCVA,binary_op);
	//find averages for the CVA
	for (int i=0;i<5;i++){
		cpCVA.normalizedCashCVA[i]=cpCVA.normalizedCashCVA[i]/float(NUM_SIMULATIONS);
		for (long j=0;j<SWAP_PERIODS;j++){
			cpCVA.normalizedSwapFixedCVA[i][j]=cpCVA.normalizedSwapFixedCVA[i][j]/float(NUM_SIMULATIONS);
			cpCVA.normalizedSwapFloatCVA[i][j]=cpCVA.normalizedSwapFloatCVA[i][j]/float(NUM_SIMULATIONS);
		}
	}
	return cpCVA;
}

float getCumulativeCVA(counterpartyCVA& cpCVA,counterParties* cp,long size)
{
	float sumCVA=0;
	float cashCVA=0;
	float floatCVA=0;
	float fixedCVA=0;
	long partiesFifth = size / 5;
	for (int j = 0; j < 5; j++) {
		long startCount = partiesFifth * j;
		for (long i = 0; i < partiesFifth; i++) {
			cashCVA+=cpCVA.normalizedCashCVA[j]*cp[startCount + i].netCashDeal;
			for (long k=0;k<SWAP_PERIODS;k++){
				fixedCVA+=cpCVA.normalizedSwapFixedCVA[j][k]*cp[startCount+i].swapFixed[k];
				floatCVA+=cpCVA.normalizedSwapFloatCVA[j][k]*cp[startCount+i].swapFloatNom[k];
			}
		}
	}
	cout<<"sum cash: "<<cashCVA<<endl;
	cout<<"sum fixed: "<<fixedCVA<<endl;
	cout<<"sum float: "<<floatCVA<<endl;
	sumCVA=cashCVA+floatCVA+fixedCVA;
	return sumCVA;
}

int main(){
	XLog logMain("CVA 2 Main");
	logMain.start();
	//break processing into groups to manage memory
//	const long cpBatches=PARTIES_NUM/iMAX_CP_GROUP+bool(PARTIES_NUM%iMAX_CP_GROUP);
	cout<<"batches: "<<CP_BATCHES<<endl;
	//manage deal allocation
//	const long cpPerBatch=PARTIES_NUM/cpBatches;

	for (int i=0;i<CP_BATCHES;i++){
		//allocate memory for a single batch
		counterParties cp[CP_PER_BATCH];
		XLog logAlloc("Setup");
		logAlloc.start();
		setupCounterparties(cp);
		logAlloc.log("Counterparties creation complete");
		allocateDeals(cp);
		logAlloc.log("Deal allocation complete");
		string cpFile("counterparties.txt");
//		writeCounterparties(cp,cpFile);
		saveCP(cp,"testBin");
		XLog logTransform("Transform");
		logTransform.start();
		counterpartyCVA cpCVA=genPaths();
		logTransform.end();
		logAlloc.log("Output file");
		cout<<"test deals: "<<cp[4200].numSwaps<<endl;
		logAlloc.end();
		{
			XLog logSum("Sum CVA");
			float totalCVA=getCumulativeCVA(cpCVA,cp,CP_PER_BATCH);
			logSum.log("total CVA:",totalCVA);
		}
	}
	logMain.end();
	return 0;
}
