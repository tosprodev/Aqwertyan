// JMidi.cpp: implementation of the JMidi class.
//
//////////////////////////////////////////////////////////////////////
#include <string.h>
#include "stdlib.h"
//#include "stdafx.h"
#include "JMidi.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

#define talloc(ty, sz) (ty *) malloc (sz * sizeof(ty))

#include "fields.h"

int freadshort(FILE *in)
{
  unsigned int i;
  
  i = fgetc(in);
  i = (i << 8) + fgetc(in);
  return i;
}

int readshort()
{
	return freadshort(stdin);
}

int freadint(FILE *in)
{
  unsigned int i;

  i = fgetc(in);
  i = (i << 8) + fgetc(in);
  i = (i << 8) + fgetc(in);
  i = (i << 8) + fgetc(in);
  return i;
}

int readint()
{
  return freadint(stdin);
}

void writeshort(unsigned int i)
{
  unsigned char c;

  c = (i >> 8) & 255;
  putchar(c);
  c = i & 255;
  putchar(c);
}

void fwriteshort(FILE *f, unsigned int i)
{
  unsigned char c;

  c = (i >> 8) & 255;
  fputc(c, f);
  c = i & 255;
  fputc(c, f);
}

void writeint(unsigned int i)
{
  fwriteint(stdout, i);
}

void fwriteint(FILE *f, unsigned int i)
{
  unsigned char c, d, e, h;


  c = (char) (i & 255);
  i = (i >> 8);
  d = (char) (i & 255);
  i = (i >> 8);
  e = (char) (i & 255);
  i = (i >> 8);
  h = (char) (i & 255);
  fputc(h, f);
  fputc(e, f);
  fputc(d, f);
  fputc(c, f);
}

void fwritevarlen(FILE *f,  long value) 
{
        unsigned char buffer[4];
        int i;

        i = 0;
        buffer[i] = value & 0x7f;
        while ((value >>= 7) > 0) {
                i++;
                buffer[i] = 0x80 | (value & 0x7f);
        }

        while (i >= 0) {
			   /* if (debug) printf("%d %d 0x%x\n", i, buffer[i], buffer[i]); */
                fputc(buffer[i], f);
                i--;
        }
}

void writevarlen(long value)
{
  fwritevarlen(stdout, value);
}

int var_size(long value)
{
  int size;

  size = 1;
  while (value >= 0x80) {
    value = value >> 7;
    size ++;
  }
  return size;
}
  
unsigned long freadvarlen(FILE *in) 
{
        unsigned long value;
        unsigned retval;

        retval = 0;

        value = fgetc(in);
        while (value & 0x80) {
          retval = retval | (value & 0x7f);
          retval = retval << 7;
          value = fgetc(in);
        }
        return retval | value;
} 

unsigned long readvarlen()
{
	 return freadvarlen(stdin);
}



void fprint_event(FILE *f, Event *e)
{
  int i, k;
  Dlist tmp;

  /* printf("%7d %02X %d\n", e->time, e->event, e->args[0]); */
  fwritevarlen(f, e->time);
  fputc(e->event, f);
  if (e->event < 0xf0) {
    fputc(e->args[0], f);
    if (e->event >= 0x80 && e->event <= 0xbf) fputc(e->args[1], f);
    if (e->event >= 0xe0 && e->event <= 0xef) fputc(e->args[1], f);
  }
  if (e->event == 0xf0 || e->event == 0xf7 || e->event == 0xff) {
    if (e->event == 0xff) fputc(e->meta, f);
    fwritevarlen(f, e->length);
    if (e->length < NARG) {
      for (i = 0; i < e->length; i++) fputc(e->args[i], f);
    } else {
      dl_traverse(tmp, e->toobig) { k = (int) tmp->val; fputc(k, f); }
    }
  }
}
    
int get_esize(Event *e)
{
  int size;

  size = 0;

  size += var_size(e->time);  /* time */
  size++;                     /* event */
  if (e->event < 0xf0) {
    size++;
    if (e->event >= 0x80 && e->event <= 0xbf) size++;
    if (e->event >= 0xe0 && e->event <= 0xef) size++;
  }
  if (e->event == 0xf0 || e->event == 0xf7 || e->event == 0xff) {
    if (e->event == 0xff) size++;
    size += var_size(e->length);
    size += e->length;
  }
  return size;
}
    
