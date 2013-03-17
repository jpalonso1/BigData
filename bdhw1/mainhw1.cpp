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
	//tracks the last line
	string lineChecked;
	//moving range (size testCount) of lines to check for duplicates
	string line[testCount];

	//keeps track of the number of individual events found
//	long lineCount=0;
//	long noiseCount=0;

	{
		XLog logClean("Find Noise");
		//set array for duplicate comparisons
		getline(input,lineChecked);
		for (int i=0;i<testCount;i++)
		{
			getline(input,line[i]);
		}
		//reset to start of file
		input.seekg(0);

		//defines which element of the line array will be overwritten next
		int lastArrayCheck=0;
		while (!input.eof())
		{
			getline(input,lineChecked);
	//		lineCount++;
			//look for each type of error
			if (findDuplicate(lineChecked,line))
			{
	//			noiseCount++;
				noise<<lineChecked<<'\n';
			}
			else if (findDatetimeNoise(lineChecked))
			{
	//			noiseCount++;
				noise<<lineChecked<<'\n';
			}
			else if (findPriceVolNoise(lineChecked))
			{
	//			noiseCount++;
				noise<<lineChecked<<'\n';
			}
			else
			{
				signal<<lineChecked<<'\n';
			}
			//update moving array with latest line
			line[lastArrayCheck]=lineChecked;
			//set next element of array to be replaced
			if (lastArrayCheck<testCount-1)lastArrayCheck++;
			else lastArrayCheck=0;
		}
	}
//	logClean.log("total lines read:",lineCount);
//	logClean.log("noise found:",noiseCount);

	return 0;
}

bool findPriceVolNoise(string &lineChecked)
{
	/* Looks for specific noise in the price or volume
	 */
	//parse the line being tested
	short int firstComma,lastComma;
	firstComma=lineChecked.find_first_of(',');
	lastComma=lineChecked.find_last_of(',');
	string priceStr=lineChecked.substr(firstComma+1,lastComma-firstComma-1).c_str();
	double price=atof(priceStr.c_str());
	//look for +5 prices
	if (price>5)return true;
	if (lineChecked[lastComma+1]=='-')return true;

	return false;
}

bool findDatetimeNoise(string &lineChecked){
	/* Looks for specific noise in the date or time
	 */
	//look for weekend date
	if (lineChecked[7]=='2')return true;
	//look for 9 am record
	if (lineChecked[10]=='9')return true;
	//look for 17 pm record
	if (lineChecked[9]=='1'&&lineChecked[10]=='7')return true;

	return false;
}

bool findDuplicate(string& lineChecked,string *line){
	/* Looks for duplicates within a specified window
	 */
	//loop through each element of comparison array and check for match
	for (int i=0;i<testCount;i++)
	{
		if(lineChecked.compare(line[i])==0)
			{
				return true;
			}
	}

	return false;
}
