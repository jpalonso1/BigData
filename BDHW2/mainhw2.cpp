#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include "XLog.h"

using namespace std;

const long DEALS_NUM=1000000;
const long PARTIES_NUM=10000;
const long MIN_DEAL=8000000;
const long MAX_DEAL=12000000;
const double PERCENT_LONG=0.6;
const double STARTING_PRICE=1.4;
const int PROP_CUTOFF[5]={1,3,7,15,31};

struct counterParties{
	double hazardRate;
	long netDeal;
	long totalDeals;
};

void setupCounterparties(counterParties *cp);
void allocateDeals(counterParties *cp);

long getRandomDeal();
long getRandomAllocation();
double randomUniform();

int main(void)
{
	cout<<endl<<"start";
	//create counterparty structs
	counterParties cp[PARTIES_NUM];
	setupCounterparties(cp);
	allocateDeals(cp);
	cout<<endl<<"Deal allocation runtime: "<<double(clock())/double(CLOCKS_PER_SEC)<<" seconds";
	cout<<endl<<"end";
	cout<<endl<<"Total runtime: "<<double(clock())/double(CLOCKS_PER_SEC)<<" seconds";
	return 0;
}

void allocateDeals(counterParties *cp){
	//allocate at least one deal to each counterparty
	for (int i=0;i<PARTIES_NUM;i++)
	{
		cp[i].netDeal=getRandomDeal();
	}
	//allocate the remaining deals randomly according to allocation probabilities
	for (int i=0;i<(DEALS_NUM-PARTIES_NUM);i++)
	{
		double deal=getRandomDeal();
		long partyAllocated=getRandomAllocation();
		cp[partyAllocated].netDeal+=deal;
		cp[partyAllocated].totalDeals++;
	}
}

void setupCounterparties(counterParties *cp){
	//DESC: initialize counterparties with predefined hazard rates
	int partiesFifth=PARTIES_NUM/5;
	for (int j=0;j<5;j++)
	{
		double thisHazard=0.02*(1+j);
		int startCount=partiesFifth*j;
		for (long i=0;i<partiesFifth;i++)
		{
			cp[startCount+i].hazardRate=thisHazard;
			cp[startCount+i].netDeal=0;
			cp[startCount+i].totalDeals=0;
		}
	}
}

void log(string logI){
	cout<<endl<<logI;
}

long getRandomAllocation()
{
	//DESC: Get a random counter party number (based on predefined allocations)
	//get a number between 0 and 30
	int numAlloc= rand() % 31;
	//define the target
	for (int i=0;i<5;i++)
	{
		if (numAlloc<PROP_CUTOFF[i])
		{
			return ((PARTIES_NUM/5)*i)+rand()%(PARTIES_NUM/5);
		}
	}
	//error, no target found
	return -1;
}

long getRandomDeal(){
	//DESC: Returns a random deal within the range, can be positive or negative
	//get absolute value of deal
	long deal=MIN_DEAL+randomUniform()*(MAX_DEAL-MIN_DEAL);
	//adjust if short
	if (randomUniform()>PERCENT_LONG)deal=(-deal);
	return deal;
}

double randomUniform(){
	//DESC: simple random number (0,1)
	return double(rand())/double(RAND_MAX);
}
