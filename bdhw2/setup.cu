#include "setup.h"

void setupCounterparties(vector<counterParties>& cp) {
	int partiesFifth = PARTIES_NUM / 5;
	for (int j = 0; j < 5; j++) {
		float thisHazard = 0.02 * (1 + j);
		int startCount = partiesFifth * j;
		for (long i = 0; i < partiesFifth; i++) {
			cp[startCount + i].hazardRate = thisHazard;
			cp[startCount + i].netDeal = 0;
		}
	}
}

void allocateDeals(vector<counterParties>& cp) {
	//allocate at least one deal to each counterparty
	for (int i = 0; i < PARTIES_NUM; i++) {
		cp[i].netDeal = getRandomDeal();
	}
	//allocate the remaining deals randomly according to allocation probabilities
	for (int i = 0; i < (DEALS_NUM - PARTIES_NUM); i++) {
		float deal = getRandomDeal();
		long partyAllocated = getRandomAllocation();
		cp[partyAllocated].netDeal += deal;
	}
}

long getRandomAllocation() {

	//get a number between 0 and 30
	int numAlloc = rand() % 31;
	//define the target
	for (int i = 0; i < 5; i++) {
		if (numAlloc < PROP_CUTOFF[i]) {
			return ((PARTIES_NUM / 5) * i) + rand() % (PARTIES_NUM / 5);
		}
	}
	//error, no target found
	return -1;
}

long getRandomDeal() {

	//get absolute value of deal
	long deal = MIN_DEAL + xfun::randomUniform() * (MAX_DEAL - MIN_DEAL);
	//adjust if short
	if (xfun::randomUniform() > PERCENT_LONG)
		deal = (-deal);
	return deal;
}
