#include <stdio.h>
#include "JMidi.h"

    
int jmidstringsmain(int argc, char **argv)
{
  FILE *out;
  Midi_file *m;
  int newline;
  Dlist tmp, t2;
  Event *e;
  int i;
  int tr;
  int stime;

  if (argc != 1) {
    fprintf(stderr, "Usage: jmidstrings\n");
    exit(1);
  }

  m = read_jmid(NULL);
  if (m == NULL) exit(1);

  for (tr = 0; tr < m->ntracks; tr++) {
    stime = 0;
    dl_traverse(tmp, m->tracks[tr]) {
      e = (Event *) tmp->val;
      stime += e->time;
      if (e->event == 0xFF && e->meta >= 0x01 && e->meta <= 0x07) {
        printf("Track %2d : %8d : ", tr, stime);
        switch(e->meta) {
          case 0x01: printf("%-11s\n", "TEXT-EVENT"); break;
          case 0x02: printf("%-11s\n", "COPYRIGHT"); break;
          case 0x03: printf("%-11s\n", "SQ/TR-NAME"); break;
          case 0x04: printf("%-11s\n", "INST-NAME"); break;
          case 0x05: printf("%-11s\n", "LYRIC"); break;
          case 0x06: printf("%-11s\n", "MARKER"); break;
          case 0x07: printf("%-11s\n", "CUE-POINT"); break;
          default: fprintf(stderr, "jmidstring INTERNAL ERROR: Meta\n");exit(1);
        }
        newline = 1;
        if (e->length > NARG) {
          dl_traverse(t2, e->toobig) {
            if (newline) printf("%4s", " ");
            printf("%c", (int) t2->val);
            newline = ('\n' == (int) t2->val);
          }
        } else {
          for (i = 0; i < e->length; i++) {
            if (newline) printf("%4s", " ");
            printf("%c", e->args[i]);
            newline = ('\n' == e->args[i]);
          }
        }
        if (!newline) printf("\n");
      }
    }
  }
  exit(0);
}

