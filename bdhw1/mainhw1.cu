//Juan Pablo Alonso

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <string>
#include <ctime>
#include <time.h>
#include <sys/time.h>
#include "xlog.h"
#include <cstring>
#include <thrust/device_vector.h>

const long DUPLICATE_ARRAY_SIZE=60;
const long GROUP_STRING_SIZE=1000;
const long NUM_GROUPS=10000;
const long MAX_LINE_LENGTH=50;

using namespace std;

__host__ __device__
inline bool findPriceVolNoise(const char* lineChecked)
{
	/* Looks for specific noise in the price or volume
	 */
	//parse the line being tested
//	cout<<"line checked: "<<lineChecked<<endl;
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

__host__ __device__
inline bool findDatetimeNoise(const char* lineChecked){
	/* Looks for specific noise in the date or time
	 */
	//look for weekend date
	if (lineChecked[7]=='2'){
//		cout<<"date noise 2: "<<lineChecked<<endl;
		return true;
	}
	//look for 9 am record
	if (lineChecked[10]=='9')return true;
	//look for 17 pm record
	if (lineChecked[9]=='1'&&lineChecked[10]=='7')return true;

	//no noise found
	return false;
}

struct group_lines{
	char line[GROUP_STRING_SIZE][MAX_LINE_LENGTH];
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
    group_bool operator()(const group_lines& gs, const group_bool& gb) const {
		group_bool output_group_bool;
		//loop through each element of comparison array and check for match
		for (long i=0;i<GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE;i++)
		{
//			if(1==2)break;
			if (gs.line[i][0]=='x')break;
			else if (findPriceVolNoise(gs.line[i]))output_group_bool.lineCheck[i]=true;
			else if(findDatetimeNoise(gs.line[i]))output_group_bool.lineCheck[i]=true;
			else
			{
				bool singleDupeFound;
				//check for duplicates
				for (long j=0;j<DUPLICATE_ARRAY_SIZE;j++)
				{
					int lineCheck=i+j+1;
					singleDupeFound=true;
					//compare line i with line i+j+1
					for (int j=MAX_LINE_LENGTH-10;j>=0;j--)
					{
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
		}
		return output_group_bool;
	}
};

inline void customGetLine(group_lines& inGroup,ifstream& inStream, long& count){
	int i=0;
	char tempChar='x';
	while (1==1){
		tempChar=inStream.get();
		if (tempChar=='\n'){
			inGroup.line[count][i]='\0';
			break;
		}
		inGroup.line[count][i]=tempChar;
		i++;
		if (i==MAX_LINE_LENGTH-1)return;
	}
}

inline void customCopyChar(group_lines& cpyGroup,group_lines& pstGroup,long& cpyCount,long& pstCount){
	for (int i=0;i<MAX_LINE_LENGTH;i++){
		cpyGroup.line[pstCount][i]=cpyGroup.line[cpyCount][i];
	}
}

int main(int argc,char* argv[]){
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
	//check that the entire file has been processed
	XLog logClean("Find Noise");
	thrust::host_vector<group_bool> Hbool(NUM_GROUPS);
	thrust::host_vector<group_lines> Hline (NUM_GROUPS);
	long sectionProcessed=0;

	while(!input.eof())
	{
		long structsCount=0;
		long instr=0;
		long cpystr=0;
		//tracks the last line
		string lineChecked;
		//hold object being copied
		group_lines tempGroup[2];
		//switches between first and second temp group
		bool fg=false;
		XLog logRead("Read Data");
		//start reading the file while within vector capacity

		while (structsCount<NUM_GROUPS && !input.eof())
		{
			getline(input,lineChecked);
			lineChecked.copy(tempGroup[fg].line[instr],MAX_LINE_LENGTH);
//			lineChecked.copy(Hline[structsCount].line[instr],MAX_LINE_LENGTH);
//			customGetLine(Hline[structsCount],input,instr);
//			lineChecked=Hline[structsCount].line[instr];

			if(instr>(GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE-1))
			{
				//copy line within duplicate range to first lines in next group
				cpystr=instr-GROUP_STRING_SIZE+DUPLICATE_ARRAY_SIZE;
				lineChecked.copy(tempGroup[!fg].
						line[instr-GROUP_STRING_SIZE+DUPLICATE_ARRAY_SIZE],MAX_LINE_LENGTH);
//				lineChecked.copy(Hline[structsCount+1].
//						line[instr-GROUP_STRING_SIZE+DUPLICATE_ARRAY_SIZE],MAX_LINE_LENGTH);
//				customCopyChar(Hline[structsCount],Hline[structsCount+1],
//						instr,cpystr);
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
				for (int i=instr+1;i<GROUP_STRING_SIZE;i++){
					tempGroup[fg].line[i][0]='x';
				}
//				Hline[structsCount]=tempGroup[fg];
				structsCount++;
				break;
			}
			instr++;
		}
		logRead.end();

		cout<<"Z"<<Hline[0].line[1]<<endl;
		cout<<"X"<<Hline[0].line[GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE]<<endl;
		cout<<"X"<<Hline[0].line[GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE+1]<<endl;
		cout<<"Y"<<Hline[1].line[0]<<endl;
		cout<<"Y"<<Hline[1].line[1]<<endl;

		XLog logCopy("Copy");
		thrust::device_vector<group_bool> Dbool(Hbool);
		thrust::device_vector<group_lines> Dline(Hline);
		logCopy.end();

		XLog logTransform("Transform");
		thrust::transform(Dline.begin(), Dline.begin()+structsCount-1, Dbool.begin(), Dbool.begin(), find_noise());
		logTransform.end();

		XLog logBoolCopy("Copy bool");
		Hbool=Dbool;
		logBoolCopy.end();
		XLog logOutput("output to file");
		//copy to noise and signal files
		for (long i=0;i<structsCount-1;i++)
		{
			//ignore overlapping section (-DUPLICATE_ARRAY_SIZE)
			for (long j=0;j<GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE;j++)
			{
				if (Hbool[i].lineCheck[j]==true)noise<<Hline[i].line[j]<<'\n';
				else signal<<Hline[i].line[j]<<'\n';
			}
		}

		logOutput.end();
		//process "leftover" strings
		for (long j=0;j<instr;j++)
		{
			if (Hbool[structsCount-1].lineCheck[j]==true)noise<<Hline[structsCount-1].line[j]<<'\n';
			else signal<<Hline[structsCount-1].line[j]<<'\n';
		}
//		gsOut=Hstr[structsCount-1];
//		gbOut=Hbool[structsCount-1];
//		for (long j=0;j<instr-1;j++)
//		{
//			if (gbOut.lineCheck[j]==true)noise<<gsOut.line[j]<<'\n';
//			else signal<<gsOut.line[j]<<'\n';
//		}
//
//		//quick check of values
//		group_values gsTest=Hstr[4];
//		group_bool gbTest=Hbool[4];
//		cout<<gbTest.lineCheck[7]<<" "<<gsTest.line[7]<<endl;;
//
		//get total noise found (optional)
		long sum=0;
		for(long i=0;i<structsCount+1;i++)
		{
			for (long j=0;j<GROUP_STRING_SIZE;j++)
			{
				sum+=Hbool[i].lineCheck[j];
			}
		}

		sectionProcessed++;
		long linesProcessed=sectionProcessed*(GROUP_STRING_SIZE-DUPLICATE_ARRAY_SIZE)*NUM_GROUPS;
		logClean.log("Processed lines up to: ",linesProcessed);
		logClean.log("noise found:",sum);
	}
	logClean.end();
	return 0;
}


