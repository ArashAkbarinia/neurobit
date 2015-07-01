#
# choose between intel compiler and gcc 
# 
CC = gcc-4.1
CFLAGS=-O3 -ffast-math -fomit-frame-pointer -fPIC -mtune=k8 -march=k8

#CC=icc
#CFLAGS= -xP -fast -DCOMPILE_WITH_ICC -DKMEANS_VERBOSE

VERBOSEFLAG=-DKMEANS_VERBOSE

MATLABDIR=/usr/local/MATLAB/R2013a

TARGETS=mex_histc
LIBS=-lm -lmex
INCLUDES=-I$(MATLABDIR)/extern/include

# 32 bit version
#SUFFIX=mexglx
#LDIRS=-L$(MATLABDIR)/bin/glnx86 

# 64 bit version
SUFFIX=mexa64
LDIRS=-L$(MATLABDIR)/bin/glnxa64

all: $(TARGETS:%=%.$(SUFFIX))

%.o:	%.c
	$(CC) $(CFLAGS) $(INCLUDES) $(VERBOSEFLAG) -c -o $@.o $*.c

mex_histc.$(SUFFIX): histnd.o mex_histc.o
	$(CC) mex_histc.o $(LDIRS) $(LIBS) -shared -o mex_histc.$(SUFFIX) histnd.o

### Targets

clean:	
	rm -f *.mexglx *.mexa64 *.o *~ *.so
