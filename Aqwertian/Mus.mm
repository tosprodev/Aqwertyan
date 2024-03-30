// Mus.cpp: implementation of the Mus class.
//
//////////////////////////////////////////////////////////////////////

#include <string.h>
#include <stdlib.h>
//#include "stdafx.h"
#include "mus.h"
//#include "MaxSeq.h"
//#include "DialogMusLoadError.h"
//#include "DialogErrbox.h"
#import <Foundation/Foundation.h>
#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

#define talloc(ty, sz) (ty *) malloc (sz * sizeof(ty))
#define copy_string(s) ((char *) strcpy(talloc(char, strlen(s)+1), s))

#include "Fields.h"
#include "JMidi.h"


int double_check_piece(Piece *p, char *fn);

static int Note_Number = 0;
static char *tie_dfl = "Default Tie String";
Piece *p;

/* This takes a qwert (string) and puts its note name into the string
   and returns its octave.  I.e. Each qwert maps to a piano note.
   This routine defines the mapping.  
   */

int insert_note_heights(Rb_node overtree, Rb_node starting_ptr, Rb_node ending_ptr)
{
	Rb_node linetree;
	Rb_node tmp1, tmp2, tmp3, tree;
	int fnd;
	Note *n;
	int i;

	linetree = make_rb();
	for (tmp1 = starting_ptr; tmp1 != ending_ptr; tmp1 = rb_next(tmp1)) {
		tree = (Rb_node) tmp1->v.val;
		rb_traverse(tmp2, tree) {
			tmp3 = rb_find_ikey_n(linetree, tmp2->k.ikey, &fnd);
			if (!fnd) {
				tmp3 = rb_inserti(linetree, tmp2->k.ikey, (void *) 0);
			}
		}
	}
	i = 0;
	rb_traverse(tmp1, linetree) {
		tmp1->v.ival = i;
		i++;
	}
	for (tmp1 = starting_ptr; tmp1 != ending_ptr; tmp1 = rb_next(tmp1)) {
		tree = (Rb_node) tmp1->v.val;
		rb_traverse(tmp2, tree) {
			n = (Note *) tmp2->v.val;
			tmp3 = rb_find_ikey(linetree, tmp2->k.ikey);
			n->exmatch->height = tmp3->v.ival;
			if (!n->exmatch->qwert) {
				n->exmatch->fingerheight = -1;
			} else {
				n->exmatch->fingerheight = qwert_to_finger(n->exmatch->name);
				if (n->linetype == RH && n->exmatch->fingerheight == 4) {
				//	n->exmatch->fingerheight++;
				}
			}
		}
	}
	rb_free_tree(linetree);
	return i;
}
char *qwert_to_note(char *qwert, int *octave)
{
	unsigned char c;
	if (strlen(qwert) == 1) {
		c = *qwert;
		if (c >= 'A' && c <= 'Z') c += ('a' - 'A');
		switch(c) {
			case ' ': *octave = -1; return "B";
			case 27: *octave = -4; return "Bb";  // Escape
			case 'z': *octave = -3; return "C";
			case 'x': *octave = -3; return "D"; 
			case 'c': *octave = -3; return "E";
			case 'v': *octave = -3; return "F";
			case 'b': *octave = -3; return "G";
			case 'a': *octave = -3; return "A";
			case 's': *octave = -3; return "B";
			case 'd': *octave = -2; return "C";
			case 'f': *octave = -2; return "D";
			case 'g': *octave = -2; return "E";
			case '\t': *octave = -2; return "F";
			case 'q': *octave = -2; return "G";
			case 'w': *octave = -2; return "A";
			case 'e': *octave = -2; return "B";
			case 'r': *octave = -1; return "C";
			case 't': *octave = -1; return "D";
			case '`':
			case 192:
			case '~': *octave = -2; return "G#";
			case '!':
			case '1': *octave = -2; return "A#";
			case '@':
			case '2': *octave = -1; return "C#";
			case '#':
			case '3': *octave = -1; return "D#";
			case '$':
			case '4': *octave = -1; return "F#";
			case '%':
			case '5': *octave = -1; return "G#";
			case '^':
			case '6': *octave = -1; return "A#";
			case 'n': *octave = 0; return "C";
			case 'm': *octave = 0; return "D";
			case ',':
			case 188:
			case '<': *octave = 0; return "E";
			case '.': 
			case 190:
			case '>': *octave = 0; return "F";
			case '/':
			case 191:
			case '?': *octave = 0; return "G";
			case 'h': *octave = 0; return "A";
			case 'j': *octave = 0; return "B";
			case 'k': *octave = 1; return "C";
			case 'l': *octave = 1; return "D";
			case ';': 
			case 186:
			case ':': *octave = 1; return "E";
			case '\'':
			case 222:
			case '"': *octave = 1; return "F";
			case 13:
			case '\n': *octave = 1; return "G";
			case 'y': *octave = 1; return "A";
			case 'u': *octave = 1; return "B";
			case 'i': *octave = 2; return "C";
			case 'o': *octave = 2; return "D";
			case 'p': *octave = 2; return "E";
			case '[':
			case 219:
			case '{': *octave = 2; return "F";
			case ']': 
			case 221:
			case '}': *octave = 2; return "G";
			case '\\': 
			case 220:
			case '|': *octave = 2; return "A";
			case '&':
			case '7': *octave = 2; return "B";
			case '*':
			case '8': *octave = 3; return "C";
			case '(':
			case '9': *octave = 3; return "D";
			case ')':
			case '0': *octave = 3; return "E";
			case '-':
			case 189:
			case '_': *octave = 3; return "F";
			case '=':
			case 187:
			case '+': *octave = 3; return "G";
			case '\b': *octave = 3; return "A";
			default: return NULL;
		}
	}
	if (strcmp(qwert, "SP") == 0) { *octave = -1; return "B"; }
	if (strcmp(qwert, "SPACE") == 0) { *octave = -1; return "B"; }
	if (strcmp(qwert, "TAB") == 0) { *octave = -2; return "F"; }
	if (strcmp(qwert, "BACK") == 0) { *octave = 3; return "A"; }
	if (strcmp(qwert, "RETURN") == 0) { *octave = 1; return "G"; }
	if (strcmp(qwert, "ESCAPE") == 0) { *octave = -4; return "Bb"; }
	return NULL;
}




int qwert_to_finger_orig(char *qwert)
{
	unsigned char c;
	if (/*strlen(qwert) == 1*/ true) {
		c = *qwert;
		if (c >= 'A' && c <= 'Z') c += ('a' - 'A');
		switch(c) {
			case ' ': return 0;
			case 27: return 0;  // Escape
			case 'z': return 0;
			case 'x': return 1; 
			case 'c': return 2;
			case 'v': return 3;
			case 'b': return 3;
			case 'a': return 0;
			case 's': return 1;
			case 'd': return 2;
			case 'f': return 3;
			case 'g': return 3;
			case '\t': return 0;
			case 'q': return 0;
			case 'w': return 1;
			case 'e': return 2;
			case 'r': return 3;
			case 't': return 3;
			case '`':
			case 192:
			case '~': return 0;
			case '!':
			case '1': return 0;
			case '@':
			case '2': return 1;
			case '#':
			case '3': return 2;
			case '$':
			case '4': return 3;
			case '%':
			case '5': return 3;
			case '^':
			case '6': return 3;
			case 'n': return 6;
			case 'm': return 6;
			case ',':
			case 188:
			case '<': return 7;
			case '.': 
			case 190:
			case '>': return 8;
			case '/':
			case 191:
			case '?': return 9;
			case 'h': return 6;
			case 'j': return 6;
			case 'k': return 7;
			case 'l': return 8;
			case ';': 
			case 186:
			case ':': return 9;
			case '\'':
			case 222:
			case '"': return 9;
			case 13:
			case '\n': return 9;
			case 'y': return 6;
			case 'u': return 6;
			case 'i': return 7;
			case 'o': return 8;
			case 'p': return 9;
			case '[':
			case 219:
			case '{': return 9;
			case ']': 
			case 221:
			case '}': return 9;
			case '\\': 
			case 220:
			case '|': return 9;
			case '&':
			case '7': return 6;
			case '*':
			case '8': return 7;
			case '(':
			case '9': return 8;
			case ')':
			case '0': return 9;
			case '-':
			case 189:
			case '_': return 9;
			case '=':
			case 187:
			case '+': return 9;
			case '\b': return 9;
			default: return 4;
		}
	}
	if (strcmp(qwert, "SP") == 0) { return 4; }
	if (strcmp(qwert, "SPACE") == 0) { return 4; }
	if (strcmp(qwert, "TAB") == 0) { return 0; }
	if (strcmp(qwert, "BACK") == 0) { return 9; }
	if (strcmp(qwert, "RETURN") == 0) { return 9; }
	if (strcmp(qwert, "ESCAPE") == 0) { return 0; }
	return 4;
}

int qwert_to_finger(char *qwert) {
    int retval = qwert_to_finger_orig(qwert);
    if (retval < 4) {
        
    } else if (retval == 4) {
        retval = 3;
    } else if (retval == 5) {
        retval = 4;
    } else if (retval == 6) {
        retval = 4;
    } else {
        retval -= 2;
    }
//    if (retval > 4) {
//        retval -= 2;
//    }
    return retval;
}

char *new_string(Piece *p, char *s)
{
	int fnd;
	Rb_node tmp;
	char *news;

	tmp = rb_find_key_n(p->strings, s, &fnd);
	if (fnd) return tmp->k.key;
	news = copy_string(s);
	rb_insert(p->strings, news, NULL);
	return news;
}

int get_lcm(int a, int b)
{
	int gcd, tmp;

	if (a > b) { tmp = b; b = a; a = tmp;}
	gcd = get_gcd(a, b);
	return a * (b / gcd);
}

int get_gcd(int a, int b)
{
	int tmp;

	if (a > b) { tmp = b; b = a; a = tmp;}
	while (1) {
		if (b % a == 0) return a;
		tmp = (b % a);
		b = a;
		a = tmp;
	}
}

void fprint_note(Note *n, FILE *f)
{
  if (n == NULL) fprintf(f, "none");
  fprintf(f, "%3d %3d %3d %3d", n->key, n->vol, n->dur_num, n->dur_den);
}

/* Returns the note starting at num/den in the given line.  If there is no such note,
   it returns NULL.  If grace_ok = 1, then it's ok to return a grace note.  If not,
   then it will note return a grace note. */

static Note *find_note_by_beat(Line *l, int num, int den, int grace_ok)
{
  Note *n;
  Dlist dtmp;
  int current_tick, i;

  num--;
  if (num < 0) return NULL;
  if (l == NULL) return NULL;
  current_tick = 0;
  dl_traverse(dtmp, l->l) {
    n = (Note *) dtmp->val;
    if (current_tick == num && (n->dur_num > 0 || grace_ok)) return n;
    i = get_lcm(n->dur_den, den);
    if (i > den) {
      num *= (i/den);
      den *= (i/den);
    }
    current_tick += ((n->dur_num * den)/n->dur_den);
  }
  return NULL;
}


/* Returns last note in the line.  It skips over rests if restok = 0 */

static Note *get_last_note(Piece *p, Measure *m, Line *l, int restok)
{
  int fnd;
  Rb_node tmp, mp;
  Note *n;
  Dlist dtmp;

  mp = rb_find_ikey_n(p->measures, m->number, &fnd);
  if (!fnd) return NULL;
  while(1) {
    dtmp = l->l->blink;
    while(dtmp != l->l) {
      n = (Note *) dtmp->val;
      if (restok || n->key != 0) return n;
      dtmp = dtmp->blink;
    }
    fnd = 0;
    while (!fnd) {
        mp = rb_prev(mp);
         if (mp == p->measures) return NULL;
        m = (Measure *) mp->v.val;
        tmp = rb_find_key_n(m->lines, l->name, &fnd);
    }
      l = (Line *) tmp->v.val;
  }
}

static Line *new_line(char *name)
{
  Line *l;

  l = talloc(Line, 1);
  l->name = name;
  l->l = make_dl();
  l->tieto = NULL;
  l->volperc = -1;
  l->program = -1;
  l->channel = -1;
  l->noadjacent = -1;
  l->lookahead = -1;
  return l;
}

static void print_measure(Measure *m)
{
  Rb_node tmp;
  Dlist dtmp;
  Line *line;
  Note *n;

  printf("Measure %d", m->number);
  printf("  Tempo = %lf, Meter = %d/%d,", m->tempo, m->meter_num, m->meter_den);
  printf(" Beats = %d/%d, keysig = %s", (m->meter_num*m->lcm)/m->meter_den, m->lcm, m->keysig);
  rb_traverse(tmp, m->lines) {
    printf("  Line: %s", tmp->k.key);
    line = (Line *) tmp->v.val;
    dl_traverse(dtmp, line->l) {
      n = (Note *) dtmp->val;
      printf("   ");
      fprint_note(n, stdout);
    }
  }
}

