#include <stdio.h>
#include <fcntl.h>
#include <sys/time.h>
#include <unistd.h>
#include <signal.h>

main()
{
  int fd;
  unsigned char *stuff;
  long *sec;
  long *usec;
  int i, nc, nevents, e;
  struct timeval tv, base_tv;

  fread(&nevents, sizeof(int), 1, stdin);
  printf("nevents = %d\n", nevents);

  stuff = (unsigned char *) malloc(sizeof(char)*(nevents+1));
  sec = (long *) malloc(sizeof(long)*(nevents+1));
  usec = (long *) malloc(sizeof(long)*(nevents+1));

  fread(stuff, sizeof(char), nevents, stdin);
  fread(sec, sizeof(long), nevents, stdin);
  fread(usec, sizeof(long), nevents, stdin);

  fd = open("/dev/midi", O_WRONLY);

  if (fd < 0) { perror("/dev/midi"); exit(1); }

  gettimeofday(&base_tv, NULL);
  base_tv.tv_sec += 2;
  for (e = nevents-1; e >= 0 ; e--) {
    sec[e] = base_tv.tv_sec + sec[e] - sec[0];
  }

  for (e = 0; e < nevents; e++) {
    printf("%02x %d %6d\n", stuff[e], sec[e], usec[e]);
  }
/*
  gettimeofday(&tv, NULL);
  for (e = 0; e < nevents; e++) {
    while (tv.tv_sec <= sec[e] && 
            (tv.tv_sec < sec[e] || tv.tv_usec < usec[e])) {
      gettimeofday(&tv, NULL);
    }
    write(fd, stuff+e, 1);
  }
*/
 
}
