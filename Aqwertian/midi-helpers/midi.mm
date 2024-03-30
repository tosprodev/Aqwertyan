#include <stdio.h>
#include <stdlib.h>
//#include "std.h"
#include "JMidi.h"
#include "fields.h"
#define talloc(ty, sz) (ty *) malloc (sz * sizeof(ty))

int readshort()
{
  unsigned int i;
  
  i = getchar();
  i = (i << 8) + getchar();
  return i;
}

int readint()
{
  unsigned int i;

  i = getchar();
  i = (i << 8) + getchar();
  i = (i << 8) + getchar();
  i = (i << 8) + getchar();
  return i;
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
  unsigned char c[4];

  c[3] = i & 255;
  i = (i >> 8);
  c[2] = i & 255;
  i = (i >> 8);
  c[1] = i & 255;
  i = (i >> 8);
  c[0] = i & 255;
  fwrite(c, 1, 4, f);
}

void fwritevarlen(FILE *f,  long value )
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
  
unsigned long readvarlen( ) {
        unsigned long value;
        unsigned char c;
        unsigned retval;

        retval = 0;

        value = getchar();
        while (value & 0x80) {
          retval = retval | (value & 0x7f);
          retval = retval << 7;
          value = getchar();
        }
        return retval | value;
} 



void fprint_event(FILE *f, Event *e)
{
  int i, k;
  Dlist tmp;

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
      dl_traverse(tmp, e->toobig) { k = (int)tmp->val; fputc(k, f); }
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
  Dlist tmp;
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
      e = (Event *) malloc(sizeof(Event));
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
  int tn;
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
