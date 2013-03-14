#include "xlog.h"

void XLog::log(char* input) {
	std::cout << std::fixed;
	std::cout<<std::setprecision(3);
	std::cout<<"Seconds: "<<getTimeDiff()<<" "<<logName<<" || "<<input<<std::endl;
}

double XLog::getTimeDiff() {
//    time_t     now = time(0);
//    struct tm  tstruct;
//    tstruct = *localtime(&now);

	struct timeval tim;
	gettimeofday(&tim,NULL);
	double difference=(tim.tv_sec+double(tim.tv_usec)/1000000.0)-timeStart;
	return difference;
}

XLog::~XLog(){
	log("end");
}
XLog::XLog(const std::string& _logName):logName(_logName){
	//get starting time
	struct timeval tim;
	gettimeofday(&tim,NULL);
	timeStart=tim.tv_sec+double(tim.tv_usec)/1000000.0;

	log("start");
}
