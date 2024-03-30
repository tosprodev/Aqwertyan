#include <stdio.h>
#include "JMidi.h"



void old_jreadermain(char *file)
{
  char s[1000];
  int i, format, ntracks, division, tracklength, dtime, event, metatype,
         nbytes, ntoread, base, note, velocity;
  
    freopen(file, "r", stdin);
  if (fread(s, 1, 4, stdin) != 4) {
      fprintf(stderr, "No header\n"); exit(1);
  }
  s[4] = '\0';
  if (strcmp("MThd", s) != 0) { fprintf(stderr, "Bad header\n"); exit(1); }

  i = readint();

  format = readshort();
  ntracks = readshort();
  division = readshort();

  printf("Header size: %d.  format: %d.  ntracks: %d.  Division: %d\n", 
    i, format, ntracks, division);

  if (i < 6) { fprintf(stderr, "header size too small\n"); exit(1); }
  if (i > 6) { fseek(stdin, i-6, 1); }

  for (i = 0; i < ntracks; i++) {
    printf("Attempting track %d\n", i);
    if (fread(s, 1, 4, stdin) != 4) { fprintf(stderr, "No track\n"); exit(1); }
    s[4] = '\0';
    if (strcmp("MTrk", s) != 0) { fprintf(stderr, "Bad track\n"); exit(1); }
    tracklength = readint();
    printf("  Length = %d\n", tracklength);

    base = ftell(stdin);
    /* read events */
    while (ftell(stdin) < base + tracklength) {
      dtime = readvarlen();
      event = getchar();
      if (event < 0xf0) {

        /* read midi events */

        printf("  MIDI event: %d %02X\n", dtime, event);
        if (event >= 0x80 && event <= 0x8f) {
          note = getchar();
          velocity = getchar();
          printf("  Note off.  Key = %d, velocity = %d\n", note, velocity);
        } else if (event >= 0x90 && event <= 0x9f) {
          note = getchar();
          velocity = getchar();
          printf("  Note on.  Key = %d, velocity = %d\n", note, velocity);
        } else if (event >= 0xa0 && event <= 0xaf) {
          note = getchar();
          velocity = getchar();
          printf("  Poly pressure.  Key = %d, velocity = %d\n", note, velocity);
        } else if (event >= 0xb0 && event <= 0xbf) {
          note = getchar();
          velocity = getchar();
          printf("  Controller.  Id = %d, value = %d\n", note, velocity);
        } else if (event >= 0xc0 && event <= 0xcf) {
          note = getchar();
          printf("  Program change.  Number = %d\n", note);
        } else if (event >= 0xd0 && event <= 0xdf) {
          note = getchar();
          printf("  Channel Pressure.  Value = %d\n", note);
        } else if (event >= 0xe0 && event <= 0xef) {
          note = getchar();
          velocity = getchar();
          printf("  Pitch Wheel.  LSB = %d, MSB = %d\n", note, velocity);
        } else {
          velocity = getchar();
          printf("  Running status: Key = %d, Velocity %d\n", event, velocity);
        }
      } else if (event == 0xf0 || event == 0xf7) {
        nbytes = readvarlen();
        printf("  SYSEX event: %d %02X -- skipping %d bytes\n", 
               dtime, event, nbytes);
        fseek(stdin, nbytes, 1);
      } else if (event == 0xff) {
        metatype = getchar();
        printf("  META event: %d %02X %02X\n", dtime, event, metatype);

        /* reading meta events */

        if (metatype >= 0x01 && metatype <= 0x07) {
          nbytes = readvarlen();
          switch(metatype) {
            case 0x01: printf("    Text Event: %d ", nbytes); break;
            case 0x02: printf("    Copyright notice: %d ", nbytes); break;
            case 0x03: printf("    Sequence/Track name: %d ", nbytes); break;
            case 0x04: printf("    Instrument name: %d ", nbytes); break;
            case 0x05: printf("    Lyric: %d ", nbytes); break;
            case 0x06: printf("    Marker: %d ", nbytes); break;
            case 0x07: printf("    Cue Point: %d ", nbytes); break;
            default: printf("Fucked up\n%d ", nbytes); exit(1);
          }
          while(nbytes > 0) {
            ntoread = (nbytes > 999) ? 999 : nbytes;
            fread(s, 1, ntoread, stdin);
            s[ntoread] = '\0';
            printf("%s", s);
            nbytes -= ntoread;
          } 
          printf("\n");
        } else {
          nbytes = readvarlen();
          switch(metatype) {
            case 0x20: printf("  Midi Channel Prefix\n"); break;
            case 0x2F: printf("  End of Track\n"); break;
            case 0x51: printf("  Tempo change\n"); break;
            case 0x54: printf("  SMPTE offset\n"); break;
            case 0x58: printf("  Time Sig\n"); break;
            case 0x59: printf("  Key Sig\n"); break;
            default: printf("  Who cares\n");
          }
          fseek(stdin, nbytes, 1);
        }
      }
    }
  }
}
