XTOOLSDIR= ../xtools

INCLUDES=-I. -I$(XTOOLSDIR)

#set up compiler and options
CXX = nvcc
CXXFLAGS = $(INCLUDES) 

SRC=parameters4.cu mainhw4.cu ../xtools/xparams.cpp ../xtools/xfun.cpp setup4.cu

EXEC=cva2

$(EXEC):
	$(CXX) -o $@ $(SRC) $(CXXFLAGS)
        
clean:
	rm -f $(EXEC)
