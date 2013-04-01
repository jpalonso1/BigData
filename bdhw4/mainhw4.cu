#include <string>
#include <vector>

#include "parameters4.h"
#include "setup4.h"
#include "xlog.h"
//x6y

using namespace std;

//holds the normalized simulation results for each type of counterparty
struct counterpartyCVA
{
	float normalizedCVA[5];
	//intialize counterparties and set to 0
	__host__ __device__
	counterpartyCVA()
	{
		for (int i=0;i<5;i++){normalizedCVA[i]=0;}
	}
};

int main(){
	XLog logMain("CVA 2 Main");
	const long cpGroups=iMAX_CP_GROUP/PARTIES_NUM;
	counterParties cp[iMAX_CP_GROUP];
	{
		XLog logAlloc("Setup");
		logAlloc.start();
		setupCounterparties(cp, iMAX_CP_GROUP);
		logAlloc.log("Counterparties creation complete");
		allocateDeals(cp,iMAX_CP_GROUP);
		logAlloc.log("Deal allocation complete");
		string cpFile("counterparties.txt");
//		writeCounterparties(cp,cpFile);
		logAlloc.log("Output file");
		logAlloc.end();
		printCPDetails(cp[7]);
	}
	logMain.end();
	return 0;
}


