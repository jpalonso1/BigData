#include "xparams.h"

XParams::XParams(const char* paramPath) {
	logFile.open(paramPath);
	extractParams();
}

XParams::~XParams(){
	logFile.close();
}

string XParams::seekValue(const string& par)const {
	for (int i=0;i<name.size();i++)
	{
		if (par.compare(name[i]))return value[i];
	}
	return "";
}

void XParams::extractParams() {
	name.clear();
	value.clear();
	string line;
	while (!logFile.eof())
	{
		getline(logFile,line,'=');
		name.push_back(line);
		getline(logFile,line);
		value.push_back(line);
	}
}


