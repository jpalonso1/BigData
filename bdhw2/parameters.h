#ifndef PARAMETERS_H_
#define PARAMETERS_H_

#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <cmath>

const long DEALS_NUM = 100000000;
const long PARTIES_NUM = 10000;
const long MIN_DEAL = 8000000;
const long MAX_DEAL = 12000000;
const float PERCENT_LONG = 0.6;
const float STARTING_PRICE = 1.4;
const float VARIANCE=0.2;
const float DISCOUNT=0.06;
const long NUM_TIMESTEPS = 1000;
const long NUM_SIMULATIONS = 120;
const float YEARS = 5;
const int PROP_CUTOFF[5] = { 1, 3, 7, 15, 31 };

#endif /* PARAMETERS_H_ */