void print_piece(Piece *p)
{
  Rb_node tmp;

  printf("Piece: %s", p->name);
  rb_traverse(tmp, p->measures) {
    print_measure((Measure *)tmp->v.val);
  }
}

static Note *new_note()
{
  Note *n;
  n = talloc(Note, 1);
  n->num = Note_Number++;
  n->linetype = -1;
  n->name = NULL;
  n->octave = -100;
  n->program = -1;
  n->channel = -1;
  n->key = 0;
  n->vol = 0;
  n->dur_num = -1;
  n->hint = NULL;
  n->anchor = NULL;
  n->exmatch = NULL;
  n->dur_den = -1;
  n->on_ties = NULL;
  n->off_ties = NULL;
  n->tie_on = tie_dfl;
  n->tie_off = tie_dfl;
  n->time = -1.0;
  n->phantom = 0;
  n->tempo_reset = 0;
  n->beat_on = -1;
  n->beat_off = -1;
  n->gbeat_on = -1;
  n->gbeat_off = -1;
  n->gtbeaton = -1;
  n->volperc = -1;
  n->grace_num = -1;
  n->trill = 0;
  n->trillnote = NULL;
  n->trillstate = 0;
  n->ripple = 0; 
  n->carry = NULL;
  n->carrytc = NULL;
  n->backcarry = NULL;
  n->backcarrytc = NULL;
  n->playing = 0;
  n->left = n->right = n->top = n->bottom = -1;
  n->overlappers = make_dl();
  n->mininterspace = -1.0;
  n->maxchorddur = -1.0;
  n->noadjacent = -1;
  n->lookahead = -1;
     n->view = nil;
    n->draw_as_exmatch = -1;
  return n;
}

Note *copy_note(Note *n)
{
    Note *nn;
    
    nn = new_note();
    nn->name = n->name;
    nn->octave = n->octave;
    nn->key = n->key;
    nn->program = n->program;
    nn->m = n->m;
    if (n->anchor == NULL) {
        nn->anchor = NULL;
    } else {
        nn->anchor = (Anchor *) malloc(sizeof(Anchor));
        nn->anchor->key = n->anchor->key;
        nn->anchor->name = n->anchor->name;
        nn->anchor->octave = n->anchor->octave;
        nn->anchor->sphere_num = n->anchor->sphere_num;
        nn->anchor->sphere_den = n->anchor->sphere_den;
    }
    if (n->exmatch == NULL) {
        nn->exmatch = NULL;
    } else {
        nn->exmatch = (Exmatch *) malloc(sizeof(Exmatch));
        nn->exmatch->key = n->exmatch->key;
        nn->exmatch->name = n->exmatch->name;
        nn->exmatch->octave = n->exmatch->octave;
        nn->exmatch->tolerance = n->exmatch->tolerance;
        nn->exmatch->lookahead = NULL;
        nn->exmatch->qwert = n->exmatch->qwert;
        nn->exmatch->height = n->exmatch->height;
        nn->exmatch->fingerheight = n->exmatch->fingerheight;
    }
    if (n->hint == NULL) {
        nn->hint = NULL;
    } else {
        nn->hint = (Anchor *) malloc(sizeof(Anchor));
        nn->hint->key = n->hint->key;
        nn->hint->name = n->hint->name;
        nn->hint->octave = n->hint->octave;
        nn->hint->sphere_num = n->hint->sphere_num;
        nn->hint->sphere_den = n->hint->sphere_den;
    }
    nn->linetype = n->linetype;
    nn->channel = n->channel;
    nn->vol = n->vol;
    nn->dur_num = n->dur_num;
    nn->dur_den = n->dur_den;
    nn->on_ties = NULL;
    nn->off_ties = NULL;
    nn->tie_on = n->tie_on;
    nn->tie_off = n->tie_off;
    nn->time = n->time;
    nn->tempo_reset = n->tempo_reset;
    nn->phantom = n->phantom;
    nn->beat_on = n->beat_on;
    nn->beat_off = n->beat_off;
    nn->gbeat_on = n->gbeat_on;
    nn->gbeat_off = n->gbeat_off;
    nn->gtbeaton = n->gtbeaton;
    nn->volperc = n->volperc;
    nn->grace_num = n->grace_num;
    nn->trill = n->trill;
    nn->trillnote = n->trillnote;
    nn->trillstate = n->trillstate;
    nn->ripple = n->ripple;
    nn->carry = n->carry;
    nn->carrytc = n->carrytc;
    nn->backcarry = n->backcarry;
    nn->backcarrytc = n->backcarrytc;
    nn->playing = n->playing;
    nn->left = n->left;
    nn->right = n->right;
    nn->top = n->top;
    nn->bottom = n->bottom;
    nn->maxchorddur = n->maxchorddur;
    nn->mininterspace = n->mininterspace;
    nn->noadjacent = n->noadjacent;
    nn->lookahead = n->lookahead;
    // Don't copy overlappers
    return nn;
}



void mus_error(Piece *p, IS is, char *s)
{
	//int i;
	//CDialogMusLoadError ebox;
    NSLog(@"%s",s);
	if (is == NULL) {
		//ebox.m_strErrString.Format("%s", s);
	} else {
	//	ebox.m_strErrString.Format("%s %d: %s", is->name, is->line, s);
		jettison_inputstruct(is);
	}
	//i = ebox.DoModal();
	if (p != NULL) delete_piece(p);
	return;
}

int mid_key(char *key, int octave)
{
  int base;
  switch(key[0]) {
  case 'c':
  case 'C': base = 0; break;
  case 'd':
  case 'D': base = 2; break;
  case 'e':
  case 'E': base = 4; break;
  case 'f':
  case 'F': base = 5; break;
  case 'g':
  case 'G': base = 7; break;
  case 'a':
  case 'A': base = 9; break;
  case 'b':
  case 'B': base = 11; break;
  default: return -1;
  }

  if (key[1] == '#') base++;
  if (key[1] == 'x') base += 2;
  if (key[1] == 'b') {
    base--;
    if (key[2] == 'b') base--;
  }
  base = base + (octave+5)*12;
  if (base <= 0 || base > 127) return -1;
  return base;
}

static Hand *new_hand()
{
  Hand *h;
 
  h = talloc(Hand, 1);
  h->skip = -1;
  h->ignore = -1;
  h->chordig = -1;
  h->noadjacent = -1;
  h->lookahead = -1;
  return h;
}

static Measure *new_measure(int number)
{
  Measure *m;

  m = talloc(Measure, 1);
  m->hand[LH] = new_hand();
  m->hand[RH] = new_hand();
  m->apart = -1;
  m->number = number;
  m->lines=make_rb();
  m->meter_num = 0;
  m->meter_den = 0;
  m->lcm = 0;
  m->tempo = 0;
  m->tempo_reset = 0;
  m->use_tempo = -1;
  m->keysig = NULL;
  m->rhkey = -1;
  m->lyrics = make_dl();
    m->view = nil;
  return m;
}

static void copy_line(Line *oldl, Line *newl)
{
  Dlist dtmp;
  Note *n, *nn;

  dl_traverse(dtmp, oldl->l) {
    n = (Note *) dtmp->val;
    nn = copy_note(n);
    dl_insert_b(newl->l, nn);
  }
  newl->tieto = oldl->tieto;
  newl->volperc = oldl->volperc;
  newl->program = oldl->program;
  newl->channel = oldl->channel;
  newl->noadjacent = oldl->noadjacent;
  newl->lookahead = oldl->lookahead;
}

static void copy_hand(Hand *oldh, Hand *newh)
{
  newh->skip = oldh->skip;
  newh->ignore = oldh->ignore;
  newh->chordig = oldh->chordig;
  newh->noadjacent = oldh->noadjacent;
  newh->lookahead = oldh->lookahead;
}

static void copy_measure(Measure *oldm, Measure *newm)
{
  Line *line, *ol;
  Rb_node tmp;
  Dlist dtmp;

  newm->meter_num = oldm->meter_num;
  newm->meter_den = oldm->meter_den;
  newm->lcm = oldm->lcm;
  copy_hand(oldm->hand[LH], newm->hand[LH]);
  copy_hand(oldm->hand[RH], newm->hand[RH]);
  newm->apart = oldm->apart;
  newm->tempo = oldm->tempo;
  newm->tempo_reset = oldm->tempo_reset;
  newm->use_tempo = oldm->use_tempo;
  newm->keysig = oldm->keysig;
  rb_traverse(tmp, oldm->lines) {
    ol = (Line *) tmp->v.val;
    line = new_line(tmp->k.key);
    rb_insert(newm->lines, line->name, line);
    copy_line(ol, line);
  }
  newm->rhkey = oldm->rhkey;
  dl_traverse(dtmp, oldm->lyrics) {
	  dl_insert_b(newm->lyrics, (void *) copy_note((Note *) dtmp->val));
  }
}

int do_repeat(IS is, Piece *p, int startm, int endm, int to)
{
  Measure *oldm;
  Measure *newm;
  int i;
  Rb_node rtmp;
  int fnd;

  for (i = startm; i <= endm; i++) {
    rtmp = rb_find_ikey_n(p->measures, to, &fnd);
    if (fnd) { mus_error(p, is, "Repeat -- measure(s) already exist"); return 0; }
    rtmp = rb_find_ikey_n(p->measures, i, &fnd);
    if (!fnd) { mus_error(p, is, "Repeat -- measure(s) do not exist"); return 0; }
    oldm = (Measure *) rtmp->v.val;
    newm = new_measure(to);
    copy_measure(oldm, newm);
    rb_inserti(p->measures, to, newm);
    to++;
  }
  return 1;
}
      

static Line *default_line(IS is, Line *l, Measure *m, char *linename, Piece *p)
{
  Rb_node tmp;
  int fnd;

  if (l == NULL && linename != NULL) {
    tmp = rb_find_key_n(m->lines, linename, &fnd);
    if (!fnd) {
      l = new_line(linename);
      rb_insert(m->lines, linename, l);
    } else {
      l = (Line *) tmp->v.val;
    }
  }
  if (l == NULL) { mus_error(p, is, "No active line"); return NULL; }
  return l;
}

int sprint_note(char *s, Note *n)
{
	if (n->name == NULL) return 0;
	if (n->octave == -100) {
		if (n->dur_num == 1) {
			sprintf(s, "      %-9s      %4d", n->name, n->dur_den);
		} else {
			sprintf(s, "      %-9s      %4d %4d", n->name, n->dur_den, n->dur_num);
		}
	} else {
		if (n->dur_num == 1) {
			sprintf(s, "      %-9s %4d %4d", n->name, n->octave, n->dur_den);
		} else {
			sprintf(s, "      %-9s %4d %4d %4d", n->name, n->octave, n->dur_den, n->dur_num);
		}
	}
	return 1;
}

