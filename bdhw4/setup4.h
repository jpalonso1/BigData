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
	long numSwaps;
	counterParties()
	{
		hazardRate=0;
		netCashDeal=0;
		numSwaps=0;
		for (int i=0;i<SWAP_PERIODS;i++){
			swapFixed[i]=0;
		}
	}
};



void setupCounterparties(counterParties* cp,int size);
void allocateDeals(counterParties* cp,int size);
void allocateSwaps(counterParties* cp,int size);
void writeCounterparties(counterParties* cp,string& fileName,int size);

//get a random counter party number (based on predefined allocation ratios)
long getRandomAllocation(int size);

//returns a random deal within the range, can be positive or negative
long getRandomCash();
long getRandomSwapAmount();
long getRandomSwapMonth();

//print details of a single counterparty
void printCPDetails(counterParties& cp);

#endif /* SETUP_H_ */
