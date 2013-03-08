#ifndef XLOG_H_
#define XLOG_H_

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>

class XLogBuf : public std::stringbuf {
private:
	//output file
	std::string logName;
	std::ostream* logFile;
public:
	XLogBuf(const std::string& logName,std::ostream* logFile);
	~XLogBuf() {  pubsync(); }
	int sync();
};

class XLog : public std::ostream {
private:

public:
	XLog(const std::string& logName,std::ostream* logFile) : std::ostream(new XLogBuf(logName,logFile)) {}
    ~XLog() {delete rdbuf(); }
};

#endif /* XLOG_H_ */
