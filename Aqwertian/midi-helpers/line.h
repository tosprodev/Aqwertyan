#include "Rbtree.h"
#include "stdlib.h"

/* Returns a rb-tree keyed on line name.  The vals are dlists of the lines.
   In the dlists are note structs.  For now, the note structs are  just
   the note number.  -1 means rest.  -2 means carry from the previous
   note. */

#define talloc(ty, sz) (ty *) malloc (sz * sizeof(ty))

typedef struct note {
  int key;
  struct note *tieto;
  int volperc;
  int onvel;
  int offvel;
  int on;
  int off;
} Note;

extern Rb_node read_lines(/* char *file */);   /* NULL = stdin */
