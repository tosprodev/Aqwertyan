#include <stdio.h>
//#include "std.h"
#include "dlist.h"
#include "line.h"
#include "fields.h"
#define copy_string(s) ((char *) strcpy(talloc(char, strlen(s)+1), s))

/* Returns a rb-tree keyed on line name.  The vals are dlists of the lines.
   In the dlists are note structs.  For now, the note structs are  just
   the note number.  -1 means rest.  -2 means carry from the previous
   note. */

typedef struct {
  char *line;
  char *tieto;
  int volperc;
} Tieto;

Note *new_note()
{
  Note *n;

  n = talloc(Note, 1);
  n->tieto = NULL;
  n->onvel = -1;
  n->offvel = -1;
  n->on = -1;
  n->off = -1;
  n->key = -1;
    
 
  return n;
}

Rb_node read_lines(char *file)
{
  int i;
  IS is;
  Rb_node tree, rtmp;
  Dlist line, tieto, tmp, ttmp, ltmp;
  Dlist tietos;
  Note *n, *ln, *tn;
  Tieto *t;
  int fnd;
  char *s;

  tree = make_rb();
  tietos = make_dl();
  
  /* Read the file */

  is = new_inputstruct(file);
  if (is == NULL) { perror(file); exit(1); }

  while (get_line(is) >= 0) {
    if (is->NF == 0) {
    } else if (is->NF == 2 && strcmp(is->fields[0], "LINE") == 0) {
      rtmp = rb_find_key_n(tree, is->fields[1], &fnd);
      if (fnd) {
        fprintf(stderr, "Two lines with the same name %s (%s)\n",
                        is->fields[1], is->line);
        exit(1);
      }
      line = make_dl();
      t = NULL;
      s = copy_string(is->fields[1]);
      rtmp = rb_insert(tree, s, line);
    } else if (is->NF >= 3 && strcmp(is->fields[0], "TIE-TO") == 0) {
      t = talloc(Tieto, 1);
      t->line = rtmp->k.key;
      t->tieto = copy_string(is->fields[2]);
      t->volperc = 100;
      dl_insert_b(tietos, t);
    } else if (is->NF == 3 && strcmp(is->fields[0], "METER") == 0) {
      /* Ignore for now */
    } else if (is->NF == 2 && strcmp(is->fields[0], "VOLPERC") == 0) {
      if (t == NULL) { 
        fprintf(stderr, "VOLPERC %d No TIE-TO\n", is->line);
        exit(1);
      }
      t->volperc = atoi(is->fields[1]);
    } else if (is->NF == 2 && strcmp(is->fields[0], "KEY") == 0) {
      /* Ignore for now */
    } else if (is->NF == 2 && strcmp(is->fields[0], "M") == 0) {
      /* Ignore for now */

      /* Insert note */
    } else if ((atoi(is->fields[0]) > 0 && atoi(is->fields[0]) < 128) 
                || atoi(is->fields[0]) == -1 
                || atoi(is->fields[0]) == -2 ) {
      n = new_note();
      n->key = atoi(is->fields[0]);
      dl_insert_b(line, n);

    /* Insert rests */
    } else if (is->NF == 2 && strcmp(is->fields[0], "REST") == 0) {
      for (i = 0; i < atoi(is->fields[1]); i++) {
        n = new_note();
        n->key = -1;
        dl_insert_b(line, n);
      }

    /* Insert carries */
    } else if (is->NF == 2 && strcmp(is->fields[0], "CARRY") == 0) {
      for (i = 0; i < atoi(is->fields[1]); i++) {
        n = new_note();
        n->key = -2;
        dl_insert_b(line, n);
      }
    } else if (is->fields[0][0] == '#') {
      /* Skip comments */
    } else {
      fprintf(stderr, "Line %d.  Unknown key: %s\n", is->line, is->fields[0]);
      exit(1);
    }
  }
    
  /* Resolve the tie-tos */

  dl_traverse(ttmp, tietos) {
    t = (Tieto *) ttmp->val;
    rtmp = rb_find_key_n(tree, t->line, &fnd);
    if (!fnd) { fprintf(stderr, "Bad tieto line %s\n", t->line); exit(1); }
    line = (Dlist) rtmp->v.val;
    rtmp = rb_find_key_n(tree, t->tieto, &fnd);
    if (!fnd) { fprintf(stderr, "Bad tieto %s\n", t->tieto); exit(1); }
    tieto = (Dlist) rtmp->v.val;
    tmp = tieto->flink;
    dl_traverse(ltmp, line) {
      if (tmp == tieto) {
        fprintf(stderr, "Error tying %s to %s.  Ran out\n", t->line, t->tieto);
        exit(1);
      }
      ln = (Note *) ltmp->val;
      tn = (Note *) tmp->val;
      ln->tieto = tn;
      ln->volperc = t->volperc;
      tmp = tmp->flink;
    }
  }
  
  return tree;
}


