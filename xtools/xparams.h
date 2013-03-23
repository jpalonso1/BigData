/*
 * XParams.h
 *
 *  Created on: Mar 8, 2013
 *      Author: jalonso
 */

#ifndef XPARAMS_H_
#define XPARAMS_H_

#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <typeinfo>
#include <cstdlib>

using namespace std;

//const string paramPath("parameters.txt");

class XParams {
public:
	XParams(const char* paramPath);
	virtual ~XParams();
	//take a parameter name and a default value as argument
	//return the file value if found, default otherwise
	int getInt(const string par)const {return atoi(seekValue(par).c_str());}
//	double getDouble(string par)const {return atof(seekValue(par).c_str());}
	float getFloat(const string par)const {return atof(seekValue(par).c_str());}
	string getString(const string par)const {return seekValue(par);}
private:
	string seekValue(const string& par)const;
	fstream logFile;
	vector<string> name;
	vector<string> value;
	void extractParams();
};

#endif /* XPARAMS_H_ */
