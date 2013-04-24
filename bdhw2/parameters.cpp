#include "parameters.h"

//const long DEALS_NUM = 500000;
//const long PARTIES_NUM = 10000;
//const long MIN_DEAL = 800000;
//const long MAX_DEAL = 1200000;
//const long NUM_SIMULATIONS = 10000;
//const long NUM_TIMESTEPS =1000;
//
//const float PERCENT_LONG = 0.6;
//const float STARTING_PRICE = 1.4;
//const float BASE_HAZARD=0.02;
//const float VARIANCE=0.2;
//const float DISCOUNT=0.06;
//const float YEARS = 5;


paramStruct initParameters(){
	paramStruct tempPar;
	tempPar.DEALS_NUM= param.getLong("DEALS_NUM",100000000);
	tempPar.PARTIES_NUM= param.getLong("PARTIES_NUM",10000);
	tempPar.MIN_DEAL= param.getLong("MIN_DEAL",800000);
	tempPar.MAX_DEAL= param.getLong("MAX_DEAL",1200000);
	tempPar.NUM_SIMULATIONS= param.getLong("NUM_SIMULATIONS",10000);
	tempPar.NUM_TIMESTEPS= param.getLong("NUM_TIMESTEPS",1000);

	tempPar.PERCENT_LONG= param.getFloat("PERCENT_LONG",0.6);
	tempPar.STARTING_PRICE= param.getFloat("STARTING_PRICE",1.4);
	tempPar.BASE_HAZARD= param.getFloat("BASE_HAZARD",0.02);
	tempPar.VARIANCE= param.getFloat("VARIANCE",0.2);
	tempPar.DISCOUNT= param.getFloat("DISCOUNT",0.06);
	tempPar.YEARS= param.getFloat("YEARS",5);

	return tempPar;
}


