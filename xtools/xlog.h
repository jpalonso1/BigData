#ifndef XLOG_H_
#define XLOG_H_

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <sys/time.h>
#include <stdio.h>
#include <iomanip>

class XLog {
private:
	std::string logName;
	std::ostream* logFile;
	double timeStart;
	double getTimeDiff();
public:
	void log(char*input);
	template <class T>
	void log(char* input,T inputT);
	XLog(const std::string& _logName);
    ~XLog();
};

template<class T>
void XLog::log(char* input, T inputT) {
	std::cout << std::fixed;
	std::cout<<std::setprecision(3);
	std::cout<<"Seconds: "<<getTimeDiff();
	std::cout << std::scientific;
	std::cout<<" "<<logName<<" || "<<input<<" "<<inputT<<std::endl;

}

#endif /* XLOG_H_ */
