XTOOLSDIR= ../xtools

INCLUDES=-I. -I$(XTOOLSDIR)

#set up compiler and options
CXX = nvcc
CXXFLAGS = $(INCLUDES) 

SRC=mainhw1.cpp ../xtools/xfun.cpp ../xtools/xlog.cpp

EXEC=scrub

$(EXEC):
	$(CXX) -o $@ $(SRC) $(CXXFLAGS)
        
clean:
	rm -f $(EXEC)