Piece *read_mus_file(char *ifn)
{
  IS is;
  Piece *p;
  Measure *m, *oldm, *lm;
  Note *n;
  int i, k, h;
  int mn, oldmn;
  int fnd;
  Rb_node tmp, lastm, rtmp;
  Dlist dtmp;
  Line *l;
  char *linename;
  char *s;
  int startm, endm, to;
  double vp;

  p = NULL;
  m = NULL;
  n = NULL;
  l = NULL;
  linename = NULL;
  lastm = NULL;

  is = new_inputstruct(ifn);
  if (is == NULL) { 
	  s = talloc(char, strlen(ifn)+50);
	  sprintf(s, "Could not open %s", ifn);
	  mus_error(p, is, s);
	  free(s);
	  return NULL;
  }

  while(get_line(is) >= 0) {
    if (is->NF == 0 || is->fields[0][0] == '#') {
      /* Do nothing on nothing */
    } else if (strcmp(is->fields[0], "NAME") == 0) {
	  if (p != NULL) { mus_error(p, is, "Duplicate name"); return NULL; }
	  if (is->NF == 1) { mus_error(p, is, "NAME needs to specify a name"); return NULL; }
      p = talloc(Piece, 1);
        p->columns = 0;
	  p->autoplay = 0;
        p->bandplay = NO;
	  p->killonstop = 0;
	  p->strings = make_rb();
	  p->maxkey = -1;
	  p->minkey = -1;
	  p->lyrics = 0;
	  s = talloc(char, strlen(is->text1));
	  strcpy(s, "");
      for(i = 1; i < is->NF; i++) {
        if (i > 1) strcat(s, " ");
        strcat(s, is->fields[i]);
      }
	  p->name = new_string(p, s);
	  free(s);
      p->measures = make_rb();
      p->marks = make_rb();
	  p->anchors = make_rb();
      p->program = -1; 
    } else {
	  if (p == NULL) { mus_error(p, is, "Need a NAME field"); return NULL; }
      if (strcmp(is->fields[0], "MEASURE") ==0) {
      if (is->NF == 1 || atoi(is->fields[1]) <= 0) {
        mus_error(p, is, "Bad measure");
		return NULL;
      }
        if (strcmp(is->fields[1], "+1") == 0) {
		  if (m == NULL) { mus_error(p, is, "Bad +1"); return NULL; }
          mn = m->number +1;
        } else {
          mn = atoi(is->fields[1]);
        }
        lastm = rb_find_ikey_n(p->measures, mn, &fnd);
        if (!fnd) {
             m = new_measure(mn);
          lastm = rb_inserti(p->measures, mn, (char *)m);
        } else {
          m = (Measure *) lastm->v.val;
        }
        l = NULL;
        n = NULL;
        if (is->NF > 2 && strcmp(is->fields[2], "=REPEAT") == 0) {
          if (is->NF > 3) {
            oldmn = atoi(is->fields[3]);
          } else {
            oldmn = m->number-1;
          }
          tmp = rb_find_ikey_n(p->measures, oldmn, &fnd);
          if (!fnd) { mus_error(p, is, "Bad repeat spec"); return NULL; }
          oldm = (Measure *) tmp->v.val;
          copy_measure(oldm, m);
        }

      /* Set program */

	  } else if (strcmp (is->fields[0], "PROGRAM") == 0) {
	      if (is->NF < 2 || is->NF > 4) {
			  mus_error (p, is, "Program line should be PROGRAM num [bank-0] [bank-32]");
			  return NULL;
		  }
		  if (sscanf (is->fields[1], "%d", &i) != 1) {
			  mus_error (p, is, "Program line -- arg not an integer");
			  return NULL;
		  }
		  if (!(i == 0 && is->NF == 2) && (i <= 0 || i > 128)) {
			  mus_error (p, is, "Program line -- program number not between 0 & 128");
			  return NULL;
		  }              
		  i--;
		  if (is->NF > 2) {	        
			  if (sscanf (is->fields[2], "%d", &k) != 1) {  		  
				  mus_error (p, is, "Program line -- bank-0 not an integer");		  
				  return NULL;		
			  }                
			  if (k <= 0 || k > 128) {                   
				  mus_error (p, is, "Program line -- bank-0 not between 1 & 128");
				  return NULL;
			  }
			  i += (256 * k);
		  }
		  if (is->NF > 3) {
			  if (sscanf (is->fields[3], "%d", &k) != 1) {
				  mus_error (p, is, "Program line -- bank-32 not an integer");
				  return NULL;
			  }
			  if (k <= 0 || k > 128) {
				  mus_error (p, is, "Program line -- bank-32 not between 1 & 128");
				  return NULL;
			  }
			  i += (256*256*k);
		  }

	      if (n != NULL) {
		    n->program = i;
	      } else if (l != NULL) {
		    l->program = i;
	      } else {
		    p->program = i;
	      }

      /* Set channel */

      } else if (strcmp(is->fields[0], "CHANNEL") == 0) {
		if (is->NF != 2) { 
          mus_error(p, is, "Channel line should be CHANNEL num");
		  return NULL;
		}
        if (sscanf(is->fields[1], "%d", &i) != 1) {
            mus_error(p, is, "Channel line -- arg not an integer");
			return NULL;
		}
        if (i <= 0 && i > 16) { mus_error(p, is, "Channel must be in [1:16]"); return NULL; }
        if (n != NULL) {
          n->channel = i-1;
        } else if (l != NULL) {
          l->channel = i-1;
        } else {
          mus_error(p, is, "CHANNEL: no current note or line");
		  return NULL;
        }

      /* Set meter */

      } else if (strcmp(is->fields[0], "METER") == 0) {
		if (is->NF != 3) {mus_error(p, is, "Meter line should have num and den"); return NULL; }
        if (m == NULL) { mus_error(p, is, "No active measure"); return NULL; }
        m->meter_num = atoi(is->fields[1]);
        m->meter_den = atoi(is->fields[2]);
        if (m->meter_num == 0 || m->meter_den == 0) { mus_error(p, is, "0 meter"); return NULL; }

         /* Set tempo -- in whole notes per second */

      } else if (strcmp(is->fields[0], "USE") == 0) {
		if (is->NF != 2) { mus_error(p, is, "USE should be followed by TEMPO"); return NULL; }
        if (strcmp(is->fields[1], "TEMPO") != 0) {
          mus_error(p, is, "USE should be followed by TEMPO"); 
		  return NULL;
        }
        if (m == NULL) { mus_error(p, is, "No measure for USE TEMPO"); return NULL; }
        m->use_tempo = 1;

      } else if (strcmp(is->fields[0], "NO") == 0) {
		if (is->NF != 2) { mus_error(p, is, "NO should be followed by TEMPO"); return NULL; } 
        if (strcmp(is->fields[1], "TEMPO") != 0) {
          mus_error(p, is, "NO should be followed by TEMPO"); 
		  return NULL;
        }
        if (m == NULL) { mus_error(p, is, "No measure for NO TEMPO"); return NULL; }
        m->use_tempo = 0;

      } else if (strcmp(is->fields[0], "NOADJACENT") == 0) {
		  if (n != NULL) {
			  n->noadjacent = 1;
		  } else if (l != NULL) {
			  l->noadjacent = 1;
		  } else {
			  mus_error(p, is, "NOADJACENT: No current line or note.\n");
			  return NULL;
		  }

      } else if (strcmp(is->fields[0], "ADJACENT") == 0) {
		  if (n != NULL) {
			  n->noadjacent = 0;
		  } else if (l != NULL) {
			  l->noadjacent = 0;
		  } else {
			  mus_error(p, is, "ADJACENT: No current line or note.\n");
			  return NULL;
		  }
      } else if (strcmp(is->fields[0], "LOOKAHEAD") == 0) {
		  if (is->NF != 2 || sscanf(is->fields[1], "%d", &i) != 1 || i < 0) {
			  mus_error(p, is, "LOOKAHEAD -- needs a lookahead number (>= 0)");
			  return NULL;
		  }
		  if (n != NULL) {
			  n->lookahead = i;
		  } else if (l != NULL) {
			  l->lookahead = i;
		  } else {
			  mus_error(p, is, "LOOKAHEAD: No current line or note.\n");
			  return NULL;
		  }

      } else if (strcmp(is->fields[0], "TEMPO") == 0) {
        
        if (is->NF == 2 && strcmp(is->fields[1], "RESET") == 0) {
          if (n != NULL) {
            if (strncmp(l->name, "TL", 2) == 0) {
              mus_error(p, is, "TEMPO RESET on a note in a tie line");
			  return NULL;
            }
            n->tempo_reset = 1;
          } else if (m == NULL) {
            mus_error(p, is, "No note or measure for TEMPO RESET");
			return NULL;
          } else {
            m->tempo_reset = 1;
          }
        } else {
			if (is->NF != 3) { 
				mus_error(p, is, "Tempo line should have unit and bpm");
				return NULL;
			}
			if (m == NULL) { mus_error(p, is, "No active measure"); return NULL; }
			m->tempo = (double) atoi(is->fields[2]) / (double)atoi(is->fields[1]);
        }

        /* Key signature */

      } else if (strcmp(is->fields[0], "KEY") == 0) {
		  if (is->NF != 2) { mus_error(p, is, "KEY needs exactly one argument"); return NULL; }
		  if (m == NULL) { mus_error(p, is, "No active measure"); return NULL; }
			m->keysig = new_string(p, is->fields[1]);

        /* Repeat a bunch of measures */

      } else if (strcmp(is->fields[0], "REPEAT") == 0) {
		if (is->NF != 4) { mus_error(p, is, "usage: REPEAT START END TO"); return NULL; }
        startm = atoi(is->fields[1]);
        endm = atoi(is->fields[2]);
        to = atoi(is->fields[3]);
        if (endm < startm) { mus_error(p, is, "REPEAT: END must be >= START"); return NULL; }
        if (!do_repeat(is, p, startm, endm, to)) return NULL;
        l = NULL;
        m = NULL;
        n = NULL;
        linename = NULL;
        lastm = NULL;

        /* Copy a line */

      } else if (strcmp(is->fields[0], "LCOPY") == 0) {
          l = default_line(is, l, m, linename, p);
		  if (l == NULL) return NULL;
          if (is->NF == 1) { /* Copy from the last measure, this line */
          rtmp = rb_prev(lastm);
          if (rtmp == p->measures) { mus_error(p, is, "Can't copy from first measure"); return NULL; }
          lm = (Measure *) rtmp->v.val;
          rtmp = rb_find_key_n(lm->lines, linename, &fnd);
          if (!fnd) {
			  mus_error(p, is, "Can't copy from last measure -- no linename");
			  return NULL;
		  }
          copy_line((Line *)rtmp->v.val, l);
        } else if (is->NF == 2) { /* Copy from given line, this measure */
          rtmp = rb_find_key_n(m->lines, is->fields[1], &fnd);
          if (!fnd) { mus_error(p, is, "Bad linename"); return NULL; }
          copy_line((Line *)rtmp->v.val, l);
        } else if (is->NF == 3) { /* Copy from given line, given measure */
          rtmp = rb_find_ikey_n(p->measures, atoi(is->fields[2]), &fnd);
          if (!fnd) { mus_error(p, is, "Bad measure name"); return NULL; }
          lm = (Measure *) rtmp->v.val;
          rtmp = rb_find_key_n(lm->lines, is->fields[1], &fnd);
          if (!fnd) { mus_error(p, is, "Bad linename"); return NULL; }
          copy_line((Line *)rtmp->v.val, l);
        } else {
          mus_error(p, is, "Bad LCOPY line: usage: LCOPY [Linename [measureno]]");
		  return NULL;
        }

        /* Substitute one note for another */

      } else if (strcmp(is->fields[0], "NOTESUB") == 0) {
		  mus_error(p, is, "NOTESUB no longer supported");
		  return NULL;
		  /*
        if (is->NF < 4 || is->NF > 5 || is->NF == 4 
          && strcmp(is->fields[3], "REST") != 0) {
          mus_error(p, is, "NOTESUB beatden beatnum {key oct}|REST");
		  return NULL;
        }
        if (l == NULL) { mus_error(p, is, "NOTESUB: no line"); return NULL; }
        n = find_note_by_beat(l, atoi(is->fields[2]), atoi(is->fields[1]), 1);
        if (n == NULL) { mus_error(p, is, "BAD NOTESUB"); return NULL; }
        if (is->NF == 4) {
			n->name = new_string(p, "REST");
          n->key = 0;
        } else {
          n->key = mid_key(is->fields[3], atoi(is->fields[4]));
		  if (n->key < 0) {
			 mus_error(p, is, "bad key specification."); 
			 return NULL;
		  }
		  n->name = new_string(p, is->fields[3])
        } */

      /* Mark a measure with a name */
     
      } else if (strcmp(is->fields[0], "MARK") == 0) {
		if (is->NF != 2) { mus_error(p, is, "MARK name-of-mark"); return NULL; }
        s = new_string(p, is->fields[1]);
        if (s[0] >= '0' && s[0] <= '9') {
          mus_error(p, is, "Bad mark name -- can't begin with a digit");
		  return NULL;
        } 
        if (m == NULL) { mus_error(p, is, "MARK -- no current measure"); return NULL; }
        rb_find_key_n(p->marks, s, &fnd);
        if (fnd) { mus_error(p, is, "duplicate mark"); return NULL; }
        rb_insert(p->marks, s, m);

      /* Tie a note to a line */
     
      } else if (strcmp(is->fields[0], "VOLPERC") == 0){
		if (is->NF !=2) { mus_error(p, is, "VOLPERC volperc"); return NULL; }
        sscanf(is->fields[1], "%lf", &vp);
        if (vp < 0) { mus_error(p, is, "Can't have VOLPERC < 0"); return NULL; }
        if (n != NULL) {
          n->volperc = vp;
        } else if (l != NULL) {
          l->volperc = vp;
        } else {
          mus_error(p, is, "VOLPERC: no active line or note");
		  return NULL;
        }

      } else if (strcmp(is->fields[0], "RHNOTE") == 0){
		  if (is->NF != 3) { mus_error(p, is, "RHNOTE note octave"); return NULL; }
		  if (m == NULL) { mus_error(p, is, "RHNOTE: No active measure"); return NULL; }
		  m->rhkey = mid_key(is->fields[1], atoi(is->fields[2]));

      } else if (strcmp(is->fields[0], "EXMATCH") == 0){
		if (is->NF != 4 && is->NF != 3) { 
			  mus_error(p, is, "EXMATCH note octave [tolerance(0)]");
			  return NULL;
		}
        if (n == NULL) { mus_error(p, is, "EXMATCH: no active note"); return NULL; }
		if (n->key <= 0) { mus_error(p, is, "EXMATCH -- cannot exmatch a rest or carry"); return NULL; }
        if (l == NULL) { mus_error(p, is, "EXMATCH: no active line"); return NULL; }
		if (n->hint != NULL || n->anchor != NULL) {
			mus_error(p, is, "EXMATCH: The note already has a hint/anchor -- can't have both");
			return NULL;
		}
		if (n->exmatch == NULL) n->exmatch = (exmatch *) malloc(sizeof(exmatch));
		if (strcmp(is->fields[2], "Q") == 0) {
			char *notename;
			n->exmatch->qwert = 1;
			n->exmatch->height = -1;
			n->exmatch->fingerheight = -1;
			notename = qwert_to_note(is->fields[1], &(n->exmatch->octave));
	    	if (notename == NULL) { mus_error(p, is, "Bad exmatch specification"); return NULL; }
			n->exmatch->key = mid_key(notename, n->exmatch->octave);
	    	if (n->exmatch->key == -1) { mus_error(p, is, "Bad exmatch specification"); return NULL; }
		} else {
			n->exmatch->qwert = 0;
            n->exmatch->key = mid_key(is->fields[1], atoi(is->fields[2]));
		    if (n->exmatch->key == -1) { mus_error(p, is, "Bad exmatch specification"); return NULL; }
		    n->exmatch->octave = atoi(is->fields[2]);
		}
		n->exmatch->name = new_string(p, is->fields[1]);
		n->exmatch->lookahead = NULL;
		if (is->NF == 3) {
			n->exmatch->tolerance = 0;
		} else {
 			if (sscanf(is->fields[3], "%d", &n->exmatch->tolerance) != 1 || n->exmatch->tolerance < 0) {
				mus_error(p, is, "Bad exmatch specification (tolerance must be int >= 0)"); 
				return NULL;
			}
		}
      } else if (strcmp(is->fields[0], "ANCHOR") == 0){
		if (is->NF != 5 && is->NF != 4 && is->NF != 3) { 
			  mus_error(p, is, "ANCHOR note octave [sphere-den] [sphere-num]");
			  return NULL;
		}
        if (n == NULL) { mus_error(p, is, "ANCHOR: no active note"); return NULL; }
		if (n->key <= 0) { mus_error(p, is, "ANCHOR -- cannot anchor a rest or carry"); return NULL; }
        if (l == NULL) { mus_error(p, is, "ANCHOR: no active line"); return NULL; }
		if (n->hint != NULL || n->exmatch) {
			mus_error(p, is, "ANCHOR: The note already has a hint/exmatch -- can't have both");
			return NULL;
		}

		if (n->anchor == NULL) n->anchor = (Anchor *) malloc(sizeof(Anchor));
        n->anchor->key = mid_key(is->fields[1], atoi(is->fields[2]));
		if (n->anchor->key == -1) { mus_error(p, is, "Bad anchor specification"); return NULL; }
		n->anchor->name = new_string(p, is->fields[1]);
		n->anchor->octave = atoi(is->fields[2]);
		if (is->NF == 3) {
			n->anchor->sphere_den = 1;
			n->anchor->sphere_num = 0;
		} else {
 			if (sscanf(is->fields[3], "%d", &n->anchor->sphere_den) != 1 || n->anchor->sphere_den < 0) {
				mus_error(p, is, "Bad anchor specification"); 
				return NULL;
			}
			if (n->anchor->sphere_den == 0) {
				mus_error(p, is, "Bad anchor specification"); 
				return NULL;
			}
			if (is->NF == 4) {
				n->anchor->sphere_num = 1;
			} else {
				if (sscanf(is->fields[4], "%d", &n->anchor->sphere_num) != 1 || n->anchor->sphere_num < 0) {
					 mus_error(p, is, "Bad anchor specification"); 
					 return NULL;
				}
			}
		}
      } else if (strcmp(is->fields[0], "HINT") == 0){
		if (is->NF != 3) { 
			  mus_error(p, is, "HINT note octave");
			  return NULL;
		}
        if (n == NULL) { mus_error(p, is, "HINT: no active note"); return NULL; }
		if (n->key <= 0) { mus_error(p, is, "HINT -- cannot put a hint on a rest or carry"); return NULL; }
        if (l == NULL) { mus_error(p, is, "HINT: no active line"); return NULL; }
		if (n->anchor != NULL || n->exmatch != NULL) {
			mus_error(p, is, "HINT: The note already has a anchor/exmatch -- can't have both");
			return NULL;
		}

		if (n->hint == NULL) n->hint = (Anchor *) malloc(sizeof(Anchor));
        n->hint->key = mid_key(is->fields[1], atoi(is->fields[2]));
		if (n->hint->key == -1) { mus_error(p, is, "Bad hint specification"); return NULL; }
		n->hint->name = new_string(p, is->fields[1]);
		n->hint->octave = atoi(is->fields[2]);
		n->hint->sphere_den = 0;
		n->hint->sphere_num = 0;

      /* Turn off tying */
      } else if (strcmp(is->fields[0], "TIENOTE") == 0){
		if (is->NF!=2 && is->NF != 3) { 
			  mus_error(p, is, "TIENOTE lineon [lineoff]");
			  return NULL;
		}
        if (n == NULL) { mus_error(p, is, "TIENOTE: no active note"); return NULL; }
        if (l == NULL) { mus_error(p, is, "TIENOTE: no active line"); return NULL; }
        if (strncmp(l->name, "TL", 2) != 0) {
          mus_error(p, is, "Can only tie TLx lines to other lines");
		  return NULL;
        }
        n->tie_on = new_string(p, is->fields[1]);
        if (is->NF == 3) {
          n->tie_off = new_string(p, is->fields[2]);
        } else {
          n->tie_off = n->tie_on;
        }

      /* Turn off tying */
     
      } else if (strcmp(is->fields[0], "TIELINE") == 0){
		if (is->NF != 3) { mus_error(p, is, "TIELINE linename volperc"); return NULL; }
        if (l == NULL) { mus_error(p, is, "TIELINE: no active line"); return NULL; }
        if (strncmp(l->name, "TL", 2) != 0) {
          mus_error(p, is, "Can only tie TLx lines to other lines");
		  return NULL;
        }
        l->tieto = new_string(p, is->fields[1]);
        sscanf(is->fields[2], "%lf", &vp);
        if (vp < 0) { mus_error(p, is, "Can't have VOLPERC < 0"); return NULL; }
        l->volperc = vp;

        /* Transpose the line */

      } else if (strcmp(is->fields[0], "TRANSPOSE") == 0){
		if (is->NF != 2) { mus_error(p, is, "TRANSPOSE needs an argument"); return NULL; }
        if (l == NULL) { mus_error(p, is, "TRANSPOSE: no active line"); return NULL; }
        dl_traverse(dtmp, l->l) {
          n = (Note *) dtmp->val;
          if (n->key > 0) n->key += atoi(is->fields[1]);
          else if (n->key < 0) n->key -= atoi(is->fields[1]);
        }
        n = NULL;

        /* Hands apart or together */

      } else if (strcmp(is->fields[0], "TOGETHER") == 0 ||
                 strcmp(is->fields[0], "APART") == 0) {
		if (m == NULL) { mus_error(p, is, "No active measure"); return NULL; }
        m->apart = (strcmp(is->fields[0], "APART") == 0);

        /* Specify skip/ignore/chordig */

      } else if (strcmp(is->fields[0], "RH") == 0 || 
                 strcmp(is->fields[0], "LH") == 0) {
		if (m == NULL) { mus_error(p, is, "No active measure"); return NULL; }
        h = (strcmp(is->fields[0], "RH") == 0) ? RH : LH;
        for (i = 1; i < is->NF; i++) {
          if (strcmp(is->fields[i], "NOSKIP") == 0) {
            m->hand[h]->skip = 0;
            /* m->hand[1-h]->skip = 1; */
          } else if (strcmp(is->fields[i], "SKIP") == 0) {
            m->hand[h]->skip = 1;
          } else if (strcmp(is->fields[i], "NOIGNORE") == 0) {
            m->hand[h]->ignore = 0;
          } else if (strcmp(is->fields[i], "IGNORE") == 0) {
            m->hand[h]->ignore = 1;
          } else if (strcmp(is->fields[i], "NOCHORDIG") == 0) {
            m->hand[h]->chordig = 0;
          } else if (strcmp(is->fields[i], "CHORDIG") == 0) {
            m->hand[h]->chordig = 1;
          } else if (strcmp(is->fields[i], "NOSKIPIG") == 0) {
            m->hand[1-h]->skip = 1;
            m->hand[1-h]->ignore = 1;
            m->hand[h]->skip = 0;
            m->hand[h]->ignore = 0;
          } else if (strcmp(is->fields[i], "SKIPIG") == 0) {
            m->hand[h]->skip = 1;
            m->hand[h]->ignore = 1;
          } else if (strcmp(is->fields[i], "LOOKAHEAD") == 0) {
			  if (is->NF == i+1 || sscanf(is->fields[i+1], "%d", &k) != 1 || k < 0) {
				mus_error(p, is, "LOOKAHEAD -- needs a lookahead number (>= 0)");
				return NULL;
			  }
			  m->hand[h]->lookahead = k;
			  i++;
          } else if (strcmp(is->fields[i], "ADJACENT") == 0) {
            m->hand[h]->noadjacent = 0;
          } else if (strcmp(is->fields[i], "NOADJACENT") == 0) {
            m->hand[h]->noadjacent = 1;
          } else {
            mus_error(p, is, "Bad hand specification");
			return NULL;
          }
        }

        /* New line of notes */

      } else if (strcmp(is->fields[0], "LINE") == 0) {
		if (is->NF != 2) { mus_error(p, is, "Line should have a label");  return NULL; }
        if ((strncmp(is->fields[1], "LH", 2) != 0 &&
             strncmp(is->fields[1], "RH", 2) != 0 &&
             strncmp(is->fields[1], "TL", 2) != 0) || 
            strlen(is->fields[1]) <= 2) {
          mus_error(p, is, "Line name must be LHx, RHx or TLx");
		  return NULL;
        }
        if (m == NULL) { mus_error(p, is, "No active measure"); return NULL; }
        tmp = rb_find_key_n(m->lines, is->fields[1], &fnd);
        if (!fnd) {
          linename = new_string(p, is->fields[1]);
          l = new_line(linename);
          rb_insert(m->lines, linename, (char *) l);
        } else {
          l = (Line *) tmp->v.val;
          linename = tmp->k.key;
        }
        n = NULL;

        /* Add a new note to a line */

      } else if ((is->NF >= 2 || is->NF <= 5) && 
                 strcmp(is->fields[0], "PHANTOM") == 0) {
        l = default_line(is, l, m, linename, p);
		if (l == NULL) return NULL;
        n = new_note();
        dl_insert_b(l->l, n);
		n->name = new_string(p, "PHANTOM");
		n->octave = -100;
        n->key = 1;
        n->vol = 64;
        n->phantom = 1;
        i = 1;
        n->dur_den = atoi(is->fields[i++]);
        if (is->NF == i) {
          n->dur_num = 1;
        } else {
          n->dur_num = atoi(is->fields[i++]);
        }
        if (is->NF == i+1) n->dur_den *= atoi(is->fields[i]);

      } else if ((is->NF >= 3 || is->NF <= 6) && strlen(is->fields[0]) <= 3 &&
               ((is->fields[0][0] >= 'a' && is->fields[0][0] <= 'g') ||
             (is->fields[0][0] >= 'A' && is->fields[0][0] <= 'G'))) {
        l = default_line(is, l, m, linename, p);
		if (l == NULL) return NULL;
        n = new_note();
        dl_insert_b(l->l, n);
        n->key = mid_key(is->fields[0], atoi(is->fields[1]));
		if (n->key == -1) { mus_error(p, is, "Bad note specification"); return NULL; }
		n->name = new_string(p, is->fields[0]);
		n->octave = atoi(is->fields[1]);
        n->vol = 64;
        i = 2;
        if (strcmp(is->fields[2], "CARRY") == 0) {
			n->name = new_string(p, "CARRY");
			n->key = -n->key;
			n->octave = -100;
			i++;
        }
        n->dur_den = atoi(is->fields[i++]);
        if (is->NF == i) {
          n->dur_num = 1;
        } else {
          n->dur_num = atoi(is->fields[i++]);
        }
        if (is->NF == i+1) n->dur_den *= atoi(is->fields[i]);


        /* Specify to ripple this hand, this beat */

      } else if (strcmp(is->fields[0], "RIPPLE") == 0) {
        if (n == NULL) { mus_error(p, is, "No note to ripple"); return NULL; }
        n->ripple = 1;

        /* Specify to trill this note with another */

      } else if (strcmp(is->fields[0], "TRILL") == 0) {
        if (n == NULL) { mus_error(p, is, "No note to trill with"); return NULL; }
        if (is->NF != 3) { mus_error(p, is, "usage: TRILL key octave"); return NULL; }
        n->trill = 1;
        n->trillnote = copy_note(n);
        n->trillnote->key = mid_key(is->fields[1], atoi(is->fields[2]));
		if (n->trillnote->key == -1) { mus_error(p, is, "Bad Trill Key specification"); return NULL; }
		n->trillnote->name = new_string(p, is->fields[1]);
		n->trillnote->octave = atoi(is->fields[2]);

        /* Repeat the last note in different guises */

      } else if (strcmp(is->fields[0],"RNOTE") == 0 ||
                 strcmp(is->fields[0], "DOCT") == 0 ||
                 strcmp(is->fields[0], "UOCT") == 0 ||
                 strcmp(is->fields[0], "NU") == 0 ||
                 strcmp(is->fields[0], "ND") == 0 ||
                 strcmp(is->fields[0], "1D") == 0 ||
                 strcmp(is->fields[0], "1U") == 0 ||
                 strcmp(is->fields[0], "NN") == 0) {
		  mus_error(p, is, "RNOTE/DOCT/UOCT/NU/ND/1D/1U/NN no longer supported");
		  return NULL;
	  /*
        l = default_line(is, l, m, linename, p);
		if (l == NULL) return NULL;
        n = get_last_note(p, m, l, 0);
        if (n == NULL) { mus_error(p, is, "Bad RNOTE/DOCT/UOCT/NU/ND"); return NULL; }
        n = copy_note(n);
        if (is->fields[0][0] != 'R') {
          if (n->key < 0) n->key = -n->key;
          if (is->fields[0][0] == 'D') {
            n->key -= 12;
          } else if (is->fields[0][0] == 'U') {
            n->key += 12;
          } else {
			if (is->NF < 2 || is->NF > 4) { mus_error(p, is, "Needs a note"); return NULL; }
            i = mid_key(is->fields[1], 0);
            if (strcmp(is->fields[0], "NU") == 0) {
              while(i > n->key) i -= 12;
              while(i < n->key) i += 12;
            } else if (strcmp(is->fields[0], "ND") == 0) {
              while(i < n->key) i += 12;
              while(i > n->key) i -= 12;
            } else if (strcmp(is->fields[0], "1U") == 0) {
              while(i < n->key) i += 12;
              while(i > n->key) i -= 12;
              i += 12;
            } else if (strcmp(is->fields[0], "1D") == 0) {
              while(i < n->key) i += 12;
              while(i > n->key) i -= 12;
              i -= 12;
            } else {
              while(i - n->key > 6) i-= 12;
              while(n->key - i >= 6) i += 12;
            }
            n->key = i;
            if (is->NF > 2) {
              n->dur_den = atoi(is->fields[2]);
              if (is->NF == 4) {
                n->dur_num = atoi(is->fields[3]);
              } else {
                n->dur_num = 1;
              }
            }
          }
          if (n->key <=0 || n->key > 127) { 
			  mus_error(p, is, "Bad DOCT/UOCT: Range");
			  return NULL;
		  }
        }
        dl_insert_b(l->l, n);
         */
	  } else if (is->NF >= 4 && strcmp(is->fields[0], "LYRIC") == 0) {
	

		  if (m == NULL) { mus_error(p, is, "LYRIC -- no measure"); return NULL; }
		  p->lyrics = 1;
		  for (i = 2; i < is->NF && i < 5 && strcmp(is->fields[i], "%") != 0; i++) ;
		  if (i == is->NF || i == 5) {
			  mus_error(p, is, "Lyric line without a proper '%' character");
			  return NULL;
		  }
		  if (i+1 == is->NF) {
			  mus_error(p, is, "No lyrics specified after the % character");
			  return NULL;
		  }

		  n = new_note();
		  n->key = 1;
		  n->octave = -100;
		  n->dur_den = atoi(is->fields[1]);
		  if (i == 2) {
			  n->dur_num = 1;
		  } else {
			  n->dur_num = atoi(is->fields[2]);
		  }
		  if (i == 4) n->dur_den *= atoi(is->fields[3]);
		  is->text1[strlen(is->text1)-1] = '\0';
		  s = is->text1 + (is->fields[i+1]-is->text2);
		  n->name = new_string(p, s);
		  dl_insert_b(m->lyrics, (void *) n);
		  n = NULL;

         /* Add a rest or a carry */

	  } else if ((is->NF >= 2 && is->NF <= 4) && strcmp(is->fields[0], "LREST") == 0) {
		  if (m == NULL) { mus_error(p, is, "LREST - No Measure"); return NULL; }
		  n = new_note();
		  n->name = new_string(p, is->fields[0]);
		  n->octave = -100;
		  n->key = 0;
		  dl_insert_b(m->lyrics, (void *) n); 
		  n->vol = 100;
		  n->dur_den = atoi(is->fields[1]);
		  if (is->NF == 2) {
			  n->dur_num = 1;
		  } else {
			  n->dur_num = atoi(is->fields[2]);
		  }
		  if (is->NF == 4) n->dur_den *= atoi(is->fields[3]);

	  } else if ((is->NF >= 2 && is->NF <= 4) && 
               (strcmp(is->fields[0], "REST") == 0 ||
              strcmp(is->fields[0], "CARRY") == 0)) {
        l = default_line(is, l, m, linename, p);
		if (l == NULL) return NULL;
        if (strcmp(is->fields[0],"CARRY") == 0) {
			 n = get_last_note(p, m, l, 1);
			 if (n == NULL) {
                 mus_error(p, is, "Bad carry");
                 return NULL;
             }
			 k = n->key;
			 if (k > 0) k = -k;
        } else {
			 k = 0;
        }
        n = new_note();
		n->name = new_string(p, is->fields[0]);
		n->octave = -100;
        n->key = k;
        dl_insert_b(l->l, n); 
        n->vol = 100;
        n->dur_den = atoi(is->fields[1]);
        if (is->NF == 2) {
          n->dur_num = 1;
        } else {
          n->dur_num = atoi(is->fields[2]);
        }
        if (is->NF == 4) n->dur_den *= atoi(is->fields[3]);
      } else {
		  s = talloc(char , (strlen(is->text1)+30));
		  sprintf(s, "Unknown Line: %s", is->text1);
		  mus_error(p, is, s);
		  free(s);
		  return NULL;
	  }
    }
  }
  if (!double_check_piece(p, is->name))
      p = NULL;
  jettison_inputstruct(is);
  return p;
}

