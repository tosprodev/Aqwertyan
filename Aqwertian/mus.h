#if !defined(AFX_MUS_H__0CEBECC0_FC7F_11D2_87DB_0000C0280101__INCLUDED_)
#define AFX_MUS_H__0CEBECC0_FC7F_11D2_87DB_0000C0280101__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Rbtree.h"
#include "Dlist.h"
#include "Fields.h"

#import <Foundation/Foundation.h>


#define LH 0
#define RH 1
#define TL 2
#define LYRICS 3

/* An anchor is a specific note that matches a note in the piece.  The note will not
   be matched until the anchor is hit.  I probably should mark them somehow in the 
   display, but we're not there yet.  Key/name/octave specifies the note.  Sphere_num
   and sphere_den denote how many beats before the note you should look for the anchor.
   They may be zero, which is the default.
 */

typedef struct anchor {
	int key;
	char *name;
	int octave;
	int sphere_num;
	int sphere_den;
} Anchor;

/* An exmatch is like an anchor, but anchors are not implemented yet...  The exmatch
   states that a note must be exclusively matched with a specific note.  You can specify
   a tolerance that says by how many notes you can miss this note.  If you specify a
   note as an exmatch, it will match by key color -- i.e. if the exmatch note is a
   white key, then you cannot match that note with a black key, regardless of the
   tolerance.

   There might be a problem right now if you specify exmatches that violate the
   absolute vertical ordering of notes.  This is because of the projections -- therefore,
   it's ok until you stop doing exmatches.  Then there is a problem.  Frankly, I should
   make set_up_projections simply return when a note has exmatches.

   Another thing about exmatches -- if one note in a beat has an exmatch, all notes
   in that beat must have exmatches.  I'm not sure if I should make this a measure
   by measure thing yet.  I'll wait on that decision.  I think not actually, but
   it might make the task of skipping over notes easier.
   */



typedef struct exmatch {
	int qwert;            /* Is it a qwert? */
	int key;
    int colkeys[4];
	char *name;           /* Name for printing out qwerts */
	int fingerheight;
	int height;           /* Iff a qwert - which line the qwert should be printed on */
	int octave;
	int tolerance;
	struct note *lookahead;     /* pointer to the next note -- should make lookahead quicker */
} Exmatch;

typedef struct note {
  int num;           /* Unique number */
  char *name;        /* The name as it appears in the mus file */
  struct measure *m; /* The measure of this note */
  int linetype;		 /* LH, RH or TL */
  int octave;
  int key;
  int vol;
  int dur_num;
  int dur_den;
  int autoplaykey;  /* The key with which it will be autoplayed */
  int beat_on;      /* lcm units -- relative to the measure */
  int beat_off;     /* lcm units -- relative to the measure */
  int gbeat_on;     /* lcm units again -- this time with grace notes resolved */
  int gbeat_off;    /* Ditto */
  int gtbeaton;     /* gbeat_on + m->lcmbeats of the note's measure */
  int program;      /* Program number -- (i.e. instrument).  Ok -- this is done as
					follows.  -1 means use the default instrument.  Any number between
					0 and 127 means that program event (0xCx).  If it's bigger, then
					there are bank select commands that need to be issued as well
					(0xBx).  (program/256%256)-1 = bank 0 , (program/256/256)-1 = bank 32 */
  int channel;      /* Channel number -- 0 to 15 */
  Anchor *hint;     /* Hint for matching purposes.  I'm using the anchor structure here
					   because it is convenient.  The spheres will be set to zero.
					   Trillnotes, rests and ripples cannot have hints.  Phantoms can. */
  Anchor *anchor;   /* If there's an anchor, this is the pointer. Trillnotes and rests 
					   cannot have anchors. */
  Exmatch *exmatch; /* Set an exclusive match for a note.  See the exmatch typedef for
					   a better explanation */
  double maxchorddur; /* The maximum time (in seconds) that notes in a chord can be
					    sounded.  The default is .2.  It should be bumped up for
						ripples. All notes on the same beat must have the same maxchorddur. */
  double mininterspace; /* The minimum time (in seconds) that must pass between the previous
						   note and this note.  The default is 0.  When things get fast,
						   it might help to bump this up. Again, all notes on the same beat
                           must have the same mininterspace. */
  double beatid;    /* Beats from the beginning of the piece */
  double beatoffid; /* Beats from the beginning of the piece until note off event*/
  double time;      /* When the note was played */
  Dlist on_ties;
  int noadjacent;   /* If 1, this note will not match notes that are adjacent to the
					   last note played in this line.  This hopefully lets you do
					   fast things and eliminate double-note errors */
  Dlist off_ties;
  int grace_num;
  int ripple;       /* 0 = no ripple.  1 = ripple in LH,  2 = ripple in RH */
  int tempo_reset;  /* If 1, then set the tempo to -1 when you hit this note.
                       That way you should be able to do sudden tempo
                       shifts (slow to fast is the problem otherwise).
                       Measure's also have tempo_reset to do the same thing. */
  int phantom;  /* Phantoms don't get played, but that act like regular
                   notes */
  char *tie_on; /* specified by line name */
  char *tie_off;
  int playing;  /* Is this note currently playing */
  double volperc;   /* A multiplier for the volume -- if tied, it's a multiplier
                    to the tied note */
  int trill;         /* Is this a trill */
  struct note *trillnote; /* what note should I trill with */
  int trillstate;    /* 0 or 1 depending on which note is being played */
  struct note *carry;   /* If this note is carried -- this points to the next note to which
						   it is carried. */
  struct note *carrytc; /* If this note is carried -- this points
                           to the last note that is carried to this note.  If not, it
						   points to the note itself. */
  struct note *backcarry; /* If this note is a CARRY, this points to the previous note */
  struct note *backcarrytc; /* Transitive close of backcarry */
  int left;               /* Device coordinates for the note.  -1 if the note is not in */
  int right;              /* the display */
  int top;
  int bottom;
  int lookahead;          /* If you're exmatching, you can skip notes if you set the lookahead */
  Dlist overlappers;      /* List of notes that overlap this note in the current display.
						     They should be displayed after this note is displayed */
  int flag;               /* Tmp variable */
    __unsafe_unretained id view;
    CGRect frame;
    double offset;
    int draw_as_exmatch;
} Note;

