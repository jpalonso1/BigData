//Juan Pablo Alonso

#include <cstdlib>
#include <stdio.h>
#include <iostream>
#include <string>
#include <xlog.h>
#include <vector>
#include "mongo/client/dbclient.h"
#include "mongo/bson/bsonobjbuilder.h"

const long BATCH_SIZE=100000;
const long DUPLICATE_ARRAY_SIZE=60;

using namespace std;
using namespace bson;
using namespace mongo;

bool checkDuplicates(string& target,string* compVector);
void parseFile(ifstream& input,DBClientConnection& c);
void outputToFile(DBClientConnection& c);
void scrub(DBClientConnection& c);

int main(int argc,char* argv[]){
	//check for file name
	if (argc<2){
		cout<<"NO FILENAME PROVIDED";
		return 0;
	}
	//create object for input text file
	ifstream input(argv[1]);

	//connect to the mongo db localhost
	DBClientConnection c;
	c.connect("localhost");

	XLog logParse("Parsing...");
	logParse.start();
	parseFile(input,c);
	logParse.end();

	XLog logScrub("Scrubbing...");
	logScrub.start();
	scrub(c);
	logScrub.end();

	XLog logOutput("Output to file...");
	logOutput.start();
	outputToFile(c);
	logOutput.end();

	return 0;
}


bool checkDuplicates(string& target,string* compVector){
	//DES: compare a target string to each string in compVector
	//IN: target string, array of strings
	//OUT: true if duplicate found, false otherwise
	for (int i=0;i<DUPLICATE_ARRAY_SIZE;i++){
		if (compVector[i].compare(target) == 0){
			return true;
		}
	}
	return false;
}

void parseFile(ifstream& input,DBClientConnection& c){
	//DES: parse text file and input into mongo database
	//IN: input text file, mongo db connection

	//clean up database if it already exists
	c.dropDatabase("hw3");
	//hold parsed elements
	string date;
	string value;
	string volume;
	//track row numbers
	long count=0;
	int total=0;
	//holds batch of "documents" to be inserted into database
	vector<BSONObj> bobjp(BATCH_SIZE);
	//holds last DUPLICATE_ARRAY_SIZE elements to be used for duplicate search
	string comparison[DUPLICATE_ARRAY_SIZE];
	int compCount=0;
	bool duplicate;
	int test=0;
	XLog logInsert("Inserting...");

	while(!input.eof()){
		duplicate=false;
		//parse a line
		getline(input,date,',');
		getline(input,value,',');
		getline(input,volume);

		//create "document" to be inserted from parsed information
		BSONObjBuilder b;
		double dValue=atof(value.c_str());
		int iVol=atol(volume.c_str());
		b.append("date", date);
		b.append("value", dValue);
		b.append("volume", iVol);

		//check for duplicates within a window of size DUPLICATE_ARRAY_SIZE
		duplicate=checkDuplicates(date,comparison);
		comparison[compCount]=date;
		compCount++;
		if (compCount>=DUPLICATE_ARRAY_SIZE)compCount=0;


		//create "document" to be inserted into database
		BSONObj p = b.obj();
		//if no duplicates, add to array for batch insertion
		if (duplicate==false){
			bobjp[count]=p;
			total++;
			count++;
		}
		//if it is a duplicate, insert right away into noise collection
		else {
			c.insert("hw3.noise", p);
			test++;
		}

		//insert batch of documents into collection once vector is full
		if (total%BATCH_SIZE==0){
			c.insert("hw3.signal", bobjp);
			count=0;
			if(total%(BATCH_SIZE*10)==0)logInsert.log("Lines inserted so far: ",total);
		}
	}
	//process leftover elements after eof
	for (int i=0;i<count;i++){
		c.insert("hw3.signal", bobjp[i]);
	}
}

void outputToFile(DBClientConnection& c){
	ofstream signal;
	ofstream noise;
	signal.open("signal.txt");
	noise.open("noise.txt");

	auto_ptr<DBClientCursor> noiseCursor =c.query("hw3.noise", Query());
	auto_ptr<DBClientCursor> signalCursor =c.query("hw3.signal", Query());
	//output to file
	while (noiseCursor->more()){
		BSONObj single = noiseCursor->next();
		noise<<single.getStringField("date")<<","<<single.getField("value").Double()
				<<","<<single.getField("volume").Int()<<'\n';
	}
	while (signalCursor->more()){
		BSONObj single = signalCursor->next();
		signal<<single.getStringField("date")<<","<<single.getField("value").Double()
				<<","<<single.getField("volume").Int()<<'\n';
	}

}

void scrub(DBClientConnection& c){
	//DES: finds and moves noise documents found in the database
	//IN: connection to the mongo database

	auto_ptr<DBClientCursor> noiseCursor[6];
	//look for negative volume
	noiseCursor[0] = c.query("hw3.signal", BSON("volume"<<LTE<<0.0));
	//find excessive price (>5 dollars)
	noiseCursor[1] = c.query("hw3.signal", BSON("value"<<GTE<<5.0));
	//find excessive negative price (<-5 dollars)
	noiseCursor[2] = c.query("hw3.signal", BSON("value"<<LTE<<-5.0));
	//find weekend dates
	noiseCursor[3] = c.query("hw3.signal", Query("{date: /[0-9]{7}2./i }"));
	//find 9 am trades
	noiseCursor[4] = c.query("hw3.signal", Query("{date: /[0-9]{8}:09./i }"));
	//find 5 pm trades
	noiseCursor[5] = c.query("hw3.signal", Query("{date: /[0-9]{8}:17./i }"));

	//loop through each noise type and move the errors from the signal collection to the
	//noise collection
	for (int i=0;i<6;i++){
		while (noiseCursor[i]->more()){
			BSONObj singleNoise = noiseCursor[i]->next();
			//add to noise db
			c.insert("hw3.noise", singleNoise);
			//remove from signal db
			c.remove("hw3.signal",singleNoise);
		}
	}
}