#define ON 0
#define OFF 1

//returns 1 if ok, 0 otherwise
static int set_tie(Measure *m, Line *l, Line *tln, Note *n, int onoff, Piece *p)
{
  Note *tn;
  Dlist dtmp;
  char s[1000];

  if (onoff == ON) {
    if (n->key <= 0) return 1;
  } else {
    if (n->carry != NULL) return 1;
    if (n->key == 0) return 1;
  }

  dl_traverse(dtmp, tln->l) {
    tn = (Note *) dtmp->val;
    if (onoff == ON) {
      if (tn->beat_on == n->beat_on && tn->grace_num == n->grace_num) {
        if (tn->key <= 0) {
          sprintf(s, "Error M: %d L: %s: Beat %d: %s %s %s",
                                m->number, l->name, n->beat_on,
                                "can't tie on to", tln->name, ": rest/carry.");
          mus_error(p, NULL, s);
		  return 0;
        }
        dl_insert_b(tn->on_ties, n);
        return 1;
      }
    } else if (onoff == OFF) {
      if (tn->beat_off == n->beat_off && tn->grace_num == n->grace_num) {
        if (tn->key == 0) {
          sprintf(s, "Error M: %d L: %s: Beat %d: %s %s %s",
                             m->number, l->name, n->beat_on,
                             "can't tie off to", tln->name, ": it's a rest.");
          mus_error(p, NULL, s);
		  return 0;
        }
        if (tn->carry != NULL) {
          sprintf(s, "Error M: %d L: %s: Beat %d: %s %s %s",
                             m->number, l->name, n->beat_on,
                             "can't tie off to", tln->name, 
                             ": it's a carried note.");
          mus_error(p, NULL, s);
		  return 0;
        }
        dl_insert_b(tn->off_ties, n);
        return 1;
      }
    }
  }
  sprintf(s, "Error M: %d L: %s: Beat %d: Can't tie to %s %d -- no matching note",
                   m->number, l->name, n->beat_on, tln->name, onoff);
  mus_error(p, NULL, s);
  return 0;
}
    

