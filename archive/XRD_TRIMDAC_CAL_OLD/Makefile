CC = gcc
#EPICSDIR = /usr/local/epics
EPICSDIR = /opt/epics
BASEDIR = $(EPICSDIR)/base
EXTENDIR = $(EPICSDIR)/extensions
EZCAINCDIR = -I$(EXTENDIR)/include
EPICSINCDIR = -I$(BASEDIR)/include -I$(BASEDIR)/include/os/Linux
INCLUDEDIRS = $(EZCAINCDIR) $(EPICSINCDIR)
#EZCALIBDIR = $(EXTENDIR)/lib/linux-x86_64
EZCALIBDIR = $(EXTENDIR)/lib/linux-x86
EZCALIB = -lezca
#CALIBDIR = $(BASEDIR)/lib/linux-x86_64
CALIBDIR = $(BASEDIR)/lib/linux-x86
CALIBS = -lca -lCom
GRACELIBDIR = /usr/local/grace/lib
GRACELIB = -lgrace_np
LIBDIRS = -L$(CALIBDIR) -L$(EZCALIBDIR)
LIBS = $(EZCALIB) $(CALIBS) -lminpack
CFLAGS = -c -fPIC

libfit.so: testfit.o
	$(CC) -shared -o libfit.so testfit.o $(LIBDIRS) $(LIBS)
clean:
	rm -f *.o libfit.so
.c.o: $*.c
	$(CC) $(CFLAGS) $(INCLUDEDIRS) $*.c



