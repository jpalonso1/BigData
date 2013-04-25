#ifndef SETUP_H_
#define SETUP_H_

#include "xfun.h"
#include "parameters.h"
#include <vector>

using std::vector;

struct counterParties {
	float hazardRate;
	float netDeal;
};

//initialize counterparties with predefined hazard rates
void setupCounterparties(vector<counterParties>& cp);

//randomly assign deals to counterparties based on specified ratio
void allocateDeals(vector<counterParties>& cp);

//returns a random deal within the range, can be positive or negative
long getRandomDeal();

//get a random counter party number (based on predefined allocation ratios)
long getRandomAllocation();

#endif /* SETUP_H_ */
