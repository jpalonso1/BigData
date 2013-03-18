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
	logMain.log("Starting..");
	vector<counterParties> cp(PARTIES_NUM);
	{
		XLog logAlloc("Setup");
		setupCounterparties(cp);
		logAlloc.log("Counterparties creation complete");
		allocateDeals(cp);
		logAlloc.log("Deal allocation complete");
		string cpFile("counterparties.txt");
		writeCounterparties(cp,cpFile);
		logAlloc.log("Output file");
	}
	cout<<"ending..."<<float(clock()) / float(CLOCKS_PER_SEC)<<endl;
	return 0;
}


