#include "parameters.h"

paramStruct initParameters(string paramFile){
	//holds the changes from the external parameter file
	const XParams param(paramFile.c_str());

	paramStruct tempPar;
	//choose between external parameter from file if it exists, default otherwise
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


