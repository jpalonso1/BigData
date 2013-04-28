#ifndef PARAMETERS_H_
#define PARAMETERS_H_

#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <cmath>

#include "xparams.h"

const float PI=3.14159265359;

//parties parameters
const long PARTIES_NUM = 10000;
const float BASE_HAZARD=0.02;

//cash deals parameters
const long CASH_DEALS_NUM = 2000000;
const long MIN_DEAL_CASH = 800000;
const long MAX_DEAL_CASH = 1200000;
const float PERCENT_CASH_LONG = 0.6;

//swap parameters
const long SWAP_DEALS_NUM=250000;
const long MIN_DEAL_SWAP = 800000;
const long MAX_DEAL_SWAP = 1200000;
const float PERCENT_SWAP_LONG = 0.45;
const float MIN_RATE_SWAP = 0.02;
const float MAX_RATE_SWAP = 0.08;
const long YEARS=5;
//const long SWAP_PERIODS=12*YEARS;
const float STARTING_PRICE = 1.4;
const long FIRST_YEAR=2;
const long SWAP_START=FIRST_YEAR*12;

//asset parameters
const float VARIANCE=0.2;
const float DISCOUNT=0.06;

//simulation parameters
const long NUM_SIMULATIONS = 100000;

const int PROP_CUTOFF[5] = { 1, 3, 7, 15, 31 };

struct nelsonSiegelPar{
	//nelson siegel parameters
	//order: 0=beta0, 1=beta1, 2=beta2, 3=lambda
	float xBar[4];
	float alpha[4];
	float sd[4];
};

struct paramStruct{
	nelsonSiegelPar NS;
	long NUM_SIMULATIONS;

	//parties parameters
	long PARTIES_NUM;
	float BASE_HAZARD;

	//cash deals parameters
	long CASH_DEALS_NUM;
	long MIN_DEAL_CASH;
	long MAX_DEAL_CASH;
	float PERCENT_CASH_LONG;

	//swap parameters
	long SWAP_DEALS_NUM;
	long MIN_DEAL_SWAP;
	long MAX_DEAL_SWAP;
	float PERCENT_SWAP_LONG;
	double MIN_RATE_SWAP;
	double MAX_RATE_SWAP;
	int YEARS;
	int SWAP_PERIODS;
	float RATE_VARIANCE;
	float STARTING_PRICE;
	long FIRST_YEAR;
	long SWAP_START;

	//asset parameters
	float VARIANCE;
	float DISCOUNT;

	//batch parameters
	long iMAX_CP_GROUP;
	long CP_BATCHES;
	long CP_PER_BATCH;
};

//get parameters from external file (if they exist) or defaults
paramStruct initParameters(string paramFile="sample_parameters2.txt");

//holds properties/parameters for use in host
const paramStruct parh=initParameters();

const int SWAP_PERIODS=12*5;

////internal parameters
//max counterparties processed per batch
//const long iMAX_CP_GROUP=5000;

//const long CP_BATCHES=PARTIES_NUM/iMAX_CP_GROUP+bool(PARTIES_NUM%iMAX_CP_GROUP);
//const long CP_PER_BATCH=PARTIES_NUM/CP_BATCHES;

const long MAX_PERIODS=60;

const long iMAX_CP_GROUP=500;

const long CP_BATCHES=PARTIES_NUM/iMAX_CP_GROUP+bool(PARTIES_NUM%iMAX_CP_GROUP);
const long CP_PER_BATCH=PARTIES_NUM/CP_BATCHES;

#endif /* PARAMETERS_H_ */
