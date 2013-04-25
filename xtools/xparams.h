#ifndef XPARAMS_H_
#define XPARAMS_H_

#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <typeinfo>
#include <cstdlib>
#include <algorithm>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

using namespace std;

class XParams {
public:
	XParams(const char* paramPath);
	virtual ~XParams();
	//take a parameter name and a default value as argument
	int getLong(const string par, long def)const;
	float getFloat(const string par, float def)const;
	string getString(const string par, string def)const;

	void printParameters()const{
		for (int i=0;i<name.size();i++){
			cout<<name[i]<<": "<<value[i]<<endl;
		}
	}
private:
	bool seekValue(const string& par, string & out)const;
	fstream logFile;
	vector<string> name;
	vector<string> value;
	void extractParams();
};

#endif /* XPARAMS_H_ */
