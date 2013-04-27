XTOOLSDIR= ../xtools

INCLUDES=-I. -I$(XTOOLSDIR)

#set up compiler and options
CXX = nvcc
CXXFLAGS = $(INCLUDES) 

SRC=mainhw2.cu parameters.cu ../xtools/xparams.cpp ../xtools/xfun.cpp ../xtools/xlog.cpp setup.cu

EXEC=cva

$(EXEC):
	$(CXX) -o $@ $(SRC) $(CXXFLAGS)
        
clean:
	rm -f $(EXEC)
