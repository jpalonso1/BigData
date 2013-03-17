//Juan Pablo Alonso

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <string>
#include <ctime>
#include <time.h>
#include <sys/time.h>
#include "xlog.h"

const long int DUPLICATE_ARRAY_SIZE=60;
const long MAX_LINE_LENGTH=70;

using namespace std;

bool findDuplicate(char** c,char* check);

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

	cout<<"copy complete"<<endl;
	cout<<"tellg: :"<<input.tellg()<<endl;

	XLog logSec("Finding Noise");

	//allocate memory for duplicate comparison array
	char** c;
	c=new char*[DUPLICATE_ARRAY_SIZE];
	for (int i=0;i<DUPLICATE_ARRAY_SIZE;i++)
	{
		c[i]=new char[MAX_LINE_LENGTH];
	}

//	//keeps track of the number of individual events found
//	long lineCount=0;
//	long noiseCount=0;

	//line counter
	int lc=0;
	//char counter
	int cc=0;
	//current char being tested
	char next;
	//fill the duplicates check vector
	while (input.get(next))
	{
		//copy character
		c[lc][cc]=next;
		cc++;
		if (next=='\n')
		{
			c[lc][cc]='\0';
			lc++;
			cc=0;
		}

		//exit when the array has been filled
		if (lc==DUPLICATE_ARRAY_SIZE)break;
	}
	cout<<"testing dupes";
	for (int i=0;i<5;i++){cout<<c[i];}
//
//	//reset to start of file
//	input.seekg(0);

	//tracks the duplicate array line # being tested (for overwriting)
	int chk=0;
	//line being tested
	char *thisLine;
	thisLine=new char[MAX_LINE_LENGTH];
	char *tempChar;
	cc=0;
	long dupeCount=0;
	while (input.get(next))
	{
		thisLine[cc]=next;
		cc++;
		if (next=='\n')
		{
			thisLine[cc]='\0';
			tempChar=thisLine;
			thisLine=c[chk];
			c[chk]=thisLine;
			dupeCount+=findDuplicate(c,thisLine);
			//run duplicate check
			chk++;
			if (chk==DUPLICATE_ARRAY_SIZE)chk=0;

			cc=0;
		}
	}

	clock_t timeEnd=clock();
	cout<<endl<<"Total Runtimeeeeee (see README.txt): "<<double(timeEnd)/double(CLOCKS_PER_SEC)<<" seconds"<<endl;

	cout<<"dupe count: "<<dupeCount;

	//delete character arrays
	for (int i=0;i<DUPLICATE_ARRAY_SIZE;i++)
	{
		delete c[i];
	}
	delete c;
	delete thisLine;

	return 0;
}

bool findDuplicate(char** c,char* check){
	//flags any found difference
	bool difference;
	//loop through each element of comparison array and check for match
	for (int i=0;i<DUPLICATE_ARRAY_SIZE;i++)
	{
//		cout<<check<<" and "<<c[i];
		difference=false;
		for (int j=0;j<MAX_LINE_LENGTH;j++)
		{
			//check for end of line
			if (check[j]=='\n')break;
			if (c[i][j]!=check[j])
			{
//				cout<<c[i][j]<<" match: "<<check[j];
				difference=true;
				break;
			}
		}
		//no difference was found on last line check, exit true
		if (difference==false){
			return true;
			cout<<"not found"<<endl;
		}
	}

	return false;
}
