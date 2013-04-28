#include "parameters4.h"

paramStruct initParameters(string paramFile){
	//holds the changes from the external parameter file
	const XParams param(paramFile.c_str());

	paramStruct tempPar;
	//simulation steps
	tempPar.NUM_SIMULATIONS= param.getLong("NUM_SIMULATIONS",700000000);

	//choose between external parameter from file if it exists, default otherwise
	tempPar.NS.xBar[0]=param.getFloat("BS00",0.60);
	tempPar.NS.xBar[1]=param.getFloat("BS10",0.58);
	tempPar.NS.xBar[2]=param.getFloat("BS20",1.58);
	tempPar.NS.xBar[3]=param.getFloat("BS30",1.40);
	tempPar.NS.alpha[0]=param.getFloat("BS01",0.2);
	tempPar.NS.alpha[1]=param.getFloat("BS11",0.25);
	tempPar.NS.alpha[2]=param.getFloat("BS21",0.10);
	tempPar.NS.alpha[3]=param.getFloat("BS31",0.10);
	tempPar.NS.sd[0]=param.getFloat("BS02",0.1);
	tempPar.NS.sd[1]=param.getFloat("BS12",0.15);
	tempPar.NS.sd[2]=param.getFloat("BS22",0.20);
	tempPar.NS.sd[3]=param.getFloat("BS32",0.50);

	//parties parameters
	tempPar.PARTIES_NUM=param.getLong("PARTIES_NUM",10000);
	tempPar.BASE_HAZARD=param.getFloat("BASE_HAZARD",0.02);

	//cash deals parameters
	tempPar.CASH_DEALS_NUM=param.getLong("CASH_DEALS_NUM",100000000);
	tempPar.MIN_DEAL_CASH=param.getLong("MIN_DEAL_CASH",800000);
	tempPar.MAX_DEAL_CASH=param.getLong("MAX_DEAL_CASH",1200000);
	tempPar.PERCENT_CASH_LONG=param.getFloat("PERCENT_CASH_LONG",0.6);

	//swap parameters
	tempPar.SWAP_DEALS_NUM=param.getLong("SWAP_DEALS_NUM",250000);
	tempPar.MIN_DEAL_SWAP=param.getLong("MIN_DEAL_SWAP",800000);
	tempPar.MAX_DEAL_SWAP=param.getLong("MAX_DEAL_SWAP",1200000);
	tempPar.PERCENT_SWAP_LONG=param.getFloat("PERCENT_SWAP_LONG",0.45);
	tempPar.MIN_RATE_SWAP=param.getFloat("MIN_RATE_SWAP",0.02);
	tempPar.MAX_RATE_SWAP=param.getFloat("MAX_RATE_SWAP",0.08);
	tempPar.YEARS=param.getLong("YEARS",5);

	tempPar.RATE_VARIANCE=param.getFloat("RATE_VARIANCE",0.2);
	tempPar.STARTING_PRICE=param.getFloat("STARTING_PRICE",1.4);
	tempPar.FIRST_YEAR=param.getFloat("FIRST_YEAR",2);
	tempPar.SWAP_START=FIRST_YEAR*12;

	//asset parameters
	tempPar.VARIANCE=param.getFloat("VARIANCE",0.2);
	tempPar.DISCOUNT=param.getFloat("DISCOUNT",0.06);

	//batch parameters
	tempPar.iMAX_CP_GROUP=param.getLong("iMAX_CP_GROUP",100);
	tempPar.CP_BATCHES=tempPar.PARTIES_NUM/tempPar.iMAX_CP_GROUP+
			bool(tempPar.PARTIES_NUM%tempPar.iMAX_CP_GROUP);
	tempPar.CP_PER_BATCH=tempPar.PARTIES_NUM/tempPar.CP_BATCHES;
	return tempPar;
}