typedef struct { 
	Note *n;
	int left;
	int right;
} OverTmp;

// returns 1 if the piece is ok, and 0 otherwise.
int double_check_piece(Piece *p, char *fn)
{
  Measure *m, *m2;
  Measure *lastm;
  Dlist tmp, dtmp2, dtmp, stack;
  Line *line, *tln, *l, *l2;
  Rb_node rtmp, rtmp2, lrtmp, rtmp3, rhtree, lhtree, tptr, tree;
  Note *n, **lnotes, *n2;
  int lcm, nlcm, fnd, beat, i, gn, ok, hand, *lprograms, h, interrest,
      *lchannels, linetype, tlcmbeats, k, left, right, lastlcm, remainder;
  Rb_node linetree, overtree, lefttree, righttree, beattree;
  int apart, fudge, oldfudge, curm;
  char c;
  char s[1000];
  OverTmp *top, *ot;
  Anchor *a;
  double inters[2];
  double chorddurs[2];
  int exmatches[2];

  if (p == NULL) {
	  sprintf(s, "%s: Empty file", fn);
	  mus_error(p, NULL, s);
	  return 0;
  }

  /* First do one pass where you set the line number for each line.
     Line numbers increase lexicographically with the line name.
     We also set the p->start, and l->m for each line. */

  linetree = make_rb();

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      lrtmp = rb_find_key_n(linetree, line->name, &fnd);
      if (!fnd) {
        lrtmp = rb_insert(linetree, line->name, NULL);
      }
    }
  }

  p->tlines = 0;
  p->start[LH] = 0;
  c = 'L';
  rb_traverse(rtmp, linetree) {
    rtmp->v.val = (char *) p->tlines;
    if (rtmp->k.key[0] != c) {
      switch (c) {
        case 'L': p->start[RH] = p->tlines; c = 'R'; break;
        case 'R': p->start[TL] = p->tlines; c = 'T'; break;
        default: 
			sprintf(s, "Internal error: dcs: C = %c, L = %s", c, rtmp->k.key);
			mus_error(p, NULL, s);
			return 0;
      }
    }
    p->tlines++;
  }
  if (c == 'L') p->start[RH] = p->tlines;
  if (c == 'L' || c == 'R') p->start[TL] = p->tlines;

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      lrtmp = rb_find_key_n(linetree, line->name, &fnd);
      if (!fnd) {
			sprintf(s, "Internal error: dcs: No line in linetree: %s", 
                  line->name);
			mus_error(p, NULL, s);
			return 0;
      }
      line->number = (int) lrtmp->v.val;
    }
  }
  rb_free_tree(linetree);

  /* Done setting line numbers */

  /* Do main processing pass -- set keysig/meter/tempo/beats/hands/use_tempo/rhkey */

  apart = 0;
  lastm = NULL;
  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    if (m->apart == -1) m->apart = apart; else apart = m->apart;
	if (m->rhkey < 0) {
		m->rhkey = (lastm == NULL) ? 60 : lastm->rhkey;
	}
    if (m->keysig == NULL) {
      if (lastm == NULL) { mus_error(p, NULL, "No KEY signature specified"); return 0; }
      m->keysig =lastm->keysig;
    }
    if (m->meter_num == 0) {
      if (lastm == NULL) { mus_error(p, NULL, "No METER specified"); return 0; }
      m->meter_num = lastm->meter_num;
      m->meter_den = lastm->meter_den;
    }
    if (m->tempo == 0.0) {
      if (lastm == NULL) { mus_error(p, NULL, "No TEMPO specified"); return 0; }
      m->tempo = lastm->tempo;
    }
    if (m->use_tempo == -1) {
      m->use_tempo = (lastm == NULL) ? 1 : lastm->use_tempo;
    }

    for (hand = LH; hand <= RH; hand++) {
      if (m->hand[hand]->skip == -1) {
        m->hand[hand]->skip = (lastm == NULL) ? 1 : lastm->hand[hand]->skip;
      }
      if (m->hand[hand]->ignore == -1) {
        m->hand[hand]->ignore = (lastm == NULL) ? 1 : lastm->hand[hand]->ignore;
      }
      if (m->hand[hand]->chordig == -1) {
        m->hand[hand]->chordig = (lastm==NULL) ? 1 : lastm->hand[hand]->chordig;
      }
    }

    /* Calculate measure's beatid */

    if (lastm == NULL) {
      m->beatid = 0;
    } else {
      m->beatid = lastm->beatid + lastm->meter_num;
    }
	lastm = m;
  }

  /* Now, calculate one value of lcm for the entire piece, and a value of lcm for
     each measure. */

  p->lcm = 1;
  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
	lcm = m->meter_den;
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
        lcm = get_lcm(lcm, n->dur_den);
		if (n->anchor != NULL) lcm = get_lcm(lcm, n->anchor->sphere_den);
	  }
	}
	dl_traverse(tmp, m->lyrics) {
		n = (Note *) tmp->val;
		lcm = get_lcm(lcm, n->dur_den);
	}
	m->lcm = lcm;

	/* Now, make a second pass where you also set the lcm for measures who are influenced
	   by the sphere of anchors */

    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
 	  nlcm = 0;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
		if (n->anchor != NULL) {
			remainder = (n->anchor->sphere_num * (m->lcm/n->anchor->sphere_den)) - nlcm;
			lastlcm = m->lcm;
			rtmp3 = rb_prev(rtmp);
			while (remainder > 0 && rtmp3 != p->measures) {
				i = get_gcd(remainder, lastlcm);
				remainder /= i;
				lastlcm /= i;
				m2 = (Measure *) rtmp3->v.val;
				m2->lcm = get_lcm(m2->lcm, lastlcm);
				if (m2->lcm != lastlcm) remainder *= (m2->lcm / lastlcm);
				remainder -= (m2->meter_num * m2->lcm / m2->meter_den);
				lastlcm = m2->lcm;
				rtmp3 = rb_prev(rtmp3);
			}
		}
        nlcm += (n->dur_num * (m->lcm/n->dur_den));
	  }
	}
	m->lcm = lcm;
	p->lcm = get_lcm(p->lcm, m->lcm);
  }

  /* Now a big pass doing the following:
     - Check for the proper number of notes (beat-wise) in each line
	 - set m / beat_on / beat_off  / grace_num for all notes.  
	   Also set maxkey / minkey / linetype, gbeat_on / gbeat_off
	 */

  tlcmbeats = 0;
  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
	m->lcmbeatid = tlcmbeats;

    /* check for the proper number of notes in each line. */
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;

      nlcm = 0;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
        nlcm += (n->dur_num * (m->lcm/n->dur_den));
      }

      if (nlcm*m->meter_den > m->meter_num * m->lcm) {
        sprintf(s, "Measure %d Line %s: Too many notes.  Meter is %d/%d, but we have %d/%d", 
			m->number, line->name, m->meter_num, m->meter_den, nlcm, m->lcm);
		mus_error(p, NULL, s); 
		return 0;
      } else if (nlcm*m->meter_den < m->meter_num * m->lcm) {
//          nlcm = m->meter_num / m->meter_den * m->meter_den;
//          NSLog(@"corrected nlcm: %d", nlcm*m->meter_den == m->meter_num * m->lcm);
//          if (false) {
              sprintf(s, "Measure %d Line %s: Too few notes.  Meter is %d/%d, but we have %d/%d",
                      m->number, line->name, m->meter_num, m->meter_den, nlcm, m->lcm);
              mus_error(p, NULL, s);
              return 0;
         // }
	  }
    }
	tlcmbeats += nlcm;

	/* Do the same with the lyrics */

	nlcm = 0;
	dl_traverse(tmp, m->lyrics) {
		n = (Note *) tmp->val;
		nlcm += (n->dur_num * (m->lcm / n->dur_den));
	}
 
    if (nlcm*m->meter_den > m->meter_num * m->lcm) {
		sprintf(s, "Measure %d Lyrics: Too many notes.  Meter is %d/%d, but we have %d/%d", 
			m->number, m->meter_num, m->meter_den, nlcm, m->lcm);
		mus_error(p, NULL, s); 
		return 0;
	} else if (nlcm > 0 && nlcm*m->meter_den < m->meter_num * m->lcm) {
		sprintf(s, "Measure %d Lyrics: Too few notes.  Meter is %d/%d, but we have %d/%d", 
			m->number, m->meter_num, m->meter_den, nlcm, m->lcm);
		mus_error(p, NULL, s);
		return 0;
	}


    /* set m / beat_on / beat_off  / grace_num for all notes.  Also set maxkey / minkey / linetype,
	   gbeat_on / gbeat_off */

    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
	  if (line->name[0] == 'R') {
		  linetype = RH;
	  } else if (line->name[0] == 'L') {
		  linetype = LH;
	  } else {
		  linetype = TL;
	  }
      beat = 0;
      gn = 0;
	  fudge = 0;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
		n->m = m;
		if (n->trill) n->trillnote->m = m;
        n->linetype = n->key >= 60 ? RH : LH; // linetype;
        n->beat_on = beat;
        n->beatid = m->beatid + n->beat_on * m->meter_den / (double) m->lcm;
        beat += n->dur_num * m->lcm / n->dur_den;
        n->beat_off = beat;
        n->beatoffid = m->beatid + n->beat_off * m->meter_den / (double) m->lcm;
	    n->gbeat_on = n->beat_on + fudge;
		n->gtbeaton = m->lcmbeatid + n->gbeat_on;
		// Deal with grace notes at the end of the measure later.
	    if (n->dur_num == 0) { 
			fudge += (m->lcm / n->dur_den);
		    n->gbeat_off = n->gbeat_on + (m->lcm / n->dur_den);
		} else {
			n->gbeat_off = n->beat_off;
			fudge = 0;
		}

        if (n->dur_num == 0 && gn == 0) {
          dtmp2 = tmp;
          ok = 1;
		  n2 = n;
          while(ok) {
            gn++;
            dtmp2 = dtmp2->flink;
            if (dtmp2 == line->l) {
              ok = 0;
            } else {
              n2 = (Note *) dtmp2->val;
              ok = (n2->dur_num == 0);
            }
          }
		}

        n->grace_num = gn;
        if (gn > 0) gn--;
		if (n->key > 1) {
			if (p->maxkey < 0 || n->key > p->maxkey) p->maxkey = n->key;
			if (p->minkey < 0 || n->key < p->minkey) p->minkey = n->key;
		}
		if (n->trill && n->trillnote->key > 1) {
			if (p->maxkey < 0 || n->trillnote->key > p->maxkey) p->maxkey = n->trillnote->key;
			if (p->minkey < 0 || n->trillnote->key < p->minkey) p->minkey = n->trillnote->key;
		}
      }
	  /* Now deal with grace notes at the end of a measure */
	  dtmp = line->l->blink;
	  fudge = 0;
	  while (n != NULL && n->dur_num == 0) {
	  	oldfudge = fudge;
		fudge += (m->lcm / n->dur_den);
		n->gbeat_on = n->beat_on - fudge;
		n->gtbeaton = m->lcmbeatid + n->gbeat_on;
		n->gbeat_off = n->beat_off - oldfudge;
		dtmp = dtmp->blink;
		n = (Note *) dtmp->val;
	  }
	  if (fudge > 0) { // Last non-grace-note.
		n->gbeat_off = n->beat_off - fudge;
	  }
    }

	/* Do the same with lyrics */

	beat = 0;
	gn = 0;
	fudge = 0;
	dl_traverse(tmp, m->lyrics) {
		n = (Note *) tmp->val;
		n->m = m;
		n->linetype = LYRICS;
		n->beat_on = beat;
		n->beatid = m->beatid + n->beat_on * m->meter_den / (double) m->lcm;
		beat += n->dur_num * m->lcm / n->dur_den;
		n->beat_off = beat;
		n->beatoffid = m->beatid + n->beat_off * m->meter_den / (double) m->lcm;
		n->gbeat_on = n->beat_on + fudge;
		n->gtbeaton = m->lcmbeatid + n->gbeat_on;
		n->gbeat_off = n->beat_off;
		fudge = 0;
		n->grace_num = gn;
	}
  }


  /* Now, check that all notes on a beat are either EXMATCH or not.  Moreover,
     set maxchorddur and mininterspace for all notes, according to beats.  The way
	 I'm going to do this is to make a rbtree of gbeatid's.  Key = gbeatid.  Val
	 = a rbtree list of notes keyed on line name whose beatid is that beatid.  
	 Then you can set stuff.

     Grace notes may well mess things up.
	 */

  for (i = 0; i < 2; i++) {
	  inters[i] = 0.04;
	  chorddurs[i] = 0.2;
  }

  rb_traverse(rtmp, p->measures) {
	m = (Measure *) rtmp->v.val;
	beattree = make_rb();

    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
	  if (line->name[0] != 'T') {
		  dl_traverse(tmp, line->l) {
			  n = (Note *) tmp->val;
			  rtmp3 = rb_find_ikey_n(beattree, n->gbeat_on, &fnd);
			  if (!fnd) {
				  rtmp3 = rb_inserti(beattree, n->gbeat_on, (void *) make_rb());
			  }
			  tree = (Rb_node) rtmp3->v.val;
			  rb_insert(tree, line->name, (void *) n);
		  }
	  }
	}
	rb_traverse(rtmp2, beattree) {
		tree = (Rb_node) rtmp2->v.val;
		exmatches[LH] = -1;
		exmatches[RH] = -1;
		rb_traverse(rtmp3, tree) {
			n = (Note *) rtmp3->v.val;
			if (n->key > 0) {
				if (exmatches[n->linetype] != -1 && exmatches[n->linetype] != (n->exmatch != NULL)) {
					sprintf(s, "Error M: %d (%s %d %d %d %d) All notes on a beat must have the same exmatch", 
						m->number, n->name, n->octave, n->gbeat_on, n->linetype, rtmp2->k.ikey);
					mus_error(p, NULL, s);
					return 0;
				}
				exmatches[n->linetype] = (n->exmatch != NULL);
				if (n->mininterspace != -1.0) {
					inters[n->linetype] = n->mininterspace;
				}
				if (n->maxchorddur != -1.0) {
					chorddurs[n->linetype] = n->maxchorddur;
				}
			} 
		}
		rb_traverse(rtmp3, tree) {
			n = (Note *) rtmp3->v.val;
			n->maxchorddur = chorddurs[n->linetype];
			n->mininterspace = inters[n->linetype];
		}
		rb_free_tree(tree);
	}
	rb_free_tree(beattree);
  }

  /* Make sure that no measure has skip = 0 for both hands */

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    /* if (!m->hand[LH]->skip && !m->hand[RH]->skip) {
      sprintf(s, "Error M: %d At least one hand must have SKIP set", m->number);
	  mus_error(p, NULL, s);
      return 0;
    } */
    if (!m->hand[LH]->chordig && m->hand[LH]->ignore) {
      sprintf(s, "Error M: %d LH: Can't have IGNORE and NOCHORDIG", m->number);
	  mus_error(p, NULL, s);
      return 0;
    }
    if (!m->hand[RH]->chordig && m->hand[RH]->ignore) {
      sprintf(s, "Error M: %d RH: Can't have IGNORE and NOCHORDIG", m->number);
	  mus_error(p, NULL, s);
      return 0;
    }
  }

  /* Set the program changes/channels of all the notes */

  lprograms = talloc(int, p->tlines);
  lchannels = talloc(int, p->tlines);
  for (i = 0; i < p->tlines; i++) lprograms[i] = -1;
  for (i = 0; i < p->tlines; i++) lchannels[i] = -1;
  lnotes = talloc(Note *, p->tlines);
  for (i = 0; i < p->tlines; i++) lnotes[i] = NULL;

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
        if (line->program != -1 && tmp == line->l->flink) {
          n->program = line->program;
        } else if (lnotes[line->number] != NULL) {
          n->program = lnotes[line->number]->program;
        } else if (lprograms[line->number] != -1) {
          n->program = lprograms[line->number];
        } else { 
          n->program = p->program;
        }
        if (n->trill) n->trillnote->program = n->program;
        if (line->channel != -1 && tmp == line->l->flink) {
          n->channel = line->channel;
        } else if (lnotes[line->number] != NULL) {
          n->channel = lnotes[line->number]->channel;
        } else if (lchannels[line->number] != -1) {
          n->channel = lchannels[line->number];
        } else { 
          n->channel = 0;
        }
        if (n->trill) n->trillnote->channel = n->channel;
        lnotes[line->number] = n;
      }
      if (line->program == -1 && lprograms[line->number] == -1) {
        line->program = p->program;
      } else if (line->program == -1) {
        line->program = lprograms[line->number];
      }
      if (line->channel == -1 && lchannels[line->number] == -1) {
        line->channel = 0;
      } else if (line->channel == -1) {
        line->channel = lchannels[line->number];
      }
      lprograms[line->number] = line->program;
      lchannels[line->number] = line->channel;
    }
  }
  free(lprograms);
  free(lchannels);
  free(lnotes);
 
  /* Now -- set the tie_on/tie_off lines for every note.  The way it 
     works is as follows:  If n->tie_on != tie_dfl, then do nothing --
     it was explictly set.  Otherwise, set it to whatever the last note
     in the line was.   If this is the first note in the measure, then
     the "last note" is the last note of the most recent measure that the
     line was in.  Note that this can skip measures.  If this is the first
     note of the line in the piece, then tie_dfl means NULL. We keep
     track of the last note in a line with an array of notes keyed
     by the line's number.  We set volperc similarly -- -1 is the unset
     default. And we set noadjacent/lookahead similarly.  */

  /* First, set noadjacent/lookahead for all lines from their hand spec. */

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
	for (h = LH; h <= RH; h++) {
		if (m->hand[h]->noadjacent != -1) {
          rb_traverse(rtmp2, m->lines) {
			  line = (Line *) rtmp2->v.val;
			  if (line->noadjacent < 0 && line->number >= p->start[h] && 
				  line->number < p->start[h+1]) {
				  line->noadjacent = m->hand[h]->noadjacent;
			  }
		  }
		}
		if (m->hand[h]->lookahead != -1) {
          rb_traverse(rtmp2, m->lines) {
			  line = (Line *) rtmp2->v.val;
			  if (line->lookahead < 0 && line->number >= p->start[h] && 
				  line->number < p->start[h+1]) {
				  line->lookahead = m->hand[h]->lookahead;
			  }
		  }
		}
	}
  }

  lnotes = talloc(Note *, p->tlines);
  for (i = 0; i < p->tlines; i++) lnotes[i] = NULL;

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      i = 0;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
        if (n->key < 0) {   /* Set carry of last note to me -- note
                               that this is safe, because the previous
                               error checking makes sure that there is
                               a note to carry from */
          lnotes[line->number]->carry = n;
		  n->backcarry = lnotes[line->number];
          if (lnotes[line->number]->trill) {
            n->trillnote = copy_note(n);
            n->trill = 1;
            n->trillnote->key = lnotes[line->number]->trillnote->key;
            n->trillnote->name = lnotes[line->number]->trillnote->name;
            n->trillnote->volperc = lnotes[line->number]->trillnote->volperc;
            lnotes[line->number]->trillnote->carry = n->trillnote;
			n->trillnote->backcarry = lnotes[line->number]->trillnote;
          }
        }
        /* Set tie lines */
        if (line->number >= p->start[TL]) {
          if (n->tie_on == tie_dfl) {
            if (i == 0 && line->tieto != NULL) {
              n->tie_on = line->tieto;
              n->tie_off = line->tieto;
            } else if (lnotes[line->number] == NULL) {
				if (n->key != 0) {
					sprintf(s, "Error M: %d L: %s: no tie to for this note",
                      m->number, line->name);
					mus_error(p, NULL, s);
					return NULL;
				}
            } else {
              n->tie_on = lnotes[line->number]->tie_off;
              n->tie_off = lnotes[line->number]->tie_off;
            }
          }
        }
        /* Set volperc */
        if (n->volperc < 0) {
		  if (i == 0 && line->volperc >= 0) { // i == 0 means that this is the first note in the line.
            n->volperc = line->volperc;
          } else if (lnotes[line->number] == NULL) {
            n->volperc = 100.0;
          } else {
            n->volperc = lnotes[line->number]->volperc;
          }
        }
        /* Set volperc of trill notes */
        if (n->trill) {
          if (n->trillnote->volperc < 0) {
            if (i == 0 && line->volperc >= 0) {
              n->trillnote->volperc = line->volperc;
            } else if (lnotes[line->number] == NULL) {
              n->trillnote->volperc = 100.0;
            } else {
              n->trillnote->volperc = lnotes[line->number]->volperc;
            }
          }
        }
		if (n->noadjacent < 0) {
			if (i == 0 && line->noadjacent >= 0) {
				n->noadjacent = line->noadjacent;
			} else if (lnotes[line->number] == NULL) {
				n->noadjacent = 0;
			} else {
				n->noadjacent = lnotes[line->number]->noadjacent;
			}
		}
		if (n->lookahead < 0) {
			if (i == 0 && line->lookahead >= 0) {
				n->lookahead = line->lookahead;
			} else if (lnotes[line->number] == NULL) {
				n->lookahead = 0;
			} else {
				n->lookahead = lnotes[line->number]->lookahead;
			}
		}
        lnotes[line->number] = n;
        i++;
      }
    }
  }
  free(lnotes);

  /* Now, set n->carrytc to be the transitive closure of n->carry, and n->backcarrytc
     to be the transitive closure of n->backcarry. */

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;

	dl_traverse(tmp, m->lyrics) {
		n = (Note *) tmp->val;
		n->carry = NULL;
		n->backcarry = NULL;
		n->carrytc = n;
		n->backcarrytc = n;
	}

    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
		/* This is not making much sense to me.  I'm rewriting, and keeping this
		   in case the rewrite does not work 
        if (n->carrytc != NULL) {
          for (n2 = n->carrytc->carrytc; n2 != NULL; n2 = n->carrytc->carrytc) {
            n->carrytc->carrytc = n2;
            n->carrytc = n2;
          }
        } else {
			n->carrytc = n;
		} 
        if (n->trill) {
          if (n->trillnote->carrytc != NULL) {
            for (n2 = n->trillnote->carrytc->carrytc; n2 != NULL; 
                 n2 = n->trillnote->carrytc->carrytc) {
              n->trillnote->carrytc->carrytc = n2;
              n->trillnote->carrytc = n2;
            }
          } else {
			  n->trillnote->carrytc = n->trillnote;
		  }
        }  */
		for (n2 = n; n2->carry != NULL; n2 = n2->carry) ; 
		n->carrytc = n2;
		if (n->trill) {
			for (n2 = n->trillnote; n2->carry != NULL; n2 = n2->carry) ;
			n->trillnote->carrytc = n2;
		}
		for (n2 = n; n2->backcarry != NULL; n2 = n2->backcarry) ; 
		n->backcarrytc = n2;
		if (n->trill) {
			for (n2 = n->trillnote; n2->backcarry != NULL; n2 = n2->backcarry) ;
			n->trillnote->backcarrytc = n2;
		}
      }
    }
  } 

  /* Ok -- now, resolve the tieon/tieoff's.  I.e. put the tie-ons
     into tie-on lists, and put the tie-offs into tie-off lists.
     Don't worry about carries.    */

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      dl_traverse(tmp, line->l) {
        n = (Note *) tmp->val;
        n->on_ties = make_dl();
        n->off_ties = make_dl();
        if (n->trill) {
          n->trillnote->on_ties = make_dl();
          n->trillnote->off_ties = make_dl();
        }

      }
    }
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      if (line->number >= p->start[TL]) {
        dl_traverse(tmp, line->l) {
          n = (Note *) tmp->val;
		  if (n->key > 0) {
              rtmp3 = rb_find_key_n(m->lines, n->tie_on, &fnd);
              if (!fnd)  {
                sprintf(s, "Error M: %d L: %s: Beat %d: tie on. no line %s",
                                m->number, line->name, n->beat_on, n->tie_on);
		    	mus_error(p, NULL, s);
                return 0;
              }
              tln = (Line *) rtmp3->v.val;
              if (!set_tie(m, line, tln, n, ON, p)) return 0;
		  }
		  if (n->key != 0 && n->carry == NULL) {
               rtmp3 = rb_find_key_n(m->lines, n->tie_off, &fnd);
                if (!fnd)  {
                  sprintf(s, "Error M: %d L: %s: Beat %d: tie off. %s %s",
                                  m->number, line->name, n->beat_off, 
                                  "no line", n->tie_off);
 			      mus_error(p, NULL, s);
                  return 0;
				}
                tln = (Line *) rtmp3->v.val;
                if (!set_tie(m, line, tln, n, OFF, p)) return 0;
		  }
        }
      }
    }
  }

  /* Now, if ripple has been set for any note of a chord, then it needs to be
     set for all the notes in that chord for displaying purposes.  Yes, this looks
     ugly, but it's a decent algorithm.  Cleaner ones are O(number of lines^2) */

  i = 0;

  rb_traverse(rtmp, p->measures) {
    rhtree = make_rb();   /* Both of these trees are keyed on the beatid.  If there is */
    lhtree = make_rb();   /* an entry, then that means there is a ripple in that hand on that beat */
    m = (Measure *) rtmp->v.val;
    rb_traverse(rtmp2, m->lines) { /* First, identify beats with ripples */
      line = (Line *) rtmp2->v.val;
	  if (line->name[0] != 'T') {
		  dl_traverse(tmp, line->l) {
			n = (Note *) tmp->val;
			if (n->ripple) {
				rtmp3 = rb_find_ikey_n((line->name[0] == 'R') ? rhtree : lhtree, n->beat_on, &fnd);
				if (!fnd) {
					rb_inserti((line->name[0] == 'R') ? rhtree : lhtree, n->beat_on, NULL);
				}
			}
		  }
	  }
	}
    rb_traverse(rtmp2, m->lines) { /* Now, go through and set n->ripple */
		line = (Line *) rtmp2->v.val;
		if (line->name[0] == 'R') {
			tree = rhtree;
		} else if (line->name[0] == 'L') {
			tree = lhtree;
		} else {
			tree = NULL;
		}
		if (tree != NULL && !rb_empty(tree)) {
			tptr = rb_first(tree);
			dl_traverse(tmp, line->l) {
				n = (Note *) tmp->val;
				while (tptr != tree && n->beat_on > tptr->k.ikey) tptr = rb_next(tptr);
				if (tptr != tree && n->key > 0 && tptr->k.ikey == n->beat_on && n->dur_num != 0) {
					n->ripple = (line->name[0] == 'R') ? 2 : 1;
				}
			}
		}
	}
	rb_free_tree(lhtree);
	rb_free_tree(rhtree);
  }

    /* Now, traverse the piece, and set up all the anchors by putting them into
	   p->anchors indexed by when their sphere starts. */

	rb_traverse(rtmp, p->measures) {
		m = (Measure *) rtmp->v.val;
		rb_traverse(rtmp2, m->lines) {
			l = (Line *) rtmp2->v.val;
 			nlcm = 0;
			dl_traverse(tmp, l->l) {
				n = (Note *) tmp->val;
				if (n->anchor != NULL) {
					a = n->anchor;
					remainder = (a->sphere_num * (m->lcm/a->sphere_den)) - nlcm;
					lastlcm = m->lcm;
					rtmp3 = rb_prev(rtmp);
					m2 = m;
					while (remainder > 0 && rtmp3 != p->measures) {
						i = get_gcd(remainder, lastlcm);
						remainder /= i;
						lastlcm /= i;
						m2 = (Measure *) rtmp3->v.val;
						if (m2->lcm != lastlcm) remainder *= (m2->lcm / lastlcm); // This should be ok.
						remainder -= (m2->meter_num * m2->lcm / m2->meter_den);
						lastlcm = m2->lcm;
						rtmp3 = rb_prev(rtmp3);
					}
					if (remainder > 0) remainder = 0;
					remainder = -remainder;
					rb_inserti(p->anchors, remainder + m2->lcmbeatid, (void *) n);
				}
				nlcm += (n->dur_num * (m->lcm/n->dur_den));
			}
		}
	}

	/* Now, double-check the anchors.  Do this by maintaining a rb-tree keyed on anchor
	   key.  The val field is a pointer to the last note whose anchor key was this key.
	   When you see a new anchor, you check to see that its current key in this tree is
	   done.  I'm going to use overtree as my tree.  Perhaps a bad name, but I don't feel
	   like declaring another variable. */

	overtree = make_rb();
	rb_traverse(rtmp, p->anchors) {
		n = (Note *) rtmp->v.val;
		a = n->anchor;
		rtmp2 = rb_find_ikey_n(overtree, a->key, &fnd);
		if (fnd) {
			n2 = (Note *) rtmp2->v.val;
			if (rtmp->k.ikey <= n2->gtbeaton) {
				sprintf(s, "m: %d beat %d/%d: Anchor clash at anchor note %s%d", 
					n->m->number, n->beat_on, n->m->meter_num*n->m->lcm/n->m->meter_den, 
					a->name, a->octave);
 				mus_error(p, NULL, s);
				rb_free_tree(overtree);
				return 0;
			}
			rtmp2->v.val = (void *) n;
		} else {
			rb_inserti(overtree, a->key, (void *) n);
		}
	}
	rb_free_tree(overtree);

	/* Now, set lookahead for all notes that need it.  A note needs lookahead if:
	   - It is an exmatch.
	   - Its lookahead is set to something greater than zero.
	   - The next note in that line (skipping carries and rests) also is an exmatch.
	   - If there is a rest between this note and the next, then the beginning of this
	     note and the beginning of the next must be in the same or consecutive measures.
	 */


	rb_traverse(rtmp, p->measures) {
		m = (Measure *) rtmp->v.val;
		rb_traverse(rtmp2, m->lines) {
			l = (Line *) rtmp2->v.val;
			dl_traverse(tmp, l->l) {
				n = (Note *) tmp->val;
				if (n->exmatch != NULL && n->lookahead > 0) {
					curm = m->number;
					m2 = m;
					dtmp = tmp->flink;
					l2 = l;
					ok = 1;
					interrest = 0;
					while (ok) {
						if (dtmp != l2->l) {
							n2 = (Note *) dtmp->val;
							if (n2->key > 0) {
								if (n2->exmatch != NULL && 
									(interrest == 0 || m2->number <= m->number+1)) {
									n->exmatch->lookahead = n2;
									// fprintf(tfp, "%d %s %s%d -> %s%d\n", m->number, l->name, 
									//	n->name, n->octave, n2->name, n2->octave);
								}
								ok = 0;
							} else {  // Skip rests and carries
								if (n2->key == 0) interrest = 1;
								dtmp = dtmp->flink;
							}
						} else {
							curm++;
							rtmp3 = rb_find_ikey_n(p->measures, curm, &fnd);
							if (!fnd) {
								ok = 0;
							} else {
								m2 = (Measure *) rtmp3->v.val;
								rtmp3 = rb_find_key_n(m2->lines, l->name, &fnd);
								if (!fnd) {
									ok = 0;
								} else {
									l2 = (Line *) rtmp3->v.val;
									dtmp = l2->l->flink;
								}
							}
						}
					}
				}
			}
		}
	}

  	/* Now, set n->overlapping for every note in the piece.  This is a big job.
	
	   If a note is carried,
	   then don't set n->overlapping for the note.  The 
	   setting of n->overlapping works as follows.  First we put each note that
	   can potentially have a n->overlapping entry into
	   a red-black tree keyed on key value. The val field is dlist of these
	   notes.  We'll process them in a second pass of overtree. */

	overtree = make_rb();
	rb_traverse(rtmp, p->measures) {
		m = (Measure *) rtmp->v.val;
		rb_traverse(rtmp2, m->lines) {
			l = (Line *) rtmp2->v.val;
			dl_traverse(tmp, l->l) {
				n = (Note *) tmp->val;
				if (n->key > 0) { /* Don't worry about carrys and phantoms */
					k = n->key;
					rtmp3 = rb_find_ikey_n(overtree, k, &fnd);
					if (fnd) {
						dtmp = (Dlist) rtmp3->v.val;
					} else {
						dtmp = make_dl();
						rb_inserti(overtree, k, (void *) dtmp);
					}
					dl_insert_b(dtmp, (void *) n);
				}
			}
		}
	}

	/* Now, for each key in overtree, we are going to create a two-level rb-tree.
	   The first level is keyed on n->gtbeaton.  The second level is keyed on 
	   n2->gtbeaton-n2->gbeat_on + n2->gbeat_off where n2 is n->carrytc, 
	   times three, plus 0 for RH, 1 for LH, 2 for TL.  What a hack. */

	rb_traverse(rtmp, overtree) {
		lefttree = make_rb();
		dtmp = (Dlist) rtmp->v.val;
		dl_traverse(tmp, dtmp) {
			n = (Note *) tmp->val;
			n2 = n->carrytc;
			left = n->gtbeaton;
			right = n2->gtbeaton - n2->gbeat_on + n2->gbeat_off;
			rtmp3 = rb_find_ikey_n(lefttree, left, &fnd);
			if (fnd) {
				righttree = (Rb_node) rtmp3->v.val;
			} else {
				righttree = make_rb();
				rb_inserti(lefttree, left, (void *) righttree);
			}
			i = right * 3;
			if (n->linetype == TL) i += 2; else if (n->linetype == LH) i++;
			rb_inserti(righttree, i, (void *) n);
		}
		dl_delete_list(dtmp);

		/* Now, walk lefttree/righttree (walk righttree backwards)
		   and maintain a stack of playing notes.  Use this to
		   add entries to set n->overlapping */

		stack = make_dl();
		top = NULL;

		rb_traverse(rtmp2, lefttree) {
			righttree = (Rb_node) rtmp2->v.val;
			rb_rtraverse(rtmp3, righttree) {
				n = (Note *) rtmp3->v.val;
				if (n->overlappers != NULL) dl_delete_list(n->overlappers);
				n->overlappers = make_dl();
				ot = (OverTmp *) malloc(sizeof(OverTmp));
				ot->n = n;
				ot->left = rtmp2->k.ikey;
				ot->right = rtmp3->k.ikey;
				while(top != NULL && top->right / 3 <= ot->left) {
					free(top);
					dl_delete_node(stack->blink);
					if (dl_empty(stack)) top = NULL; else top = (OverTmp *) stack->blink->val;
				}
				if (top != NULL) {
					dl_insert_b(top->n->overlappers, (void *) n);
				}
				dl_insert_b(stack, (void *) ot);
				top = ot;
			}
			rb_free_tree(righttree);
		}
		rb_free_tree(lefttree);
		dl_traverse(tmp, stack) {
			ot = (OverTmp *) tmp->val;
			free(ot);
		}
		dl_delete_list(stack);

	}
	rb_free_tree(overtree);
	set_exmatch_heights(p);
	return 1;
}

