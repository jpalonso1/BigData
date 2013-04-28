#include "setup4.h"

void setupCounterparties(counterParties * cp) {
	//DESC: initialize counterparties with predefined hazard rates
	long partiesFifth = iMAX_CP_GROUP / 5;
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
	for (long i = 0; i < iMAX_CP_GROUP; i++) {
		cp[i].netCashDeal = getRandomCash();
		setRandomFixedSwap(cp[i]);
	}
	//allocate the remaining deals randomly according to allocation probabilities
	//assign cash deals randomly
	for (long i = 0; i < (parh.CASH_DEALS_NUM/parh.CP_BATCHES - iMAX_CP_GROUP); i++) {
		long partyCashAllocated = getRandomAllocation();
		cp[partyCashAllocated].netCashDeal += getRandomCash();
	}

	//assign swaps randomly
	for (long i = 0; i < (parh.SWAP_DEALS_NUM/parh.CP_BATCHES - iMAX_CP_GROUP); i++) {
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
			return ((iMAX_CP_GROUP / 5) * i) + rand() % (iMAX_CP_GROUP / 5);
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
	float deal = parh.MIN_DEAL_CASH + xfun::randomUniform() * (parh.MAX_DEAL_CASH - parh.MIN_DEAL_CASH);
	//adjust if short
	if (xfun::randomUniform() > parh.PERCENT_CASH_LONG)deal = (-deal);
	return deal;
}

float getRandomSwapAmount(){
	//DES: returns a monthly fixed amount for the swap
	//get absolute value of deal
	long deal = parh.MIN_DEAL_SWAP + xfun::randomUniform() * (parh.MAX_DEAL_SWAP - parh.MIN_DEAL_SWAP);
	//adjust if eur;
	if (xfun::randomUniform()>0.5)deal=deal/parh.STARTING_PRICE;
	//adjust if short
	if (xfun::randomUniform() > parh.PERCENT_SWAP_LONG)deal = (-deal);
	return deal;
}

void setRandomFixedSwap(counterParties& cp){
	//DES: adds fixed payments up to a random month for input counterparty
	long month=rand() %(parh.SWAP_PERIODS-parh.SWAP_START+1)+parh.SWAP_START;
	float notionalValue=getRandomSwapAmount();
	//get fixed rate
	float rate = parh.MIN_RATE_SWAP + xfun::randomUniform() * (parh.MAX_RATE_SWAP - parh.MIN_RATE_SWAP);
	float fixedMonthAmt=rate*notionalValue/12.0;
	for (long i=0;i<month;i++){
		cp.swapFloatNom[i]+=notionalValue;
		cp.swapFixed[i]+=fixedMonthAmt;
	}
	//track total number of swaps for specific cp
	cp.numSwaps++;
}

void writeCounterparties(counterParties* cp,string& fileName){
}

void prlongCPDetails(counterParties& cp){
	cout<<cp.hazardRate<<","<<cp.netCashDeal<<","<<cp.numSwaps<<"|";
	for (long i=0;i<parh.SWAP_PERIODS;i++){
		cout<<i<<','<<cp.swapFixed[i]<<','<<cp.swapFloatNom[i]*parh.DISCOUNT/12.0<<'|'<<endl;
	}
	cout<<endl;
}
