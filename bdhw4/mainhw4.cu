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
	float normalizedSwapFloatCVA[5][MAX_PERIODS];
	float normalizedSwapFixedCVA[5][MAX_PERIODS];
	//intialize counterparties and set to 0
	__host__ __device__
	counterpartyCVA()
	{
		for (int i=0;i<5;i++){
			normalizedCashCVA[i]=0;
			for (long j=0;j<MAX_PERIODS;j++){
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
		for (long j=0;j<MAX_PERIODS;j++){
			tempCVA.normalizedSwapFloatCVA[i][j]=
					cvaL.normalizedSwapFloatCVA[i][j]+cvaR.normalizedSwapFloatCVA[i][j];
			tempCVA.normalizedSwapFixedCVA[i][j]=
					cvaL.normalizedSwapFixedCVA[i][j]+cvaR.normalizedSwapFixedCVA[i][j];
		}
	}
	return tempCVA;
}

__host__ __device__
inline float getNSCurve(float * BS,float t){
	//0=beta0, 1=beta1, 2=beta2, 3=lambda
	float tOverL=t/BS[3];
	return BS[0]+BS[1]*BS[3]*(1-exp(-tOverL))/t+BS[2]*BS[3]*((1-exp(-tOverL))/(t-exp(-tOverL)));
//	return b0+b1*exp(-tOverL)+b2*tOverL*exp(-tOverL);
}

struct get_CVA4 : public thrust::unary_function<unsigned int,counterpartyCVA>
{
	paramStruct pard;
	get_CVA4(paramStruct _pard):pard(_pard){}

	__host__ __device__
	counterpartyCVA operator()(unsigned long seed)
	{
		//initialize output counterparty results
		counterpartyCVA sumCVA;

		// seed a random number generator
		thrust::default_random_engine rng(seed);

		//Standard Normal distribution
		thrust::random::experimental::normal_distribution<float> ndist(0, 1.0f);

		//initialize parameters for simulation
		float timeStep=float(pard.YEARS)/float(pard.SWAP_PERIODS);
		float defProb=0;
		double price=pard.STARTING_PRICE;

		//factor used in random evolution of price
		float priceFactor=sqrt(pard.VARIANCE)*(timeStep);

		//to hold the random normal generated each step for asset
		float normal=0;
		//to hold normal for NS curve
		float normalNS=0;

		//initialize hazard rate factors
		float hazard[5];
		for (int i=0;i<5;i++)
		{
			hazard[i]=pard.BASE_HAZARD+pard.BASE_HAZARD*float(i);
		}

		//initialize nelson siegel factors
		float NS0[4];
		float NS1[4];
		thrust::random::experimental::normal_distribution<float> normNS[4];
		for (int i=0;i<4;i++){
			NS0[i]=pard.NS.xBar[i];
			//Normal distribution for siegel curve
			normNS[i]=thrust::random::experimental::normal_distribution<float> (pard.NS.xBar[i], 1.0f);
		}

		float time=0;
		float curveRate=0;
		float curveRateLast=0;
		float discount=1;

		float sqTimeStep=sqrt(timeStep);
		float stepDisc=0;
		//eliminate first random number
		normal=ndist(rng);
		//probability of default this and last period
		//run the required number of steps
		for(unsigned long i = 0; i < pard.SWAP_PERIODS-1; ++i){
			time=time+timeStep;
			//get new price
			normal=ndist(rng);
			price+=price*normal*priceFactor;
			//update NS curve factors
			for (int j=0;j<4;j++){
				//generate factors for current step using nelson siegel
				normalNS=normNS[j](rng);
				NS1[j]=pard.NS.alpha[j]*(pard.NS.xBar[j]-NS0[j])+pard.NS.sd[j]*sqTimeStep*normalNS;
				NS0[j]=NS1[j];
			}
			curveRate=getNSCurve(NS1,pard.YEARS-time);
			//fix nan values (in low-probability case that function explodes) assign last found value
			if (curveRate!=curveRate)curveRate=curveRateLast;
			//prevent values from exploding
			else if(curveRate<0||curveRate>1)curveRate=curveRateLast;
			curveRateLast=curveRate;

			//override for testing
			curveRate=0.06;

			stepDisc=exp(-timeStep*curveRate);
			discount=discount*stepDisc;
			//find default probability for each and copy result to output CVA struct
			for (int j=0;j<5;j++){
				defProb=1.0f/exp((time-timeStep)*hazard[j])-1.0f/exp(time*hazard[j]);
				sumCVA.normalizedCashCVA[j]+=defProb*discount*price;
				sumCVA.normalizedSwapFixedCVA[j][i]=-defProb*discount;
				sumCVA.normalizedSwapFloatCVA[j][i]=defProb*stepDisc*curveRate*1.0/12.0;
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
			thrust::counting_iterator<int>(parh.NUM_SIMULATIONS),get_CVA4(parh),cpCVA,binary_op);
	//find averages for the CVA
	for (int i=0;i<5;i++){
		cpCVA.normalizedCashCVA[i]=cpCVA.normalizedCashCVA[i]/float(parh.NUM_SIMULATIONS);
		for (long j=0;j<parh.SWAP_PERIODS;j++){
			cpCVA.normalizedSwapFixedCVA[i][j]=cpCVA.normalizedSwapFixedCVA[i][j]/float(parh.NUM_SIMULATIONS);
			cpCVA.normalizedSwapFloatCVA[i][j]=cpCVA.normalizedSwapFloatCVA[i][j]/float(parh.NUM_SIMULATIONS);
		}
	}
	return cpCVA;
}

float getAverageCVA(counterpartyCVA& cpCVA,counterParties* cp,long size)
{
	float cashCVA=0;
	float floatCVA=0;
	float fixedCVA=0;
	long partiesFifth = size / 5;
	for (int j = 0; j < 5; j++) {
		long startCount = partiesFifth * j;
		for (long i = 0; i < partiesFifth; i++) {
			cashCVA+=cpCVA.normalizedCashCVA[j]*cp[startCount + i].netCashDeal;
			for (long k=0;k<parh.SWAP_PERIODS;k++){
				fixedCVA+=cpCVA.normalizedSwapFixedCVA[j][k]*cp[startCount+i].swapFixed[k];
				floatCVA+=cpCVA.normalizedSwapFloatCVA[j][k]*cp[startCount+i].swapFloatNom[k];
			}
		}
	}
	cout<<"total cash: "<<cashCVA<<endl;
	cout<<"total float: "<<floatCVA<<endl;
	cout<<"total fixed: "<<fixedCVA<<endl;
	return cashCVA+floatCVA+fixedCVA;
}


int main(){
	XLog logMain("CVA 2 Main");
	logMain.start();
	//break processing into groups to manage memory
//	const long cpBatches=PARTIES_NUM/iMAX_CP_GROUP+bool(PARTIES_NUM%iMAX_CP_GROUP);
	cout<<"batches: "<<parh.CP_BATCHES<<endl;
	//track sum of CVA from all batches
	float sumCVA=0;
	//manage deal allocation
	for (int i=0;i<parh.CP_BATCHES;i++){
		//allocate memory for a single batch
		counterParties cp[iMAX_CP_GROUP];

		XLog logAlloc("Setup");
		cout<<"counterparties:"<<endl;
		setupCounterparties(cp);
		cout<<"deals:"<<endl;
		allocateDeals(cp);
		cout<<"counterparties"<<endl;
		logAlloc.end();

		XLog logTransform("Transform");
		cout<<"Transform: "<<endl;
		counterpartyCVA cpCVA=genPaths();
		logTransform.end();

		XLog logSum("Aggregate CVA");
		float totalCVA=getAverageCVA(cpCVA,cp,iMAX_CP_GROUP);
		sumCVA+=totalCVA;
		logSum.log("batch CVA:",totalCVA);

	}
	logMain.log("total CVA:",sumCVA);
	logMain.end();
	return 0;
}
