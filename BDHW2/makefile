XTOOLSDIR= ../XTools

INCLUDES=-I. -I$(XTOOLSDIR)

#set up compiler and options
CXX = g++
CXXFLAGS = -c -Wall $(INCLUDES)
LDFLAGS= 

SRC = mainhw2.cpp ../XTools/XLog.cpp
OBJ=$(SRC:%.cpp=%.o)

EXEC=base

all: $(SRC) $(EXEC)

$(EXEC):$(OBJ)
	$(CXX) $(LDFLAGS) $(OBJ) -o $@ 

.cpp.o:
	$(CXX) $(CXXFLAGS) $< -o $@
        
clean:
	rm -f $(OBJ)
