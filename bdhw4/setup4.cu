#include "setup4.h"

void setupCounterparties(counterParties * cp) {
	//DESC: initialize counterparties with predefined hazard rates
	long partiesFifth = CP_PER_BATCH / 5;
	for (long j = 0; j < 5; j++) {
		float thisHazard = 0.02 * (1 + j);
		long startCount = partiesFifth * j;
		for (long i = 0; i < partiesFifth; i++) {
			cp[startCount + i].hazardRate = thisHazard;
		}
	}
}

void allocateDeals(counterParties* cp) {
	//allocate at least one deal to each counterparty
	for (long i = 0; i < CP_PER_BATCH; i++) {
		cp[i].netCashDeal = getRandomCash();
		setRandomFixedSwap(cp[i]);
	}
	//allocate the remaining deals randomly according to allocation probabilities
	//assign cash deals randomly
	for (long i = 0; i < (CASH_DEALS_NUM/CP_BATCHES - CP_PER_BATCH); i++) {
		long partyCashAllocated = getRandomAllocation();
		cp[partyCashAllocated].netCashDeal += getRandomCash();
	}

	//assign swaps randomly
	for (long i = 0; i < (SWAP_DEALS_NUM/CP_BATCHES - CP_PER_BATCH); i++) {
		long partySwapAllocated = getRandomAllocation();
		setRandomFixedSwap(cp[partySwapAllocated]);
	}
}

long getRandomAllocation() {
	//get a number between 0 and 30
	long numAlloc = rand() % 31;
	//define the target
	for (long i = 0; i < 5; i++) {
		if (numAlloc < PROP_CUTOFF[i]) {
			return ((CP_PER_BATCH / 5) * i) + rand() % (CP_PER_BATCH / 5);
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
	long month=rand() %(SWAP_PERIODS-SWAP_START+1)+SWAP_START;
	float notionalValue=getRandomSwapAmount();
	//get fixed rate
	float rate = MIN_RATE_SWAP + xfun::randomUniform() * (MAX_RATE_SWAP - MIN_RATE_SWAP);
	float fixedMonthAmt=rate*notionalValue/12.0;
	for (long i=0;i<month;i++){
		cp.swapFixed[i]+=fixedMonthAmt;
		cp.swapFloatNom[i]+=notionalValue;
	}
	//track total number of swaps for specific cp
	cp.numSwaps++;
}

void writeCounterparties(counterParties* cp,string& fileName){
}

void saveCP(counterParties* cp,string fileName){
	std::ofstream binFile;
	binFile.open (fileName.c_str(), ios::out| ios::binary);
	binFile.write ((char*)cp, CP_PER_BATCH*sizeof(counterParties));
	binFile.close();
}

void prlongCPDetails(counterParties& cp){
	cout<<cp.hazardRate<<","<<cp.netCashDeal<<","<<cp.numSwaps<<"|";
	for (long i=0;i<SWAP_PERIODS;i++){
		cout<<i<<','<<cp.swapFixed[i]<<','<<cp.swapFloatNom[i]*DISCOUNT/12.0<<'|'<<endl;
	}
	cout<<endl;
}
