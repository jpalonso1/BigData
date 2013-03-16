#include "xparams.h"

XParams::XParams(string paramPath) {
	logFile.open(paramPath.c_str());
	extractParams();
}

XParams::~XParams(){
	logFile.close();
}

string XParams::seekValue(string par) {
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


