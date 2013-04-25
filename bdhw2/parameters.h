#ifndef PARAMETERS_H_
#define PARAMETERS_H_

#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <cmath>
#include <map>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include "xparams.h"

const int PROP_CUTOFF[5] = { 1, 3, 7, 15, 31 };

struct paramStruct{
	long DEALS_NUM;
	long PARTIES_NUM;
	long MIN_DEAL;
	long MAX_DEAL;
	long NUM_SIMULATIONS;
	long NUM_TIMESTEPS;
	float PERCENT_LONG;
	float STARTING_PRICE;
	float BASE_HAZARD;
	float VARIANCE;
	float DISCOUNT;
	float YEARS;
};

//get parameters from external file (if they exist) or defaults
paramStruct initParameters(string paramFile="sample_parameters.txt");

//holds properties/parameters for use in host
const paramStruct parh=initParameters();

#endif /* PARAAMETERS_H_ */
