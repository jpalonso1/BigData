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
const long CASH_DEALS_NUM = 100000;
const long MIN_DEAL_CASH = 800000;
const long MAX_DEAL_CASH = 1200000;
const float PERCENT_CASH_LONG = 0.6;

//swap parameters
const long SWAP_DEALS_NUM=250000;
const long MIN_DEAL_SWAP = 800000;
const long MAX_DEAL_SWAP = 1200000;
const float PERCENT_SWAP_LONG = 0.45;
const double MIN_RATE_SWAP = 0.02;
const double MAX_RATE_SWAP = 0.08;
const int YEARS=5;
const int SWAP_PERIODS=12*YEARS;
const float RATE_VARIANCE=0.2;
const float STARTING_PRICE = 1.4;
const int FIRST_YEAR=2;
const int SWAP_START=FIRST_YEAR*12;

//asset parameters
const float VARIANCE=0.2;
const float DISCOUNT=0.06;

//simulation parameters
const long NUM_SIMULATIONS = 10000;

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
};

//get parameters from external file (if they exist) or defaults
paramStruct initParameters(string paramFile="sample_parameters2.txt");

//holds properties/parameters for use in host
const paramStruct parh=initParameters();



////internal parameters
//max counterparties processed per batch
const long iMAX_CP_GROUP=5000;

const long CP_BATCHES=PARTIES_NUM/iMAX_CP_GROUP+bool(PARTIES_NUM%iMAX_CP_GROUP);
const long CP_PER_BATCH=PARTIES_NUM/CP_BATCHES;


#endif /* PARAMETERS_H_ */
