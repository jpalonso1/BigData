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
	float normalizedCashCVA[5];
	float normalizedSwapFloatCVA[5][SWAP_PERIODS];
	float normalizedSwapFixedCVA[5][SWAP_PERIODS];
	//intialize counterparties and set to 0
	__host__ __device__
	counterpartyCVA()
	{
		for (int i=0;i<5;i++){
			normalizedCashCVA[i]=0;
			for (int j=0;j<SWAP_PERIODS;j++){
				normalizedSwapFloatCVA[i][j]=0;
				normalizedSwapFixedCVA[i][j]=0;
			}
		}
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
		saveCP(cp,"testBin",iMAX_CP_GROUP);
		logAlloc.log("Output file");

		logAlloc.end();

		printCPDetails(cp[7]);
	}
	logMain.end();
	return 0;
}