extern Note *copy_note(Note *n);

typedef struct line {
  char *name;
  int program;            /* Instrument name.  Default is 1 -- grand piano */
  int channel;            /* Midi channel (1-16) to transmit the events.
                             values are 0-15  */
  Dlist l;                /* The notes in the line */
  int number;             /* Unique line number per name -- set on a post-
                                processing pass */
  char *tieto;            /* Line that this line is tied to */
  double volperc;         /* See volperc above */
  int lookahead;          /* See the description under note. */
  int noadjacent;         /* See the description under Note.  This just lets you set 
						     noadjacent at the beginning of a line, rather than for the
							 note */
} Line;

typedef struct hand {
  char skip;              /* Boolean -- skip notes of this hand? */
  char ignore;            /* Boolean -- ignore extra notes that are played */
  char chordig;           /* Boolean -- ignore extra notes in chords? */
  int lookahead;          /* See the description under note. */
  int noadjacent;  /* See the description under Note.  This lets you set adjacent or
				      no adjacent for all lines in a measure.  It's really best for 
					  clearing out all the lines. */
} Hand;

typedef struct measure {
  Rb_node lines;    /* Key = line name. Val=Line.  # of beats must = meter */
  Hand *hand[2];
  int apart;        /* 0 = hands play together.  1 = hands play apart */
  int number;
  int meter_num;
  int meter_den;
  int lcm;
  char *keysig;
  double tempo;    /* Whole notes per second */
  double beatid;   /* Beats from start of measure to beginning of piece */
  int lcmbeatid;   /* Sum of lcm units up to this point in the piece */
  int tempo_reset; /* See tempo_reset in notes above */
  int use_tempo;   /* Do you use tempo to throw out notes, or not? */
  int start;
  int rhkey;      /* lowest RH note -- default should be middle C */
  int left;       /* Device coordinates for the leftmost point in the measure */
  int right;      /* Device coordinates for the rightmost point in the measure */
  Dlist lyrics;   /* The lyrics -- a dlist of notes */
    __unsafe_unretained id view;
    CGRect frame;
    double offset;
} Measure;




typedef struct piece {
  char *name;
  Rb_node strings;    /* This has a pointer to all the allocated strings, so that
					      freeing a piece is straightforwards -- you just free all
						  the strings in this rb-tree */
  Rb_node measures;   /* Key = measure number.  Val = measure struct */
  Rb_node marks;      /* Key = Mark name.  Val = measure struct */
  Rb_node anchors;    /* Key = lcm beat id starting the anchor's sphere, val = note. */
  int lcm;            /* Least common multiple of all denom's in the piece (including anchors) */
  int tlines;         /* total # of lines */
  int start[3];       /* Line # of first LH, RH, TL lines */
  int heights[2];     /* # lines in the qwerty bars for LH [0] and RH [1] */
  int program;        /* Program -- (i.e. instrument) */
  int maxkey;         /* Highest note in the piece (-1 if no notes) */
  int minkey;         /* Lowest note in the piece */
  int autoplay;       /* Do CMP, or simply auto-play */
    int bandplay;
  int killonstop;     /* Kill the process when you stop playing */
  double qwertyheight; /* Height of the entire qwerty bar (in key units) */
  int lyrics;          /* Are there lyrics? */
    int columns;
} Piece;

extern Piece *read_mus_file(char *ifn);
extern void delete_piece(Piece *p);
extern int mid_key(char *key, int octave);
extern void set_rhkey(Piece *p, int midkey); /* Sets rhkey of every measure of the piece */
extern void kill_exmatches(Piece *p, int lr);  /* 'L' or 'R' */
extern int sprint_note(char *buffer, Note *n); /* 1 on success, 0 on failure */
void set_exmatch_heights(Piece *p);
extern void mus_error(Piece *p, IS is, char *s);

/* In the mus file, grace notes have durations of zero/xx.  If you 
   "resolve" them, they will have durations of 1/xx, taking that time
   from the note before the grace notes.  One caveat is that grace
   notes may not start a measure.  In mus2mid, you resolve grace
   notes.  In musplay, you don't. */

extern int resolve_grace_notes(Piece *p); // returns 1 if the piece is ok, and 0 otherwise.
extern void fprint_note(Note *n, FILE *f);
extern char *qwert_to_note(char *qwert, int *octave);
extern int qwert_to_finger(char *qwert);

extern int get_lcm(int a, int b);  // returns least common multiple of a and b
extern int get_gcd(int a, int b);  // returns greatest common denom of a and b

#endif // !defined(AFX_MUS_H__0CEBECC0_FC7F_11D2_87DB_0000C0280101__INCLUDED_)