void set_exmatch_heights(Piece *p)
{
	Rb_node overtree, rtmp, rtmp2, tree, rtmp3;
	Measure *m, *inm;
	Rb_node starting_ptr;
	Line *line;
	Dlist tmp;
	Note *n;
	int i, fnd;

	/* Set n->exmatch->height for all qwerts.  This is the row in which the name
	   of the note will be printed.  To do this, we create an rbtree of gtbeaton for
	   each qwert'd note.  Then we traverse it, assigning heights for each "unit".
	   I'll define that algorithm when I've written the code.

	   So that I can reuse variables, I'm going to use overtree as the tree. (ok, 
	   there's now no need to reuse variables, because I broke this code out of
	   double_check_piece()).
	*/

	for(i = 0; i < 2; i++) {
	  overtree = make_rb();
	  rb_traverse(rtmp, p->measures) {
		m = (Measure *) rtmp->v.val;
		rb_traverse(rtmp2, m->lines) {
			line = (Line *) rtmp2->v.val;
			if (line->name[0] == ((i == RH) ? 'R' : 'L')) {
				dl_traverse(tmp, line->l) {
					n = (Note *) tmp->val;
					if (n->exmatch != NULL && n->exmatch->qwert) {
						rtmp3 = rb_find_ikey_n(overtree, n->gtbeaton, &fnd);
						if (fnd == 0) {
							rtmp3 = rb_inserti(overtree, n->gtbeaton, (void *) make_rb());
						}
						tree = (Rb_node) rtmp3->v.val;
						rb_inserti(tree, line->number, (void *) n);
					}
				}
			}
		}
	  }
	  inm = NULL;
	  p->heights[i] = 0;
	  int j;

	  rb_traverse(rtmp, overtree) {
		  tree = (Rb_node) rtmp->v.val;
		  rb_traverse(rtmp2, tree) {
			  n = (Note *) rtmp2->v.val;
			  if (inm != NULL && n->m->number > inm->number) {
				  j = insert_note_heights(overtree, starting_ptr, rtmp);
				  if (j > p->heights[i]) p->heights[i] = j;
				  inm = NULL;
			  }
			  if (inm == NULL) {
				  inm = n->carrytc->m;
				  starting_ptr = rtmp;
			  }
			  if (n->carrytc->m->number > inm->number) inm = n->carrytc->m;
		  }
	  }
	  if (inm != NULL) {
		  j = insert_note_heights(overtree, starting_ptr, rtmp);
		  if (j > p->heights[i]) p->heights[i] = j;
	  }
	  rb_traverse(rtmp, overtree) {
		  tree = (Rb_node) rtmp->v.val;
		  rb_free_tree(tree);
	  }
	  rb_free_tree(overtree);
	}
	p->qwertyheight = (p->heights[0] + p->heights[1]);
}

