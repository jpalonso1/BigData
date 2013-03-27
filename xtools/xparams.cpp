#include "xparams.h"

XParams::XParams(const char* paramPath) {
	logFile.open(paramPath);
	extractParams();
}

XParams::~XParams(){
	logFile.close();
}

bool XParams::seekValue(const string& par, string & out)const {
	for (int i=0;i<name.size();i++)
	{
		if (!par.compare(name[i])){
			out=value[i];
			return true;
		}
	}
	//no value found, return empty
	return false;
}

float XParams::getFloat(const string par, float def) const {
	string temp;
	if (seekValue(par,temp))return atof(temp.c_str());
	else return def;
}

string XParams::getString(const string par, string def) const {
	string temp;
	if (seekValue(par,temp))return temp;
	else return def;
}

void XParams::extractParams() {
	name.clear();
	value.clear();
	string line;
	//loop through each line and save before/after equal sign
	while (!logFile.eof())
	{
		getline(logFile,line,'=');
		name.push_back(line);
		getline(logFile,line);
		value.push_back(line);
	}
}
