#ifndef SETUP_H_
#define SETUP_H_

#include "xfun.h"
#include "parameters4.h"
#include <vector>
#include <string>
#include <fstream>

using std::vector;
using std::string;

struct counterParties {
	double hazardRate;
	double netCashDeal;
	//one element for each month
	double swapFixed[SWAP_PERIODS];
	double swapFloatNom[SWAP_PERIODS];
	long numSwaps;
	counterParties()
	{
		hazardRate=0;
		netCashDeal=0;
		numSwaps=0;
		for (long i=0;i<SWAP_PERIODS;i++){
			swapFixed[i]=0;
			swapFloatNom[i]=0;
		}
	}
};

void setupCounterparties(counterParties* cp,long size);
void allocateDeals(counterParties* cp,long size);
void allocateSwaps(counterParties* cp,long size);
void writeCounterparties(counterParties* cp,string& fileName,long size);

//get a random counter party number (based on predefined allocation ratios)
long getRandomAllocation(long size);

//returns a random deal within the range, can be positive or negative
float getRandomCash();
void setRandomFixedSwap(counterParties& cp);
float getRandomSwapMthAmount();

//save counterparty array to binary file
void saveCP(counterParties* cp,string fileName,long size);

//print details of a single counterparty
void printCPDetails(counterParties& cp);

#endif /* SETUP_H_ */
