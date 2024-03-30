// Dlist.cpp: implementation of the Dlist class.
//
//////////////////////////////////////////////////////////////////////

#include "stdlib.h"
//#include "stdafx.h"
#include "Dlist.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

#define boolean int
#define TRUE 1
#define FALSE 0


/*---------------------------------------------------------------------*
 * PROCEDURES FOR MANIPULATING DOUBLY LINKED LISTS 
 * Each list contains a sentinal node, so that     
 * the first item in list l is l->flink.  If l is  
 * empty, then l->flink = l->blink = l.            
 *---------------------------------------------------------------------*/

Dlist make_dl()
{
  Dlist d;

  d = (Dlist) malloc (sizeof(struct dlist));
  d->flink = d;
  d->blink = d;
  d->val = (void *) 0;
  return d;
}
 
void dl_insert_b(Dlist node, void *val)	/* Inserts to the end of a list */
{
  Dlist last_node, new_node;

  new_node = (Dlist) malloc (sizeof(struct dlist));
  new_node->val = val;

  last_node = node->blink;

  node->blink = new_node;
  last_node->flink = new_node;
  new_node->blink = last_node;
  new_node->flink = node;
  return;
}

void dl_delete_node(Dlist item)		/* Deletes an arbitrary iterm */
{
  item->flink->blink = item->blink;
  item->blink->flink = item->flink;
  free(item);
  return;
}

void dl_delete_list(Dlist l)
{
  Dlist d, next_node;

  d = l->flink;
  while(d != l) {
    next_node = d->flink;
    free(d);
    d = next_node;
  }
  free(d);
  return;
}

int dl_count(Dlist l) {
    int count = 0;
    Dlist ptr;
    dl_traverse(ptr, l) {
        count++;
    }
    return count;
}

void dl_delete_val(Dlist d, void *v) {
    Dlist ptr;
    dl_traverse(ptr, d) {
        if (ptr->val == v) {
            dl_delete_node(ptr);
            return;
        }
    }
}

void *dl_val(Dlist l)
{
  return l->val;
}
