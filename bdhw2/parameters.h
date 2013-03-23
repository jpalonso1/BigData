#ifndef PARAMETERS_H_
#define PARAMETERS_H_

#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <cmath>

#include "xparams.h"

const XParams par("paramhw4.txt");

const float PI=3.14159265359;

const long DEALS_NUM = par.getLong("DEALS_NUM",100000000);
const long PARTIES_NUM = par.getLong("PARTIES_NUM ",10000);
const long MIN_DEAL = par.getLong("MIN_DEAL",8000000);
const long MAX_DEAL = par.getLong("MAX_DEAL",12000000);
const long	NUM_TIMESTEPSH= par.getLong("NUM_TIMESTEPS",1000);

const long NUM_SIMULATIONS = par.getLong("NUM_SIMULATIONS",10000);

//const float PERCENT_LONG = par.getFloat("PERCENT_LONG",0.6);
//const float STARTING_PRICE = par.getFloat("STARTING_PRICE",1.4);
//const float BASE_HAZARD=par.getFloat("BASE_HAZARD",0.02);
//const float VARIANCE=par.getFloat("VARIANCE",0.2);
//const float DISCOUNT=par.getFloat("DISCOUNT",0.06);
//const float YEARS = par.getFloat("YEARS",5.0);

//const long DEALS_NUM = 100000000;
//const long PARTIES_NUM = 10000;
//const long MIN_DEAL = 8000000;
//const long MAX_DEAL = 12000000;
//const long NUM_TIMESTEPS = 1000;
//const long NUM_SIMULATIONS = 10000;

const float PERCENT_LONG = 0.6;
const float STARTING_PRICE = 1.4;
const float BASE_HAZARD=0.02;
const float VARIANCE=0.2;
const float DISCOUNT=0.06;
const float YEARS = 5;

const int PROP_CUTOFF[5] = { 1, 3, 7, 15, 31 };

#endif /* PARAMETERS_H_ */
