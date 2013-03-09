#ifndef SETUP_H_
#define SETUP_H_

#include "xfun.h"
#include "parameters.h"

struct counterParties {
	double hazardRate;
	double netDeal;
	double CVAVal;
};

void setupCounterparties(counterParties *cp);
void allocateDeals(counterParties *cp);

long getRandomDeal();
long getRandomAllocation();

#endif /* SETUP_H_ */
