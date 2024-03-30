// JKrec.h: interface for the JKrec class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_JKREC_H__D2812660_FCC2_11D2_87DB_0000C0280101__INCLUDED_)
#define AFX_JKREC_H__D2812660_FCC2_11D2_87DB_0000C0280101__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

//#include "MaxMidi.h"

#define KE_CONTROL(ke) (ke != NULL && ((ke->e[0] & 0xf0) == 0xb0)) 
#define KE_PROGRAM(ke) (ke != NULL && ((ke->e[0] & 0xf0) == 0xc0)) 
#define KE_WHEEL(ke) (ke != NULL && ((ke->e[0] & 0xf0) == 0xe0)) 

#define KE_METRONOME(ke) (ke != NULL && ke->e[0] == 0xf8) 
#define KE_NOTE_ON(ke) (ke != NULL && ((ke->e[0] & 0xf0) == 0x90) \
                                   && (ke->e[2] > 0))
#define KE_NOTE_OFF(ke) (ke != NULL && \
                         (((ke->e[0] & 0xf0) == 0x90 && (ke->e[2] == 0)) || \
                          ((ke->e[0] & 0xf0) == 0x80)))
#define KE_PEDAL_DOWN(ke) (KE_CONTROL(ke) && ke->e[1] == 64 && \
                                         ke->e[2] > 0)
#define KE_PEDAL_UP(ke)   (KE_CONTROL(ke) && ke->e[1] == 64 && \
                                         ke->e[2] == 0)
#define KE_COMP_NOTE(ke)   (ke->e[0] < 0x80 && ke->e[0] > 0)
 
//struct timeval {
//	int tv_sec;
//	int tv_usec;
//};



//extern struct Play_state;

typedef unsigned long DWORD;
typedef unsigned char BYTE;

typedef struct {
	DWORD	time;		// time in ticks since last event
	BYTE	status;		// status byte of this midi message
	BYTE	data1;		// first data byte of message
	BYTE	data2;		// second data byte of message
	BYTE	data3;		// third data byte, used for tempo changes
} MidiEvent;

typedef MidiEvent* LPMIDIEVENT;

typedef struct krec_event {
  unsigned char e[4];
  struct timeval tv[1];
} Krec_event;

typedef struct krec {
	Krec_event *e;
    unsigned char last;
	struct timeval cumtime;
	int starting_beat;
    int undone;     /* If undone, then don't get a new event -- just use e */
} Krec;
   
extern Krec *new_krec();
extern Krec_event *krec_event(Krec *k, LPMIDIEVENT lpMsg, double time, int beats, int tempo, double base_clock);
extern void krec_undo(Krec *k);
extern void free_krec(Krec *k);

/* tv_to_t converts a timeval to seconds -- as a double */
extern double tv_to_t(struct timeval *t);

/* compute_dtime converts a timeval to 480ths of a second */
extern int compute_dtime(struct timeval *t);

#endif // !defined(AFX_JKREC_H__D2812660_FCC2_11D2_87DB_0000C0280101__INCLUDED_)
