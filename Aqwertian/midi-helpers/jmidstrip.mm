#include <stdio.h>
#include "JMidi.h"

    
void jmidstripmain(int argc, char **argv)
{
  FILE *out;
  Midi_file *m;
  double seconds;
  int miditime;
  int i;
  int tottime;
  Dlist tmp;
  Event *e;

  if (argc != 3) {
    fprintf(stderr, "Usage: jmidstrip seconds outputfile\n");
    fprintf(stderr, "       if seconds < 0, then it strips after that number of seconds\n");
    exit(1);
  }

  if (sscanf(argv[1], "%lf", &seconds) != 1) { 
    fprintf(stderr, "Usage: jmidstrip seconds outputfile\n");
    exit(1);
  }
  
  miditime = seconds*480;

  m = read_jmid(NULL);

  for (i = 0; i < m->ntracks; i++) {
    tottime = 0;
    dl_traverse(tmp, m->tracks[i]) {
        e = (Event *) tmp->val;
      tottime += e->time;
      if (miditime < 0) {
        if (tottime >= -miditime) {
          tmp = tmp->blink;
          dl_delete_node(tmp->flink);
        } 
      } else {
        if (tottime < miditime && (tottime > 0 || e->event != 0xff)) {
          tmp = tmp->blink;
          dl_delete_node(tmp->flink);
        }
      }
    }
  }

  out = fopen(argv[2], "w");
  if (out == NULL) { perror(argv[2]); exit(1); }

  create_midi(out, m);
  exit(0);
}

