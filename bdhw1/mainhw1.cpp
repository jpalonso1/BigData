//Juan Pablo Alonso

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <string>
#include <ctime>
#include <time.h>
#include <sys/time.h>
#include "xlog.h"
#include <thrust/device_vector.h>

const long DUPLICATE_ARRAY_SIZE=60;
const long GROUP_STRING_SIZE=1000;
const long NUM_GROUPS=10000;

using namespace std;

__host__ __device__
inline bool findPriceVolNoise(const string &lineChecked)
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

__host__ __device__
inline bool findDatetimeNoise(const string &lineChecked){
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

struct group_strings{
	string line[GROUP_STRING_SIZE];
};

struct group_bool{
	bool lineCheck[GROUP_STRING_SIZE];
	__host__ __device__
	group_bool()
	{
		for (long i=0;i<GROUP_STRING_SIZE;i++){lineCheck[i]=false;}
	}
};

struct find_noise
{
    __host__ __device__
    group_bool operator()(const group_strings& gs, const group_bool& gb) const {
			group_bool output_group_bool;
//			//loop through each element of comparison array and check for match
			for (long i=0;i<GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE;i++)
			{
				if (findDatetimeNoise(string(gs.line[i]))){output_group_bool.lineCheck[i]=true;}
				else if (findPriceVolNoise(string(gs.line[i]))){output_group_bool.lineCheck[i]=true;}
				else
				{
					//check for duplicates
					for (long j=0;j<DUPLICATE_ARRAY_SIZE;j++)
					{
						if(gs.line[i].compare(gs.line[i+j+1])==0)
						{
							output_group_bool.lineCheck[i]=true;
							break;
						}
					}
				}
			}
//			output_group_bool.lineCheck[5]=true;output_group_bool.lineCheck[7]=true;
			return output_group_bool;
		}
};


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
	//tracks the last line
	string lineChecked;

	ofstream signal("signal.txt");
	ofstream noise("noise.txt");
	//check that the entire file has been processed
	while(!input.eof())
	{
		XLog logClean("Find Noise");
		group_strings tempGroup;
		thrust::host_vector<group_strings> Hstr(NUM_GROUPS);
		thrust::host_vector<group_bool> Hbool(NUM_GROUPS);
		long structsCount=0;
		long instr=0;

		//start reading the file while within vector capacity
		while (structsCount<NUM_GROUPS)
		{
			getline(input,lineChecked);
			tempGroup.line[instr]=lineChecked;
			instr++;
			if (instr==GROUP_STRING_SIZE || input.eof()){
				Hstr[structsCount]=tempGroup;
				//create overlap of DUPLICATE_ARRAY_SIZE in case dupes are on the edge
				for (long i=0;i<DUPLICATE_ARRAY_SIZE;i++)
				{
					tempGroup.line[i]=tempGroup.line[GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE+i];
				}
				if (!input.eof()){
					instr=DUPLICATE_ARRAY_SIZE;
				}
				else break;
				structsCount++;
			}
		}

//		thrust::device_vector<string> D = H;
		thrust::transform(Hstr.begin(), Hstr.begin()+structsCount-1, Hbool.begin(), Hbool.begin(), find_noise());

		group_strings gsOut;
		group_bool gbOut;
		//copy to noise and signal files
		for (long i=0;i<structsCount-1;i++)
		{
			gsOut=Hstr[i];
			gbOut=Hbool[i];
			//ignore overlapping section (-DUPLICATE_ARRAY_SIZE)
			for (long j=0;j<GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE;j++)
			{
				if (gbOut.lineCheck[j]==true)noise<<gsOut.line[j]<<'\n';
				else signal<<gsOut.line[j]<<'\n';
			}
		}

		//process "leftover" strings
		gsOut=Hstr[structsCount-1];
		gbOut=Hbool[structsCount-1];
		for (long j=0;j<instr-1;j++)
		{
			if (gbOut.lineCheck[j]==true)noise<<gsOut.line[j]<<'\n';
			else signal<<gsOut.line[j]<<'\n';
		}

		//quick check of values
		group_strings gsTest=Hstr[4];
		group_bool gbTest=Hbool[4];
		cout<<gbTest.lineCheck[7]<<" "<<gsTest.line[7]<<endl;;

		//get total noise found (optional)
		long sum=0;
		group_bool gbSum;
		for(long i=0;i<structsCount;i++)
		{
			gbSum=Hbool[i];
			for (long j=0;j<GROUP_STRING_SIZE;j++)
			{
				sum+=gbSum.lineCheck[j];
			}
		}
		cout<<"duplicates sum: "<<sum<<endl;
	}


//	logClean.log("total lines read:",lineCount);
//	logClean.log("noise found:",noiseCount);

	return 0;
}


