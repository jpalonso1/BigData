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
		setRandomFixedSwap(cp[i]);
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
		setRandomFixedSwap(cp[partySwapAllocated]);
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
float getRandomCash() {
	//get absolute value of deal
	float deal = MIN_DEAL_CASH + xfun::randomUniform() * (MAX_DEAL_CASH - MIN_DEAL_CASH);
	//adjust if short
	if (xfun::randomUniform() > PERCENT_CASH_LONG)deal = (-deal);
	return deal;
}

float getRandomSwapAmount(){
	//FUN: returns a monthly fixed amount for the swap
	//get absolute value of deal
	long deal = MIN_DEAL_SWAP + xfun::randomUniform() * (MAX_DEAL_SWAP - MIN_DEAL_SWAP);
	//adjust if eur;
	if (xfun::randomUniform()>0.5)deal=deal/STARTING_PRICE;
	//adjust if short
	if (xfun::randomUniform() > PERCENT_SWAP_LONG)deal = (-deal);
	return deal;
}

void setRandomFixedSwap(counterParties& cp){
	//FUN: adds fixed payments up to a random month for input counterparty
	int month=rand() %SWAP_PERIODS;
	float notionalValue=getRandomSwapAmount();
	//get fixed rate
	float rate = MIN_RATE_SWAP + xfun::randomUniform() * (MAX_RATE_SWAP - MIN_RATE_SWAP);
	float fixedMonthAmt=rate*notionalValue/12.0;
	for (int i=0;i<month;i++){
		cp.swapFixed[i]+=fixedMonthAmt;
		cp.swapFloatNom[i]+=notionalValue;
	}
	//track total number of swaps for specific cp
	cp.numSwaps++;
}

void writeCounterparties(counterParties* cp,string& fileName, int size){
}

void saveCP(counterParties* cp,string fileName,long size){
	std::ofstream binFile;
	binFile.open (fileName.c_str(), ios::out| ios::binary);
	binFile.write ((char*)cp, size*sizeof(counterParties));
	binFile.close();

}

void printCPDetails(counterParties& cp){
	cout<<cp.hazardRate<<","<<cp.netCashDeal<<","<<cp.numSwaps<<"|";
	for (int i=0;i<SWAP_PERIODS;i++){
		cout<<i<<','<<cp.swapFixed[i]<<','<<cp.swapFloatNom[i]*DISCOUNT/12.0<<'|'<<endl;
	}
	cout<<endl;
}
