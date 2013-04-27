XTOOLSDIR= ../xtools

INCLUDES=-I. -I$(XTOOLSDIR)

#set up compiler and options
CXX = g++
CXXFLAGS = $(INCLUDES) -pthread -lmongoclient -lboost_thread-mt -lboost_filesystem -lboost_program_options -lboost_system 

SRC=mainhw3.cpp ../xtools/xlog.cpp

EXEC=scrub2

$(EXEC):
	$(CXX) -o $@ $(SRC) $(CXXFLAGS)
        
clean:
	rm -f $(EXEC)
