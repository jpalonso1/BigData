#ifndef PARAMETERS_H_
#define PARAMETERS_H_

#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <cmath>

#include "xparams.h"

const float PI=3.14159265359;

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
	float YEARS;
	long SWAP_PERIODS;
	float RATE_VARIANCE;
	float STARTING_PRICE;
	long FIRST_YEAR;
	long SWAP_START;

	//asset parameters
	float VARIANCE;
	float DISCOUNT;

	//batch parameters
	long CP_BATCHES;
};

//get parameters from external file (if they exist) or defaults
paramStruct initParameters(string paramFile="sample_parameters2.txt");

//holds properties/parameters for use in host
const paramStruct parh=initParameters();

////internal parameters
//max counterparties processed per batch
//const long iMAX_CP_GROUP=5000;

//const long CP_BATCHES=PARTIES_NUM/iMAX_CP_GROUP+bool(PARTIES_NUM%iMAX_CP_GROUP);
//const long CP_PER_BATCH=PARTIES_NUM/CP_BATCHES;

const long MAX_PERIODS=60;

const long iMAX_CP_GROUP=500;

//const long CP_BATCHES=PARTIES_NUM/iMAX_CP_GROUP+bool(PARTIES_NUM%iMAX_CP_GROUP);
//const long CP_PER_BATCH=PARTIES_NUM/CP_BATCHES;

#endif /* PARAMETERS_H_ */
