#include "parameters4.h"

paramStruct initParameters(string paramFile){
	//holds the changes from the external parameter file
	const XParams param(paramFile.c_str());

	paramStruct tempPar;
	//choose between external parameter from file if it exists, default otherwise
	tempPar.NUM_SIMULATIONS= param.getLong("NUM_SIMULATIONS",700000000);
	tempPar.NS.xBar[0]=param.getFloat("BS00",0.06);
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
	return tempPar;
}
