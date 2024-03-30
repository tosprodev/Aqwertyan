#include <stdio.h>

void hex2binmain()
{
  char s[100];
  unsigned char c;
  unsigned int i;

  while(scanf("%s", s) != EOF) {
    sscanf(s, "%X", &i);
    c = i;
    putchar(c);
  }
}
