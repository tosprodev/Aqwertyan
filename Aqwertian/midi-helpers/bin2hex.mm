#include <stdio.h>

void bin2hexmain()
{
  unsigned char c[8];
  int i, j;

  while((i = fread(c, 1, 8, stdin)) > 0) {
    for (j = 0; j < i; j++) {
      printf("%02X ", c[j]);
    }
    printf("\n");
  }
}
