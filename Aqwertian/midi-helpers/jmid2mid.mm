#include <stdio.h>
#include <stdlib.h>
#include "JMidi.h"

    
int jmidtomidmain(int argc, char **argv)
{
  FILE *out;
  Midi_file *m;

  if (argc != 2) {
    fprintf(stderr, "Usage: jmid2mid outputfile\n");
    exit(1);
  }

  m = read_jmid(NULL);
  out = fopen(argv[1], "w");
  if (out == NULL) { perror(argv[1]); exit(1); }

  create_midi(out, m);
  exit(0);
}