Midi_file *read_jmid(char *fn)
{
  IS is;
  int tn;
  int i, j, k;
  Event *e;
  Midi_file *m;
  int dummy;

  is = new_inputstruct(fn);
  if (is == NULL) return NULL;

  m = talloc(Midi_file, 1);
  if (get_line(is) != 2 || strcmp(is->text1, "JMID FILE\n") != 0) {
    fprintf(stderr, "%s Not a jmid file\n", is->name);
    return NULL;
  }

  get_line(is);
  if (is->NF != 6 || strcmp(is->fields[0], "Format:") != 0) {
      fprintf(stderr, "%s Not a jmid file\n", is->name);
      return NULL;
  }

  m->format = atoi(is->fields[1]); 
  m->ntracks = atoi(is->fields[3]); 
  m->division = atoi(is->fields[5]); 
  m->tracks = (Dlist *) malloc(sizeof(Dlist)*m->ntracks);

  tn = -1;
  while(get_line(is) >= 0) {
    if (strcmp(is->fields[0], "TRACK") == 0) {
      tn++;
      if (tn != atoi(is->fields[1])) {
        fprintf(stderr, "Not a jmid file (Track) %d %s", tn, is->text1);
        return NULL;
      }
      m->tracks[tn] = make_dl();
    } else {
      e = talloc(Event, 1);
      e->time = atoi(is->fields[0]);
      sscanf(is->fields[2], "%x", &dummy);
      e->event = dummy;
      j = 3;
      if (e->event == 0xFF || e->event == 0xF0 || e->event == 0xF7) {
        if (e->event == 0xFF) {
          sscanf(is->fields[j++], "%02X", &dummy);
          e->meta = dummy;
        }
        e->length = atoi(is->fields[j++]);
        if (e->length > NARG) e->toobig = make_dl();
        for (i = 0; i < e->length; i++) {
          if (j == is->NF) {
            get_line(is);
            j = 0;
          }
          sscanf(is->fields[j++], "%02X", &k);
          if (e->length > NARG) {
            dl_insert_b(e->toobig, (void *)k);
          } else {
            e->args[i] = k;
          }
        }
      } else if (e->event < 0x80) {
        e->args[0] = atoi(is->fields[j++]);
      } else if (e->event >= 0x80 && e->event <= 0xbf) {
        e->args[0] = atoi(is->fields[j++]);
        e->args[1] = atoi(is->fields[j++]);
      } else if (e->event >= 0xc0 && e->event <= 0xdf) {
        e->args[0] = atoi(is->fields[j++]);
      } else if (e->event >= 0xe0 && e->event <= 0xef) {
        e->args[0] = atoi(is->fields[j++]);
        e->args[1] = atoi(is->fields[j++]);
      } else {
        fprintf(stderr, "Bad event: %d %s", is->line, is->text1);
        return NULL;
      }
      dl_insert_b(m->tracks[tn], e);
    }
  }

  if (tn+1 != m->ntracks) {
    fprintf(stderr, "ERROR: Ntracks = %d, tn+1 = %d\n", m->ntracks, tn+1);
    return NULL;
  }

  jettison_inputstruct(is);
  return m;
}

void create_midi(FILE *out, Midi_file *m)
{
  int sz, i;
  Dlist tmp;
  
  fprintf(out, "MThd");
  fwriteint(out, 6);
  fwriteshort(out, m->format);
  fwriteshort(out, m->ntracks);
  fwriteshort(out, m->division);
        
  for (i = 0; i < m->ntracks; i++) {
    fprintf(out, "MTrk");
    sz = 0;
    dl_traverse(tmp, m->tracks[i]) sz += get_esize((Event *) tmp->val);
    fwriteint(out, sz);
    dl_traverse(tmp, m->tracks[i]) {
      fprint_event(out, (Event *)tmp->val);
    }
  }
}
