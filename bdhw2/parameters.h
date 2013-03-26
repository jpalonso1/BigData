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

const XParams param("paramhw4.txt");

//const long DEALS_NUM = 100000000;
//const long PARTIES_NUM = 10000;
//const long MIN_DEAL = 8000000;
//const long MAX_DEAL = 12000000;
//const long NUM_SIMULATIONS = 10000;


struct parStruct{
	long NUM_TIMESTEPS;
};

void updateParameters(parStruct& par){
	par.NUM_TIMESTEPS=1000;
}
const long NUM_TIMESTEPS = 1000;

//const long NUM_TIMESTEPS= param.getLong("NUM_TIMESTEPS",1000);

const float PERCENT_LONG = 0.6;
const float STARTING_PRICE = 1.4;
const float BASE_HAZARD=0.02;
const float VARIANCE=0.2;
const float DISCOUNT=0.06;
const float YEARS = 5;

const float PI=3.14159265359;

const long DEALS_NUM = param.getLong("DEALS_NUM",100000000);
const long PARTIES_NUM = param.getLong("paramTIES_NUM ",10000);
const long MIN_DEAL = param.getLong("MIN_DEAL",8000000);
const long MAX_DEAL = param.getLong("MAX_DEAL",12000000);
const long NUM_SIMULATIONS= param.getLong("NUM_SIMULATIONS",10000);


//const float PERCENT_LONG = param.getFloat("PERCENT_LONG",0.6);
//const float STARTING_PRICE = param.getFloat("STARTING_PRICE",1.4);
//const float BASE_HAZARD=param.getFloat("BASE_HAZARD",0.02);
//const float VARIANCE=param.getFloat("VARIANCE",0.2);
//const float DISCOUNT=param.getFloat("DISCOUNT",0.06);
//const float YEARS = param.getFloat("YEARS",5.0);


const int PROP_CUTOFF[5] = { 1, 3, 7, 15, 31 };

#endif /* PARAAMETERS_H_ */
