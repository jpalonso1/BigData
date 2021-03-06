//Juan Pablo Alonso

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <string>
#include <cstring>
#include <thrust/device_vector.h>

#include "xlog.h"

const long DUPLICATE_ARRAY_SIZE=60;
const long GROUP_STRING_SIZE=2000;
const long NUM_GROUPS=10000;
const long MAX_LINE_LENGTH=50;

using namespace std;

struct group_lines{
	//DES: Groups lines of characters for easier processing with thrust
	char line[GROUP_STRING_SIZE][MAX_LINE_LENGTH];
};

struct group_bool{
	//DES: Groups boolean check for noise for easier processing with thrust
	bool lineCheck[GROUP_STRING_SIZE];
	__host__ __device__
	group_bool()
	{
		for (long i=0;i<GROUP_STRING_SIZE;i++){lineCheck[i]=false;}
	}
};

long readData(thrust::host_vector<group_lines>& Hline,ifstream& input);
bool findPriceVolNoise(const char* lineChecked);
bool findDatetimeNoise(const char* lineChecked);

struct find_noise
{
	ofstream& signal;
	ofstream& noise;
	find_noise(ofstream& _signal,ofstream& _noise):signal(_signal),noise(_noise){}

    __host__
    group_bool operator()(const group_lines& gs, const group_bool& gb) const {
		group_bool output_group_bool;
		//DES: separate noise from signal and output to file
		//IN: custume structs that hold lines and noise flag check
		//OUT: updated boolean struct with flags identifying noise
		//loop through each element of comparison array and check for match
		for (long i=0;i<GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE;i++){
			if (gs.line[i][0]=='x')break;
			else if (findPriceVolNoise(gs.line[i]))output_group_bool.lineCheck[i]=true;
			else if(findDatetimeNoise(gs.line[i]))output_group_bool.lineCheck[i]=true;
			else{
				bool singleDupeFound;
				//check for duplicates
				for (long j=0;j<DUPLICATE_ARRAY_SIZE;j++){
					int lineCheck=i+j+1;
					singleDupeFound=true;
					//compare line i with line i+j+1
					for (int j=MAX_LINE_LENGTH-10;j>=0;j--){
						//check each character
						if(gs.line[i][j]!=gs.line[lineCheck][j]){
							singleDupeFound=false;
							break;
						}
					}
					if (singleDupeFound==true){
						output_group_bool.lineCheck[i]=true;
						break;
					}
				}
			}
			//output to file
			if (output_group_bool.lineCheck[i])noise<<gs.line[i]<<'\n';
			else signal<<gs.line[i]<<'\n';
		}
		return output_group_bool;
	}
};

int main(int argc,char* argv[]){
	//check for file name
	if (argc<2){
		cout<<"NO FILENAME PROVIDED";
		return 0;
	}
	//ready objects for input-output
	ifstream input(argv[1]);
	ofstream signal;
	ofstream noise;
	signal.open("signal.txt");
	noise.open("noise.txt");

	//time and log the clean/output process
	XLog logClean("Scrub");
	logClean.start();

	long sectionProcessed=0;
	//holds groups of strings and lines to be processed with thrust
	thrust::host_vector<group_bool> Hbool(NUM_GROUPS);
	thrust::host_vector<group_lines> Hline (NUM_GROUPS);

	//check that the entire file has been processed
	while(!input.eof()){
		XLog logBatch("Processing Batch");
		logBatch.log("Current batch: ",sectionProcessed+1);
		XLog logRead("Read Data");
		//read data and store in hline vector
		long structsCount=readData(Hline,input);
		logRead.end();

		XLog logTransform("Transform and Output");
		//separate into noise and signal and send to output files
		thrust::transform(Hline.begin(), Hline.begin()+structsCount,
				Hbool.begin(), Hbool.begin(), find_noise(signal,noise));
		logTransform.end();

		sectionProcessed++;
		long linesProcessed=sectionProcessed*(GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE)*NUM_GROUPS;
		logBatch.log("Processed lines up to: ",linesProcessed);
	}
	logClean.end();
	return 0;
}

long readData(thrust::host_vector<group_lines>& Hline,ifstream& input){
	//DES: extract data from stream to lines vector
	//IN: vector of lines structure, input filestream
	//OUT: total of lines structure objects filled

	//tracks the last line
	string lineChecked;
	//hold object being copied
	group_lines tempGroup[2];
	//switches between first and second temp group
	bool fg=false;
	long structsCount=0;
	long instr=0;
	long cpystr=0;
	size_t len=0;
	//start reading the file while within vector capacity
	while (structsCount<NUM_GROUPS){
		getline(input,lineChecked);
		len=lineChecked.copy(tempGroup[fg].line[instr],MAX_LINE_LENGTH);
		tempGroup[fg].line[instr][len]='\0';
		if(instr>(GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE-1)){
			//copy line within duplicate range to first lines in next group
			cpystr=instr-GROUP_STRING_SIZE+DUPLICATE_ARRAY_SIZE;
			lineChecked.copy(tempGroup[!fg].line[cpystr],MAX_LINE_LENGTH);

			//reset values to start new group
			if (instr==(GROUP_STRING_SIZE-1)){
				Hline[structsCount]=tempGroup[fg];
				fg=!fg;
				structsCount++;
				instr=DUPLICATE_ARRAY_SIZE-1;
				if (input.eof())break;
			}
		}
		//copy leftover struct and flag remainder
		if (input.eof()){
			for (int i=instr;i<GROUP_STRING_SIZE;i++){
				tempGroup[fg].line[i][0]='x';
			}
			Hline[structsCount]=tempGroup[fg];
			structsCount++;
			break;
		}
		//move to next line
		instr++;
	}
	return structsCount;
}

__host__
bool findPriceVolNoise(const char* lineChecked)
{
	//DES: Looks for specific noise in the price or volume
	//IN: Current line being tested
	//OUT: true if noise, false otherwise
	//parse the line being tested
	bool firstComma=false;
	for (int i=23;i<GROUP_STRING_SIZE;i++){
		if (lineChecked[i]==','){
			//value is being tested after first comma
			if (firstComma==false){
				firstComma=true;
				//check excessive prices positive or negative
				if (lineChecked[i+1]=='-'){
					if (lineChecked[i+2]!='0')return true;
				}
				else if(lineChecked[i+1]!='0'){
					return true;
				}
				i=i+7;
			}
			//negative volume tested after second comma
			else if (firstComma==true){
				if (lineChecked[i+1]=='-')return true;
				else return false;
			}
		}
	}
	//no noise found
	return false;
}

__host__
bool findDatetimeNoise(const char* lineChecked){
	//DES: Looks for specific noise in the date or time
	//IN: Current line being tested
	//OUT: true if noise, false otherwise
	//look for weekend date
	if (lineChecked[7]=='2')return true;
	//look for 9 am record
	if (lineChecked[10]=='9')return true;
	//look for 17 pm record
	if (lineChecked[9]=='1'&&lineChecked[10]=='7')return true;

	//no noise found
	return false;
}


