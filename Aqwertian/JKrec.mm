// JKrec.cpp: implementation of the JKrec class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "JKrec.h"
#include "time.h"
#include <sys/time.h>


#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

double tv_to_t(struct timeval *t)
{
  double d;

  d = t->tv_usec;
  d /= 1000000.0;
  d += t->tv_sec;
  return d;
}

int compute_dtime(struct timeval *t)
{
  double d;

  d = t->tv_usec;
  d /= 1000000.0;
  d += t->tv_sec;
  d *= 480;
  d += 0.5;
  return (int) d;
}


Krec *new_krec()
{
  Krec *k;

  k = (Krec *) malloc(sizeof(Krec));

  k->last = 0;
  k->e = (Krec_event *) malloc(sizeof(Krec_event));
  k->undone = -1;
  k->cumtime.tv_sec = -1;
  k->cumtime.tv_usec = -1;
  k->starting_beat = -1;
  return k;
}

void free_krec(Krec *k)
{
	free(k->e);
	free(k);
}

void krec_undo(Krec *k)
{
  if (k->undone != 0) { 
    fprintf(stderr, "krec_undo called twice\n");
    exit(1);
  }
  k->undone = 1;
}

/* This assumes that lpMsg->time is in ticks, the tempo is 120 bpm, and the resolution
   is 480 ticks per beat */

Krec_event *krec_event(Krec *k, LPMIDIEVENT lpMsg, double time, int beats, int tempo, double base)
{
	double d;
	int sec;
	int usec;
	int tpb;
	double cl;

	tpb = 480 * 1000000 / tempo;


    if (k->undone == 1) {
      k->undone = 0;
      return k->e;
    }
    k->undone = 0;
	if (lpMsg == NULL) return NULL;
    struct timeval tv;
    gettimeofday(&tv, NULL);
    cl = tv_to_t(&tv)*CLOCKS_PER_SEC;
	if (k->cumtime.tv_sec == -1) {

		//cl = clock();
        
		k->starting_beat = beats;
		k->cumtime.tv_sec = ((int)(cl - base))/CLOCKS_PER_SEC;
		k->cumtime.tv_usec = (((int)(cl - base))%CLOCKS_PER_SEC);
		lpMsg->time = 0;
	} else {
    //lpMsg->time = 0;
	sec = lpMsg->time/tpb;
	d = (double) (lpMsg->time%tpb);
	d = (d / ((double) tpb) * 1000000) + 0.5;
	usec = (int) d;
//	k->cumtime.tv_sec += sec;
//	k->cumtime.tv_usec += usec;
        k->cumtime.tv_sec += (int)(cl - time)/CLOCKS_PER_SEC;
	k->cumtime.tv_usec += (int)(cl- time)/CLOCKS_PER_SEC;
    }
	if (k->cumtime.tv_usec >= 1000000) {
		k->cumtime.tv_sec++;
		k->cumtime.tv_usec -= 1000000;
	}

	k->e->tv->tv_sec = k->cumtime.tv_sec;
	k->e->tv->tv_usec = k->cumtime.tv_usec;
	k->e->e[0] = lpMsg->status;
	k->e->e[1] = lpMsg->data1;
	k->e->e[2] = lpMsg->data2;
	k->e->e[3] = lpMsg->data3;
	return k->e;
}