// returns 1 if the piece is ok, and 0 otherwise.

int resolve_grace_notes(Piece *p)
{
  Rb_node rtmp, rtmp2;
  Dlist tmp, tmp2;
  Measure *m;
  Line *line;
  int gcount;
  Note *n, *lastn;
  char s[1000];

  /* Now, do another preprocessing pass.  This time, resolve grace notes  */

  rb_traverse(rtmp, p->measures) {
    m = (Measure *) rtmp->v.val;
    rb_traverse(rtmp2, m->lines) {
      line = (Line *) rtmp2->v.val;
      lastn = NULL;
      dl_traverse(tmp, line->l) {
        gcount = 0;
        n = (Note *) tmp->val;
        if (n->dur_num == 0) {
          tmp2 = tmp;
          while(n != NULL && n->dur_num == 0) {
            gcount += m->lcm / n->dur_den;
            n->dur_num = 1;
            tmp2 = tmp2->flink;
            if (tmp2 == line->l) {
              n = NULL;
            } else {
              n = (Note *) tmp2->val;
            }
          }
          if (lastn == NULL) lastn = n;
          lastn->dur_num *= m->lcm / lastn->dur_den;
          lastn->dur_den = m->lcm;
          if (lastn->dur_num <= gcount) {
            sprintf(s, "M: %d l: %s: Grace count %d %d > note %d %d",
                    m->number, line->name, gcount, m->lcm, 
                    lastn->dur_num, lastn->dur_den);
			mus_error(p, NULL, s);
            return 0;
          }
          lastn->dur_num -= gcount;
        }
        lastn = n;
      }
    }
  }
  return 1;
}

