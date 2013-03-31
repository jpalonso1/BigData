XTOOLSDIR= ../xtools

INCLUDES=-I. -I$(XTOOLSDIR)

#set up compiler and options
CXX = nvcc
CXXFLAGS = $(INCLUDES) -Xcompiler -fopenmp -DTHRUST_DEVICE_BACKEND=THRUST_DEVICE_BACKEND_OMP -lgomp

SRC=mainhw1.cu ../xtools/xlog.cpp

EXEC=scrub

$(EXEC):
	$(CXX) -o $@ $(SRC) $(CXXFLAGS)
        
clean:
	rm -f $(EXEC)
