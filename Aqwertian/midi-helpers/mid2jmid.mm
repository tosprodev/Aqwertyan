#include <stdio.h>
#include <stdlib.h>
#include "JMidi.h"
#include "mid2jmid.h"
#import <Foundation/Foundation.h>





Channel *add_channel(NSMutableArray *array, int channel, int track) {
    for (Channel *theChannel in array) {
        if (theChannel.Number == channel) {
            return theChannel;
        }
    }

    Channel *theChannel = [Channel new];
    theChannel.Track = track;
    theChannel.Number = channel;
    [array addObject:theChannel];
    return theChannel;
}

NSArray *get_events(NSString *aFile) {
    char s[1000];
    int i, format, ntracks, division, tracklength, dtime, event, metatype,
    nbytes, ntoread, base, note, velocity, track;
    //  FILE *f;
    NZMidiEvent *theEvent;
    NSMutableArray *theTracks = [NSMutableArray new];
    NSMutableArray *theEvents;
    

    freopen([aFile UTF8String], "r", stdin);
    
    if (fread(s, 1, 4, stdin) != 4) {
        fprintf(stderr, "No header\n"); exit(1);
    }
    s[4] = '\0';
    if (strcmp("MThd", s) != 0) { fprintf(stderr, "Bad header\n"); exit(1); }
    
    i = readint();
    
    format = readshort();
    ntracks = readshort();
    division = readshort();
    
    //    f = fopen([[args objectAtIndex:1] UTF8String], "w");
    //    if (f == NULL) { perror([[args objectAtIndex:2] UTF8String]); exit(1); }
    theEvents = [NSMutableArray new];
    [theTracks addObject:theEvents];
    [theEvents addObject:[NSString stringWithFormat:@"JMID FILE"]];
    [theEvents addObject:[NSString stringWithFormat:@"Format: %d  ntracks: %d  Division: %d",format, ntracks, division]];
    
    if (i < 6) { fprintf(stderr, "header size too small\n"); exit(1); }
    if (i > 6) { fseek(stdin, i-6, 1); }
    
    for (track = 0; track < ntracks; track++) {
//        theEvents = [NSMutableArray new];
//        [theTracks addObject:theEvents];
        
        [theEvents addObject:[NSString stringWithFormat:@"TRACK %d\n", track]];
        if (fread(s, 1, 4, stdin) != 4) { fprintf(stderr, "No track\n"); exit(1); }
        s[4] = '\0';
        if (strcmp("MTrk", s) != 0) { fprintf(stderr, "Bad track\n"); exit(1); }
        tracklength = readint();
        int channel;
      
        
        base = ftell(stdin);
        /* read events */
        while (ftell(stdin) < base + tracklength) {
            dtime = readvarlen();
            event = getchar();
            // fprintf(f, "%7d ", dtime);
             [theEvents addObject:[NSString stringWithFormat:@"%7d ", dtime]];
            if (event < 0xf0) {
                
                /* read midi events */
                
                if (event >= 0x80 && event <= 0x8f) {
                    note = getchar();
                    velocity = getchar();
                     [theEvents addObject:[NSString stringWithFormat:@"NOTE-OFF %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0x90 && event <= 0x9f) {
                    note = getchar();
                    velocity = getchar();
                    channel = event-0x90;
                   // theEvent = [NZMidiEvent new];
                     [theEvents addObject:[NSString stringWithFormat:@"NOTE-ON  %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0xa0 && event <= 0xaf) {
                    note = getchar();
                    velocity = getchar();
                      [theEvents addObject:[NSString stringWithFormat:@"PRESSUR  %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0xb0 && event <= 0xbf) {
                    note = getchar();
                    velocity = getchar();
                     [theEvents addObject:[NSString stringWithFormat:@"CONTROL  %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0xc0 && event <= 0xcf) {
                    note = getchar();
                    channel = event - 0xc0;
                   // theChannel = add_channel(theEvents, channel);
                   // [theChannel.Instruments addObject:[NSNumber numberWithInt:note]];
                     [theEvents addObject:[NSString stringWithFormat:@"PROGRM   %02X %3d\n", event , note]];
                    
                } else if (event >= 0xd0 && event <= 0xdf) {
                    note = getchar();
                    [theEvents addObject:[NSString stringWithFormat:@"CHANPRE  %02X %3d\n", event , note]];
                } else if (event >= 0xe0 && event <= 0xef) {
                    note = getchar();
                    velocity = getchar();
                     [theEvents addObject:[NSString stringWithFormat:@"PWHEEL   %02X %3d %3d\n", event , note, velocity]];
                } else {
                    velocity = getchar();
                     [theEvents addObject:[NSString stringWithFormat:@"RSTAT       %3d %3d\n", event , velocity]];
                }
            } else if (event == 0xf0 || event == 0xf7) {
                nbytes = readvarlen();
                [theEvents addObject:[NSString stringWithFormat:@"SYSEX      %02X %d", event, nbytes]];
                                for (i = 0; i < nbytes; i++) {
                //                    if (i != 0 && i % 10 == 0) fprintf(f, "\n                   ");
                [theEvents addObject:[NSString stringWithFormat:@" %02X", getchar()]];
                                   // getchar();
                 }
                //  fprintf(f, "\n");
            } else if (event == 0xff) {
                metatype = getchar();
                nbytes = readvarlen();
               [theEvents addObject:[NSString stringWithFormat:@"META       %02X %02X %d", event, metatype, nbytes]];
                                for (i = 0; i < nbytes; i++) {
                //                    if (i != 0 && i % 10 == 0) fprintf(f, "\n                   ");
                                    [theEvents addObject:[NSString stringWithFormat:@" %02X", getchar()]];
                                    //getchar();
                            }
                //                fprintf(f, "\n");
            }
        }
    }
//    for (NSMutableArray *theArray in theTracks) {
//        [theArray sortUsingSelector:@selector(compare:)];
//    }
    return theTracks;
}

NSArray *get_program_events(NSString *aFile) {
    char s[1000];
    int i, format, ntracks, division, tracklength, dtime, event, metatype,
    nbytes, ntoread, base, note, velocity, track;
  //  FILE *f;
    
    NSMutableArray *theTracks = [NSMutableArray new];
    NSMutableArray *theEvents;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:aFile]) {
        NSLog(@"no file");
        return nil;
    }
   freopen([aFile UTF8String], "r", stdin);
    Channel *theChannel;
    
    if (fread(s, 1, 4, stdin) != 4) {
        fprintf(stderr, "No header\n");
        return nil;
     //   exit(1);
    }
    s[4] = '\0';
    if (strcmp("MThd", s) != 0) {
        fprintf(stderr, "Bad header\n");
        return nil;
    //    exit(1);
    }
    
    i = readint();
    
    format = readshort();
    ntracks = readshort();
    division = readshort();
    
//    f = fopen([[args objectAtIndex:1] UTF8String], "w");
//    if (f == NULL) { perror([[args objectAtIndex:2] UTF8String]); exit(1); }
    
//    fprintf(f, "JMID FILE\n");
//    fprintf(f, "Format: %d  ntracks: %d  Division: %d\n",
//            format, ntracks, division);
    
    if (i < 6) {
        fprintf(stderr, "header size too small\n");
       // exit(1);
    }
    if (i > 6) { fseek(stdin, i-6, 1); }
    theEvents = [NSMutableArray new];
    [theTracks addObject:theEvents];
    for (track = 0; track < ntracks; track++) {
        //fprintf(f, "TRACK %d\n", track);
        if (fread(s, 1, 4, stdin) != 4) { fprintf(stderr, "No track\n"); return nil; }
        s[4] = '\0';
        if (strcmp("MTrk", s) != 0) { fprintf(stderr, "Bad track\n");return nil; }
        tracklength = readint();
        int channel;
       // theEvents = [NSMutableArray new];
        //[theTracks addObject:theEvents];
        
        
        base = ftell(stdin);
        int time = 0;
        /* read events */
        while (ftell(stdin) < base + tracklength) {
            dtime = readvarlen();
            time += dtime;
            event = getchar();
          // [theEvents addObject:[NSString stringWithFormat:@"%7d ", dtime]];
            if (event < 0xf0) {
                
                /* read midi events */
                
                if (event >= 0x80 && event <= 0x8f) {
                    note = getchar();
                    velocity = getchar();
                // [theEvents addObject:[NSString stringWithFormat:@"NOTE-OFF %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0x90 && event <= 0x9f) {
                    note = getchar();
                    velocity = getchar();
                    channel = event-0x90;
                    theChannel = add_channel(theEvents, channel, track);
               // [theEvents addObject:[NSString stringWithFormat:@"NOTE-ON  %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0xa0 && event <= 0xaf) {
                    note = getchar();
                    velocity = getchar();
                // [theEvents addObject:[NSString stringWithFormat:@"PRESSUR  %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0xb0 && event <= 0xbf) {
                    note = getchar();
                    velocity = getchar();
                // [theEvents addObject:[NSString stringWithFormat:@"CONTROL  %02X %3d %3d\n", event , note, velocity]];
                } else if (event >= 0xc0 && event <= 0xcf) {
                    note = getchar();
                    channel = event - 0xc0;
                    theChannel = add_channel(theEvents, channel, track);
                    [theChannel.Instruments addObject:[NSNumber numberWithInt:note]];
                    //NSLog(@"PROGRM   %d %3d (%d)\n", channel , note, time);
                    
                } else if (event >= 0xd0 && event <= 0xdf) {
                    note = getchar();
                 // [theEvents addObject:[NSString stringWithFormat:@"CHANPRE  %02X %3d\n", event , note]];
                } else if (event >= 0xe0 && event <= 0xef) {
                    note = getchar();
                    velocity = getchar();
            // [theEvents addObject:[NSString stringWithFormat:@"PWHEEL   %02X %3d %3d\n", event , note, velocity]];
                } else {
                    velocity = getchar();
              // [theEvents addObject:[NSString stringWithFormat:@"RSTAT       %3d %3d\n", event , velocity]];
                }
            } else if (event == 0xf0 || event == 0xf7) {
                nbytes = readvarlen();
              // [theEvents addObject:[NSString stringWithFormat:@"SYSEX      %02X %d", event, nbytes]];
                for (i = 0; i < nbytes; i++) {
//                    if (i != 0 && i % 10 == 0) fprintf(f, "\n                   ");
                   // fprintf(f, " %02X", getchar());
                    getchar();
                }
              //  fprintf(f, "\n");
            } else if (event == 0xff) {
                metatype = getchar();
                nbytes = readvarlen();
              //  [theEvents addObject:[NSString stringWithFormat:@"META       %02X %02X %d", event, metatype, nbytes]];
                for (i = 0; i < nbytes; i++) { 
//                    if (i != 0 && i % 10 == 0) fprintf(f, "\n                   ");
//                    fprintf(f, " %02X", getchar());
                    getchar();
               }
//                fprintf(f, "\n");
            }
        }
    }
    for (NSMutableArray *theArray in theTracks) {
        [theArray sortUsingSelector:@selector(compare:)];
    }
    return theTracks;
}

void mid2jmidmain(NSArray *args)
{
  char s[1000];
  int i, format, ntracks, division, tracklength, dtime, event, metatype,
         nbytes, ntoread, base, note, velocity, track;
    FILE *f;int argc = [args count];
  
  if (argc != 2) {
    fprintf(stderr, "usage:infile outputfile\n");
    exit(1);
  }
    
    freopen([[args objectAtIndex:0] UTF8String], "r", stdin);

  if (fread(s, 1, 4, stdin) != 4) {
      fprintf(stderr, "No header\n"); exit(1);
  }
  s[4] = '\0';
  if (strcmp("MThd", s) != 0) { fprintf(stderr, "Bad header\n"); exit(1); }

  i = readint();

  format = readshort();
  ntracks = readshort();
  division = readshort();

  f = fopen([[args objectAtIndex:1] UTF8String], "w");
  if (f == NULL) { perror([[args objectAtIndex:2] UTF8String]); exit(1); }
 
  fprintf(f, "JMID FILE\n");
  fprintf(f, "Format: %d  ntracks: %d  Division: %d\n", 
    format, ntracks, division);

  if (i < 6) { fprintf(stderr, "header size too small\n"); exit(1); }
  if (i > 6) { fseek(stdin, i-6, 1); }

  for (track = 0; track < ntracks; track++) {
    fprintf(f, "TRACK %d\n", track);
    if (fread(s, 1, 4, stdin) != 4) { fprintf(stderr, "No track\n"); exit(1); }
    s[4] = '\0';
    if (strcmp("MTrk", s) != 0) { fprintf(stderr, "Bad track\n"); exit(1); }
    tracklength = readint();

    base = ftell(stdin);
    /* read events */
    while (ftell(stdin) < base + tracklength) {
      dtime = readvarlen();
      event = getchar();
      fprintf(f, "%7d ", dtime);
      if (event < 0xf0) {

        /* read midi events */

        if (event >= 0x80 && event <= 0x8f) {
          note = getchar();
          velocity = getchar();
          fprintf(f, "NOTE-OFF %02X %3d %3d\n", event , note, velocity);
        } else if (event >= 0x90 && event <= 0x9f) {
          note = getchar();
          velocity = getchar();
          fprintf(f, "NOTE-ON  %02X %3d %3d\n", event , note, velocity);
        } else if (event >= 0xa0 && event <= 0xaf) {
          note = getchar();
          velocity = getchar();
          fprintf(f, "PRESSUR  %02X %3d %3d\n", event , note, velocity);
        } else if (event >= 0xb0 && event <= 0xbf) {
          note = getchar();
          velocity = getchar();
          fprintf(f, "CONTROL  %02X %3d %3d\n", event , note, velocity);
        } else if (event >= 0xc0 && event <= 0xcf) {
          note = getchar();
          fprintf(f, "PROGRM   %02X %3d\n", event , note);
        } else if (event >= 0xd0 && event <= 0xdf) {
          note = getchar();
          fprintf(f, "CHANPRE  %02X %3d\n", event , note);
        } else if (event >= 0xe0 && event <= 0xef) {
          note = getchar();
          velocity = getchar();
          fprintf(f, "PWHEEL   %02X %3d %3d\n", event , note, velocity);
        } else {
          velocity = getchar();
          fprintf(f, "RSTAT       %3d %3d\n", event , velocity);
        }
      } else if (event == 0xf0 || event == 0xf7) {
        nbytes = readvarlen();
        fprintf(f, "SYSEX      %02X %d", event, nbytes);
        for (i = 0; i < nbytes; i++) { 
          if (i != 0 && i % 10 == 0) fprintf(f, "\n                   ");
          fprintf(f, " %02X", getchar());
        }
        fprintf(f, "\n");
      } else if (event == 0xff) {
        metatype = getchar();
        nbytes = readvarlen();
        fprintf(f, "META       %02X %02X %d", event, metatype, nbytes);
        for (i = 0; i < nbytes; i++) { 
          if (i != 0 && i % 10 == 0) fprintf(f, "\n                   ");
          fprintf(f, " %02X", getchar());
        }
        fprintf(f, "\n");
      }
    }
  }
}
