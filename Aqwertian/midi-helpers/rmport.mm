#include <stdio.h>
#include <fcntl.h>
#include <sys/time.h>
#include <unistd.h>
#include <signal.h>

int done = 0;
void *cntl_c_handler(int i)
{
  done = 1;
}
  
main()
{
  int fd;
  unsigned char *stuff;
  long *sec;
  long *usec;
  int i, nc, nevents;
  struct timeval tv;

  stuff = (unsigned char *) malloc(sizeof(char)*1000000);
  sec = (long *) malloc(sizeof(long)*1000000);
  usec = (long *) malloc(sizeof(long)*1000000);

  (void) signal(SIGINT, cntl_c_handler);

  fd = open("/dev/midi", O_RDONLY);

  if (fd < 0) { perror("/dev/midi"); exit(1); }

  nevents = 0;
  while(!done) {
    nc = read(fd, stuff+nevents, 400);
    gettimeofday(&tv, NULL);
    for (i = 0; i < nc; i++) {
      sec[nevents+i] = tv.tv_sec;
      usec[nevents+i] = tv.tv_usec;
    }
    nevents += nc;
  }

  fwrite(&nevents, sizeof(int), 1, stdout);
  fwrite(stuff, sizeof(char), nevents, stdout);
  fwrite(sec, sizeof(long), nevents, stdout);
  fwrite(usec, sizeof(long), nevents, stdout);
}

  
