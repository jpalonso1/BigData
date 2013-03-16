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

class XParams {
public:
	XParams(string paramPath);
	virtual ~XParams();
	//take a parameter name and a default value as argument
	//return the file value if found, default otherwise
	void getValue(string par,int& val){val=atoi(seekValue(par).c_str());}
	void getValue(string par,double& val){val=atof(seekValue(par).c_str());}
	void getValue(string par,float& val){val=atof(seekValue(par).c_str());}
	void getValue(string par,string& val){val=seekValue(par);}
private:
	string seekValue(string par);
	fstream logFile;
	vector<string> name;
	vector<string> value;
	void extractParams();
};



#endif /* XPARAMS_H_ */
