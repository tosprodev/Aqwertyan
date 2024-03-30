//
//  Structs.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/19/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#ifndef Aqwertian_Structs_h
#define Aqwertian_Structs_h
#import "Fields.h"
#import "Dlist.h"
#include "mus.h"
#import "JKrec.h"

typedef struct keys {
    int isvalid;    /* 1 if the line was played in this or the last measure */
    int key;        /* The key struck */
    int endbeat;    /* The beat (in lcm units) that the note is supposed to
                     end on */
} Keys;

typedef struct stats {
	int ignored_otherhand; /* Note ignored because we are waiting for a note in the other hand */
	int ignored_straychord; /* Note ignored because we played too many notes in a chord */
	int ignored_exmatch;   /* Note ignored because we are exmatching, and it didn't match */
	int skipped;
	int played;
} Stats;

typedef struct play_state {
    /* These first arrays are p->tlines long.  The are
     indexed by the line->number */
    
    int   *ison;    /* Is the line playing this measure? */
    Dlist *lptrs;   /* Pointer to the dlist node of the next note in the line
                     to be played */
    Note **notes;   /* the note that lptr is pointing to */
    int *cbeat;     /* How many beats (in lcm units from the start of the
                     measure) until lptr's note gets played */
    Line **lines;   /* Pointers to each line -- this only needs to be set up
                     once */
    int *nlookaheadtmp;  /* ditto */
    Keys *lln;      /* The last note played for this line.  ->key is the
                     key struck, not the note played */
    
    Measure *m;     /* Current measure */
    Rb_node m_ptr;  /* Pointer in p->measures to m's node in the rb-tree */
    int endbeat;    /* Ending beat of measure (lcm units)--remember grace notes */
    
    int volperc;    /* Percentage by which to multiply the volume */
    
    Rb_node project[2];   /* projected value of what keys will map to each line.
                           Key = key played.  Val = line number.  There is
                           one of these for each hand. */
    int curbeat[2];    /* Current beat/hand being played (units m->lcm) */
    double beatid[2];  /* Id of current beat/hand */
    double lhp[2];     /* Id of last beat played in this hand */
    double lhpt[2];    /* Time of last beat played in this hand */
    double skip_until; /* If we have to skip a bunch of notes, this says to keep killing beats
                        and redoing events until we've gotten to this note.  */
    double tempo_factor; /* Multiplier for the tempo */
    int rippling[2];   /* Are we rippling with this hand? */
    int nnotes[2];     /* Are there any notes left to play in this measure? */
    int n_ntp[2];      /* # of notes to play left in this beat/hand */
    int ngrace[2];     /* # of notes left to play that are grace notes */
    
    int playing[128];    /* Notes currently being played -- > 1 for on */
    int last_off[128];   /* The absolute time of the last note-off event for that note */
    Note *mapped[128];  /* What notes actual keys map to */
    int nplaying;   /* Number of 1 entries in playing */
    
    Piece *p;       /* The piece */
    double current_time;
    Krec *k;        /* The krec struct for input/output of midi events */
    double base_clock_time;    /* The clock() setting at the beginning of playing the
						     piece.  This may be redundant, but I don't have time
							 to grock through the code and figure it out.  Sorry */
    double last_clock;         /* The last clock() reading -- used to calculate deltas
						     for keypress events */
    double one_back;
    long cur_midi_time;      /* Current midi time (msec) in offset from base timeval */
    
    unsigned char *buf;     /* buffer for playing/unplaying multiple notes */
    int bufptr;
    unsigned char *bufnotes[128];   /* Notes played/unplayed in buf -- these are pointers
                                     to their volume.  The reason for this is that if you
                                     are playing the same note multiple times
									 as a result of one midi event, you only want to
									 generate one midi output event -- the one with the
									 highest volume.  So, bufnotes[key] points to the
									 volume of key that is buffered for playing when all
									 the midi events have been generated.  If you play the
									 same key twice, you check *bufnotes[key], and if the
									 current volume is greater, you simply update *bufnotes[key].
									 You don't generate a second midi event. */
    
    /* All of these have 2 values -- one for each hand
     if the hands are playing apart.  If the hands
     are playing together, then both use the [0] value */
    double tempo[2];       /* In beats / sec since beg of most recent measure */
    double cbtime[2];      /* Time of the current beat */
    double cbid[2];        /* Number of the current beat */
    double lbtime[2];      /* Time of the last beat (not used right now) */
    double lbid[2];        /* Number of the last beat (not used right now) */
    double mbtime[2];      /* Time of the last major beat */
    double mbid[2];        /* Number of the last major beat */
    
    int mask;              /* This gets &&'d with the hand to see which of the
                            above gets used.  If apart, mask = 1.  If
                            together, mask = 0. */
    
    Note *trill_note;       /* The note being trilled (null if none) */
    int trill_key[2];       /* The keys that map to the trill notes */
    int trill_line;         /* The line # of the line that is trilling */
    int program[16];        /* The current program number of each channel
                             (channels indexed 0 to 15). See the definition of
                             n->program for notes for what this number really means */
    FILE *tf;               /* Trace file */
    Dlist midi_events;      /* Midi events for making the midi output file.  This is a dlist
                             of chunks of EVBUF MidiEvents.  The number of events in the
                             current chunk is in nevents. */
    int nevents;            /* See above */
    int total_nevents;	  /* Total number of events in the midi-events list */
    int maxkey;             /* Max key of the piece (may differ from p->maxkey because these
						     values are set to make the output window look nice) */
    int minkey;             /* Min key of the piece */
    Rb_node firstm;         /* Display measures -- first, and one past the last */
    Rb_node lastm;
    int windowlcm;          /* Lcm of the display notes */
    int *windowbeats;        /* Total number of beats (in windowlcm units) in each line of he window */
    Measure **leftmeasures; /* The leftmost measure in each line of the display*/
    Measure **rightmeasures; /* The rightmost measure in each line of the display */
    int voffset;             /* starting line from the top of the screen (since you can wrap
						      around */
    double YAH;    /* Beat id of you-are-here -- used to calc the position of the YAH
				    line */
    Rb_node YAH_to_delete;
    Rb_node YAH_ntr; /* Notes to redisplay on undrawyah.  Key = n->num.  Val = note */
    Rb_node YAH_mtr; /* Measures to redisplay on undrawyah.  Key = m->number Val = measure */
    int YAH_displayed;
    Measure *YAH_dmeasure;
    int YAH_Inv_top;
    int YAH_Inv_bottom;
    int YAH_Draw_top;
    int YAH_Draw_bottom;
    Note *last_played;
    Dlist autoplaying;  /* Notes that are currently being autoplayed.  This is brutal,
                         but so be it -- I'm going to keep this sorted.  My kingdom for
                         jrb's....  It will be sorted by note off time.  */
    int inst_default;  /* Default instrument for notes with n->program < 0 */
    Stats stats[2];
} Play_state;


#endif
