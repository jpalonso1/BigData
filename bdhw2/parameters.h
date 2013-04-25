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

const long DEALS_NUM = 100000000;
const long PARTIES_NUM = 10000;
const long MIN_DEAL = 800000;
const long MAX_DEAL = 1200000;
const long NUM_SIMULATIONS = 10000;
const long NUM_TIMESTEPS =1000;

const float PERCENT_LONG = 0.6;
const float STARTING_PRICE = 1.4;
const float BASE_HAZARD=0.02;
const float VARIANCE=0.2;
const float DISCOUNT=0.06;
const float YEARS = 5;

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

const XParams param("paramhw2.txt");

paramStruct initParameters();


#endif /* PARAAMETERS_H_ */
