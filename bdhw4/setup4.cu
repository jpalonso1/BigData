#include "setup4.h"



void setupCounterparties(counterParties * cp, int size) {
	//DESC: initialize counterparties with predefined hazard rates
	int partiesFifth = size / 5;
	for (int j = 0; j < 5; j++) {
		float thisHazard = 0.02 * (1 + j);
		int startCount = partiesFifth * j;
		for (long i = 0; i < partiesFifth; i++) {
			cp[startCount + i].hazardRate = thisHazard;
		}
	}
}

void allocateDeals(counterParties* cp, int size) {
	//allocate at least one deal to each counterparty
	for (int i = 0; i < size; i++) {
		cp[i].netCashDeal = getRandomCash();
		cp[i].swapFixed[getRandomSwapMonth()]=getRandomSwapAmount();
		cp[i].numSwaps++;
	}
	//allocate the remaining deals randomly according to allocation probabilities
	//assign cash deals randomly
	for (int i = 0; i < (CASH_DEALS_NUM - size); i++) {
		long partyCashAllocated = getRandomAllocation(size);
		cp[partyCashAllocated].netCashDeal += getRandomCash();
	}

	//assign swaps randomly
	for (int i = 0; i < (SWAP_DEALS_NUM - size); i++) {
		long partySwapAllocated = getRandomAllocation(size);
		cp[partySwapAllocated].numSwaps++;
		cp[partySwapAllocated].swapFixed[getRandomSwapMonth()]=getRandomSwapAmount();
	}
}

long getRandomAllocation(int size) {
	//get a number between 0 and 30
	int numAlloc = rand() % 31;
	//define the target
	for (int i = 0; i < 5; i++) {
		if (numAlloc < PROP_CUTOFF[i]) {
			return ((size / 5) * i) + rand() % (size / 5);
		}
	}
	//error, no target found
	return -1;
}
//parameter file
//button in exel to generate data (to text parameter)
//launch cva button (command line vs rtd)
//turn flag to red/green
//using txt output vs rtd? rtd recommended
//give partial progress on excel/time estimate?
long getRandomCash() {
	//get absolute value of deal
	long deal = MIN_DEAL_CASH + xfun::randomUniform() * (MAX_DEAL_CASH - MIN_DEAL_CASH);
	//adjust if short
	if (xfun::randomUniform() > PERCENT_CASH_LONG)deal = (-deal);
	return deal;
}

long getRandomSwapAmount(){
	//get absolute value of deal
	long deal = MIN_DEAL_SWAP + xfun::randomUniform() * (MAX_DEAL_SWAP - MIN_DEAL_SWAP);
	//adjust if eur;
	if (xfun::randomUniform()>0.5)deal=deal/STARTING_PRICE;
	//adjust if short
	if (xfun::randomUniform() > PERCENT_SWAP_LONG)deal = (-deal);
	//get fixed rate
	float rate = MIN_RATE_SWAP + xfun::randomUniform() * (MAX_RATE_SWAP - MIN_RATE_SWAP);
	//get yearly fixed amount

	return deal*rate;
}

long getRandomSwapMonth(){
	return (rand() %SWAP_PERIODS);
}

void writeCounterparties(counterParties* cp,string& fileName, int size){
	std::ofstream outFile(fileName.c_str());
	for (long i=0;i<size;i++){
		outFile<<cp[i].hazardRate<<","<<cp[i].netCashDeal<<","<<cp[i].numSwaps;
//		for (long j=0;j<cp[i].numSwaps;j++){
//			outFile<<cp[i].SwapDeal[j]<<",";
//		}
		outFile<<'\n';
	}
	outFile.close();
}

void printCPDetails(counterParties& cp){
	cout<<cp.hazardRate<<","<<cp.netCashDeal<<","<<cp.numSwaps<<"|";
	for (int i=0;i<SWAP_PERIODS;i++){
		cout<<i<<','<<cp.swapFixed[i]<<'|'<<endl;
	}
	cout<<endl;
}
