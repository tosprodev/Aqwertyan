#include "Dlist.h"

#define NARG 14

typedef struct {
  int time;
  int length;
  unsigned char event;
  unsigned char meta;
  unsigned char args[NARG];
  Dlist toobig;
} Event;

typedef struct {
  Dlist *tracks;
  int ntracks;
  int format;
  int division;
} Midi_file;
 
extern void fprint_event(FILE *f, Event *e );  /* turns it to midi */
extern int get_esize(Event *e );          /* Returns the # of midi bytes */
extern void create_midi(FILE *f, Midi_file *m );   /* Turns m into into
                                                       a midi file */
extern Midi_file *read_jmid(char *fn);   /* reads jmid file (NULL
                                                  means stdin */

/* Reading and writing stuff in midi */

extern int readshort();           /* reads a short (2 bytes) and returns it */
extern int readint();             /* reads an int (4 bytes) and returns it */
extern void writeshort( int i );   /* writes a short to stdout */
extern void writeint( int );     /* writes an int to stdout */
extern void writevarlen( long v ); /* writes v as a variable length num */
extern void fwriteshort( FILE *f,int i );   /* writes a short to f */
extern void fwriteint( FILE *f, int i );     /* writes an int to f */
extern void fwritevarlen(FILE *f, long v ); /* writes v as a varlength num */
unsigned long readvarlen();       /* reads and returns a variable length num */
extern int var_size( long v ); /* Returns # of bytes in v */
