// Dlist.h: interface for the Dlist class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DLIST_H__14B91500_FAEE_11D2_87DB_0000C0280101__INCLUDED_)
#define AFX_DLIST_H__14B91500_FAEE_11D2_87DB_0000C0280101__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/* Routines for doubly linked lists.  The structs are exposed to the 
   users.  All lists have a sentinel node and are circular.  The val
   field is a void * that you cast to what you want.  Not as nice as
   using a jval (which you can't use here since jvals are 8 bytes),
   but usable nonetheless */

typedef struct dlist {
  struct dlist *flink;
  struct dlist *blink;
  void *val;
} *Dlist;

/* Nil, first, next, and prev are macro expansions for list traversal 
 * primitives. */

#ifndef nil
#define nil(l) (l)
#endif

#ifndef first
#define first(l) (l->flink)
#endif

#ifndef last
#define last(l) (l->blink)
#endif

#ifndef next
#define next(n) (n->flink)
#endif

#ifndef prev
#define prev(n) (n->blink)
#endif

/* These are the routines for manipluating lists */

extern Dlist make_dl();
extern void dl_insert_b(Dlist n, void *v); /* Makes a new node, and inserts it before
                                        the given node -- if that node is the 
                                        head of the list, the new node is 
                                        inserted at the end of the list */
#define dl_insert_a(n, val) dl_insert_b(n->flink, val)

extern void dl_delete_node(Dlist n);    /* Deletes and free's a node */

extern void dl_delete_list(Dlist l);  /* Deletes the entire list from
                                            existance */
extern void *dl_val(Dlist n);   /* Returns node->val (used to shut lint up) */

extern void dl_delete_val(Dlist d, void *v);

extern int dl_count(Dlist l);

#define dl_traverse(ptr, list) \
  for (ptr = first(list); ptr != list; ptr = next(ptr))
#define dl_empty(list) (list->flink == list)


#endif // !defined(AFX_DLIST_H__14B91500_FAEE_11D2_87DB_0000C0280101__INCLUDED_)
