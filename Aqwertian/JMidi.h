// JMidi.h: interface for the JMidi class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_JMIDI_H__4DBB9861_FB24_11D2_87DB_0000C0280101__INCLUDED_)
#define AFX_JMIDI_H__4DBB9861_FB24_11D2_87DB_0000C0280101__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
#include <stdio.h>
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

typedef struct midi_file{
  Dlist *tracks;
  int ntracks;
  int format;
  int division;
} Midi_file;
 
extern void fprint_event(FILE *f, Event *e);  /* turns it to midi */
extern int get_esize(Event *e);          /* Returns the # of midi bytes */
extern void create_midi(FILE *f, Midi_file *m);   /* Turns m into into 
                                                       a midi file */
extern Midi_file *read_jmid(char *fn);   /* reads jmid file (NULL
                                                  means stdin */

/* Reading and writing stuff in midi */

extern int readshort();           /* reads a short (2 bytes) and returns it */
extern int readint();             /* reads an int (4 bytes) and returns it */
extern void writeshort(int i);   /* writes a short to stdout */
extern void writeint(int i);     /* writes an int to stdout */
extern void writevarlen(long v); /* writes v as a variable length num */
extern void fwriteshort(FILE *f,unsigned int i);   /* writes a short to f */
void fwriteint(FILE *f, unsigned int i);     /* writes an int to f */
void fwritevarlen(FILE *f, long v); /* writes v as a varlength num */
unsigned long readvarlen();       /* reads and returns a variable length num */
unsigned long freadvarlen(FILE * f);       /* reads and returns a variable length num */
extern int var_size(long v); /* Returns # of bytes in v */
extern int freadshort(FILE *f);           /* reads a short (2 bytes) and returns it */
extern int freadint(FILE *f);             /* reads an int (4 bytes) and returns it */

#endif // !defined(AFX_JMIDI_H__4DBB9861_FB24_11D2_87DB_0000C0280101__INCLUDED_)
