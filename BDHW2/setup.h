#ifndef SETUP_H_
#define SETUP_H_

#include "xfun.h"
#include "parameters.h"

struct counterParties {
	double hazardRate;
	double netDeal;
};

void setupCounterparties(counterParties *cp);
void allocateDeals(counterParties *cp);

//returns a random deal within the range, can be positive or negative
long getRandomDeal();
//get a random counter party number (based on predefined allocation ratios)
long getRandomAllocation();

#endif /* SETUP_H_ */
