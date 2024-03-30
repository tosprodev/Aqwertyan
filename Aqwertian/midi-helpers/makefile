# +mkmake+ -- Everything after this line is automatically generated

EXECUTABLES = bin2hex hex2bin mid2jmid jmid2mid jmidstrip
LIBDIR = $(HOME)/lib/$(ARCH)
LIBS = $(LIBDIR)/libfdr.a
CFLAGS = -O -I$(HOME)/include

all: $(EXECUTABLES)

clean:
	rm -f core *.o $(EXECUTABLES) a.out

.SUFFIXES: .c .o .jav .jmid .mid
.c.o:
	$(CC) $(CFLAGS) -c $*.c


.jmid.mid:
	jmid2mid < $*.jmid $*.mid

.jav.jmid:
	java2jmid < $*.jav > $*.jmid

bin2hex: bin2hex.o
	$(CC) $(CFLAGS) -o bin2hex bin2hex.o

hex2bin: hex2bin.o
	$(CC) $(CFLAGS) -o hex2bin hex2bin.o

jmid2mid: jmid2mid.o midi.o
	$(CC) $(CFLAGS) -o jmid2mid jmid2mid.o midi.o $(LIBS)

jmidstrip: jmidstrip.o midi.o
	$(CC) $(CFLAGS) -o jmidstrip jmidstrip.o midi.o $(LIBS)

mid2jmid: mid2jmid.o midi.o
	$(CC) $(CFLAGS) -o mid2jmid mid2jmid.o midi.o $(LIBS)
