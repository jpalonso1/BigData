#include "XLog.h"

XLogBuf::XLogBuf(const std::string& logName,std::ostream* logFile) : logName(logName),logFile(logFile){
	//this->logFile=logFile;
}

int XLogBuf::sync(){
	*logFile <<logName<< ": "  << str()<<std::endl; str("");
	return !std::cout;
}