void free_note(Note *n)
{
	if (n->on_ties != NULL) dl_delete_list(n->on_ties);
	if (n->off_ties != NULL) dl_delete_list(n->off_ties);
	if (n->overlappers != NULL) dl_delete_list(n->overlappers);
	if (n->anchor != NULL) free(n->anchor);
	if (n->hint != NULL) free(n->hint);
	if (n->exmatch != NULL) free(n->exmatch);
	//if (n->trillnote != NULL) free_note(n->trillnote);  I'm letting this be a memory leak.
}

void free_hand(Hand *h)
{
	free(h);
}

void free_line(Line *l)
{
	Dlist tmp;

	dl_traverse(tmp, l->l) free_note((Note *) tmp->val);
	free(l);
}

void free_measure(Measure *m)
{
	Rb_node rtmp;
	Dlist tmp;

	rb_traverse(rtmp, m->lines) free_line((Line *)rtmp->v.val);
	rb_free_tree(m->lines);
	free_hand(m->hand[0]);
	free_hand(m->hand[1]);
	dl_traverse(tmp, m->lyrics) free_note((Note *) tmp->val);
	dl_delete_list(m->lyrics);
	free(m);
}

void delete_piece(Piece *p)
{
	Rb_node rtmp;

	if (p == NULL) return;
	rb_free_tree(p->marks);
	rb_free_tree(p->anchors);
	rb_traverse(rtmp, p->measures) free_measure((Measure *) rtmp->v.val);
	rb_free_tree(p->measures);
	rb_traverse(rtmp, p->strings) free(rtmp->k.key);
	rb_free_tree(p->strings);
}

void set_rhkey(Piece *p, int midkey)
{
	Rb_node rtmp;
	Measure *m;

	rb_traverse(rtmp, p->measures) {
		m = (measure *) rtmp->v.val;
		m->rhkey = midkey;
	}
}

/* Strip exmatches out of a piece -- not used. */

void kill_exmatches(Piece *p, int lr)
{
	Rb_node rtmp1, rtmp2;
	Measure *m;
	Line *l;
	Note *n;
	Dlist dtmp;

	rb_traverse(rtmp1, p->measures) {
		m = (measure *) rtmp1->v.val;
		rb_traverse(rtmp2, m->lines) {
			l = (Line *) rtmp2->v.val;
			if (l->name[0] == lr) {
				dl_traverse(dtmp, l->l) {
					n = (Note *) dtmp->val;
					if (n->exmatch != NULL) {
						free(n->exmatch);
						n->exmatch = NULL;
						if (n->trill) {
							if (n->trillnote->exmatch != NULL) {
								free(n->trillnote->exmatch);
								n->trillnote->exmatch = NULL;
							}
						}
					}
				}
			}
		}
	}
}