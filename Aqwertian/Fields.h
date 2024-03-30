// Fields.h: interface for the Fields class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_FIELDS_H__14B91501_FAEE_11D2_87DB_0000C0280101__INCLUDED_)
#define AFX_FIELDS_H__14B91501_FAEE_11D2_87DB_0000C0280101__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <stdio.h>
#define MAXLEN 1001
#define MAXFIELDS 1000

typedef struct inputstruct {
  char *name;               /* File name */
  FILE *f;                  /* File descriptor */
  int line;                 /* Line number */
  char text1[MAXLEN];       /* The line */
  char text2[MAXLEN];       /* Working -- contains fields */
  int NF;                   /* Number of fields */
  char *fields[MAXFIELDS];  /* Pointers to fields */
  int file;                 /* 1 for file, 0 for popen */
} *IS;

extern IS new_inputstruct(char *filename);
extern int get_line(IS is); /* returns NF, or -1 on EOF.  Does not
                                  close the file */
extern void jettison_inputstruct(IS is);  /* frees the IS and fcloses 
                                                the file */

#endif // !defined(AFX_FIELDS_H__14B91501_FAEE_11D2_87DB_0000C0280101__INCLUDED_)
