#include <cstdlib>
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

bool checkDuplicates(string& target,string* compVector){
	for (int i=0;i<DUPLICATE_ARRAY_SIZE;i++){
		if (compVector[i].compare(target) == 0){
			return true;
		}
	}
	return false;
}

void parseFile(ifstream& input,DBClientConnection& c){
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
	XLog logParse("Parsing...");

	while(!input.eof())
	{
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
		//		if (total>DUPLICATE_ARRAY_SIZE)
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
			c.insert("hw3.raw", bobjp);
			count=0;
			if(total%(BATCH_SIZE*10)==0)logParse("Lines inserted so far: ",total);
		}
	}
	//process leftover elements after eof
	for (int i=0;i<count;i++){
		c.insert("hw3.raw", bobjp[i]);
	}
	logParse.end();
	cout<<"DUPLICATES "<<test<<endl;
}

void scrub(DBClientConnection& c){
	//look for negative volume
	auto_ptr<DBClientCursor> negVol = c.query("hw3.raw", BSON("volume"<<LTE<<0.0));
	auto_ptr<DBClientCursor> cursor = c.query("hw3.noise", Query("{volume: {'$lt':0}}"));
//	auto_ptr<DBClientCursor> cursor = c.query("hw3.raw", Query("{\"date\": \"test\",\"$options\":\"i\"}"));
	while (negVol->more()){
		BSONObj singleNoise = negVol->next();
		c.insert("hw3.noise", singleNoise);
//		cout<<singleNoise<<endl;
//		c.remove("hw3.noise",singleNoise);
//		cout << cursor->next().toString() << endl;
	}
	cout<<"pos vol count:"<<cursor->itcount()<<endl;
	cout<<"neg vol count:"<<negVol->itcount()<<endl;
	cout<<"scrub inside end"<<endl;
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

	//connect to the mongo db localhost
	DBClientConnection c;
	c.connect("localhost");
//	parseFile(input,c);

	XLog logScrub("Scrubbing...");
	XLog logDupe("Duplicates");

	logDupe.end();
	scrub(c);
	logScrub.end();

	ifstream signal;
	ifstream noise;
	signal.open("signal.txt");
	noise.open("noise.txt");

  return EXIT_SUCCESS;
}
