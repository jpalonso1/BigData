//Juan Pablo Alonso

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <string>
#include <ctime>
#include <time.h>
#include <sys/time.h>
#include "xlog.h"

const long int testCount=60;

using namespace std;
bool findDuplicate(string& lineChecked,string *line);
bool findDatetimeNoise(string &lineChecked);
bool findPriceVolNoise(string &lineChecked);

int main(int argc,char* argv[]){
	//start log
	XLog logMain("Scrub Main");

	//check for file name
	if (argc<2)
	{
		cout<<"NO FILENAME PROVIDED";
		return 0;
	}

	//ready objects for input-output
	ifstream input(argv[1]);
	ofstream signal("signal.txt");
	ofstream noise("noise.txt");

	XLog logSec("After initializing files");
//	//tracks the last line
//	string lineChecked;

	//keeps track of the number of individual events found
	long lineCount=0;
	long noiseCount=0;

	//defines which element of the line array will be overwritten next
	int lastArrayCheck=0;
	//noise<<lineChecked;
	char c[10000];
	while (!input.eof())
	{
		input.read(c,10000);
		noise<<c;
	}
	//	while (!input.eof())
//	{
//		getline(input,lineChecked);
//		lineCount++;
//		noise<<lineChecked<<'\n';
//	}
	clock_t timeEnd=clock();
	cout<<endl<<"Total Runtime (see README.txt): "<<double(timeEnd)/double(CLOCKS_PER_SEC)<<" seconds";
	return 0;
}
