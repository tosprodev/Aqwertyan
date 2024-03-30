//
//  FileConverter.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/20/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//
#include <stdio.h>

#include "stdlib.h"
#include <map>
#include <set>
#include <vector>
#include "JMidi.h"
#import "Conversions.h"
#import "InputHandler.h"
#import "MusicFile.h"
#import <QuartzCore/QuartzCore.h>


int NoteToColumn(int note) {
    return 0;
}

void _old_jreadermain(char *file)
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


@implementation Conversions

+ (void)doChording:(Piece *)aPiece {
    //[InputHandler doChording:aPiece];
}

+ (void)removeExmatch:(Piece *)aPiece {
    // [InputHandler removeExmatch:aPiece];
}

+ (void)doColumns:(Piece *)aPiece {
    //[InputHandler doColumns:aPiece];
}

+ (void) getKeysForKey:(char)key buffer:(int *)array {
    // return [InputHandler getKeysForKey:key buffer:array];
}

+ (void)normalizeNoteWidths:(Piece *)aPiece {
    //return [InputHandler normalize:aPiece];
}

+ (Song *) getSong:(NSString *)aFile soloChannels:(NSArray *)channelsToSolo mutedChannels:(NSArray *)channelsToMute {
    
    char s[1000];
    RGNote *waitingForNoteOff[265][16];
    std::set<int> soloChannels;
    std::set<int> mutedChannels;
    std::map<int, RGNote *> allNotes;
    std::map<int, SpecialEvent *> allEvents;
    int i, format, ntracks, division, tracklength, dtime, event, metatype, channel,
    nbytes, ntoread, base, note, velocity;
    
    CFTimeInterval time = CACurrentMediaTime();
    
    //    _old_jreadermain((char *)[aFile UTF8String]);
    //    return nil;
    
    NSMutableArray *soloNotes = [NSMutableArray new];
    NSMutableArray *bandNotes = [NSMutableArray new];
    NSMutableArray *specialEvents = [NSMutableArray new];
    NSMutableArray *lyrics = [NSMutableArray new];
    NSMutableArray *maybeLyrics = [NSMutableArray new];
    
    for (NSNumber *ch in channelsToSolo) {
        soloChannels.insert(ch.intValue);
    }
    for (NSNumber *ch in channelsToMute) {
        mutedChannels.insert(ch.intValue);
    }
    
    for (int i = 0; i < 256; i++) {
        for (int j = 0; j < 16; j++) {
            waitingForNoteOff[i][j] = nil;
        }
    }
    
    freopen([aFile UTF8String], "r", stdin);
    
    if (fread(s, 1, 4, stdin) != 4) {
        NSLog(@"no header"); return nil;
    }
    s[4] = '\0';
    if (strcmp("MThd", s) != 0) { NSLog(@"bad header"); return nil; }
    
    i = readint();
    
    format = readshort();
    ntracks = readshort();
    division = readshort();
    int currentTempo = 500000;
    BOOL hasLyrics = NO;
    NSLog(@"Header size: %d.  format: %d.  ntracks: %d.  Division: %d\n",
          i, format, ntracks, division);
    
    if (i < 6) { NSLog(@"header size too small"); return nil;  }
    if (i > 6) { fseek(stdin, i-6, 1); }
    int lastStatus = 0;
    
    int quantum = division/24;
    
    
    for (i = 0; i < ntracks; i++) {
        NSLog(@"Attempting track %d\n", i);
        if (fread(s, 1, 4, stdin) != 4) { NSLog(@"No track\n"); return nil; }
        s[4] = '\0';
        if (strcmp("MTrk", s) != 0) { NSLog(@"Bad track"); return nil; }
        tracklength = readint();
        //  printf("  Length = %d\n", tracklength);
        int time = 0;
        int prevTime = 0;
        int quantumTime = 0;
        base = ftell(stdin);
        /* read events */
        // BOOL firstNoteOn = NO;
        int notes = soloNotes.count;
        
        RGNote *prevNote = nil;
        while (ftell(stdin) < base + tracklength) {
            
            dtime = readvarlen();
            
            time += dtime;
            quantumTime = ((time + quantum/2) / quantum) * quantum;
            
            event = getchar();
            
            if (event < 0xf0) {
                
                /* read midi events */
                
                // Check for running status
                if (event < 0x80) {
                    note = event;
                    event = lastStatus;
                    //  velocity = getchar();
                } else {
                    note = getchar();
                    //  velocity = getchar();
                    lastStatus = event;
                }
                
                //   printf("  MIDI event: %d %02X\n", dtime, event);
                if (event >= 0x80 && event <= 0x8f) {
                    channel = event - 0x80;
                    //                    note = getchar();
                    velocity = getchar();
                    
                    RGNote *n = waitingForNoteOff[note][channel];
                    if (n) {
                        waitingForNoteOff[note][channel] = nil;
                        n.duration = time - n.time;
                    } else {
                        NSLog(@"unused note off");
                    }
                    
                    // printf("  Note off.  Key = %d, velocity = %d\n", note, velocity);
                } else if (event >= 0x90 && event <= 0x9f) {
                    channel = event - 0x90;
                    //                    note = getchar();
                    velocity = getchar();
                    if (velocity == 0) {
                        RGNote *n = waitingForNoteOff[note][channel];
                        if (n) {
                            waitingForNoteOff[note][channel] = nil;
                            n.duration = time - n.time;
                        } else {
                          //  NSLog(@"unused note off (velocity 0)");
                        }
                    } else {
                        RGNote *n = [[RGNote alloc] init];
                        if (prevNote && (time - prevNote.time < quantum)) {
                            n.time = prevNote.time;
                        } else {
                            n.time = time;
                        }
                        n.note = note;
                        n.channel = channel;
                        n.volume = velocity;
                        n.rate = (float)division / currentTempo * 1000000.0;
                        
                        int compare = n.note + n.channel*1000 + n.time * 100000;
                        if (allNotes.find(compare) == allNotes.end()) {
                            allNotes[compare] = n;
                            
                            // check for a note waiting to get turned off
                            RGNote *other = waitingForNoteOff[note][channel];
                            if (other) {
                                other.duration = time - other.time;
                            }
                            
                            waitingForNoteOff[n.note][n.channel] = n;
                            if (soloChannels.find(channel) != soloChannels.end()) {
                                [soloNotes addObject:n];
                                //     firstNoteOn = YES;
                            } else if (mutedChannels.find(channel) == mutedChannels.end()) {
                                [bandNotes addObject:n];
                                //  firstNoteOn = YES;
                            }
                            prevNote = n;
                        } else {
//                            RGNote *note = allNotes[compare];
//                            if (!note.tieNotes) {
//                                note.tieNotes = [NSMutableArray new];
//                            }
//                            [(NSMutableArray *)note.tieNotes addObject:n];
//                            n.duration = note.duration;
                        }
                    }
                    
                    //   printf("  Note on.  Key = %d, velocity = %d\n", note, velocity);
                } else if (event >= 0xa0 && event <= 0xaf) {
                    //                    note = getchar();
                    velocity = getchar();
                    
                        printf("  Poly pressure.  Key = %d, velocity = %d\n", note, velocity);
                } else if (event >= 0xb0 && event <= 0xbf) {
                    //                    note = getchar();
                    velocity = getchar();
                    if (note== 0x40) {
                    channel = event - 0xb0;
                    SpecialEvent *e = [SpecialEvent new];
                    e.channel = channel;
                    e.value = note;
                    e.value2 = velocity;
                    e.type = SpecialEventTypePedal;
                    e.time = time;
                    int compare = e.type + e.time * 100000 + e.value * 1000 + e.channel*10;
                 //   if (allEvents.find(compare) == allEvents.end()) {
                        allEvents[compare] = e;
                        [specialEvents addObject:e];
//                    } else {
//                        NSLog(@"hmm..");
//                    }
                    }
                    //   printf("  Controller.  Id = %d, value = %d\n", note, velocity);
                } else if (event >= 0xc0 && event <= 0xcf) {
                    //  note = getchar();
                    //  printf("  Program change.  Number = %d\n", note);
                    SpecialEvent *e = [SpecialEvent new];
                    e.channel = event - 0xc0;
                    e.value = note;
                    e.time = time;
                    e.type = SpecialEventTypeProgramChange;
                    int compare = e.type + e.time * 100000 + e.value * 1000 + e.channel*10;
                  //  NSLog(@"PROGRAM %d CH %d time %d", note, channel, time);
                 //   if (allEvents.find(compare) == allEvents.end()) {
                  //      NSLog(@"prog added");
                        allEvents[compare] = e;
                        [specialEvents addObject:e];
//                    } else {
//                        NSLog(@"hmm..");
//                    }
//                    
                } else if (event >= 0xd0 && event <= 0xdf) {
                     // note = getchar();
                      printf("  Channel Pressure.  Value = %d\n", note);
                } else if (event >= 0xe0 && event <= 0xef) {
                    //  note = getchar();
                    velocity = getchar();
                     //  printf("  Pitch Wheel.  LSB = %d, MSB = %d\n", note, velocity);
                } else {
                    velocity = getchar();
                    //    printf("  Running status: Key = %d, Velocity %d\n", event, velocity);
                }
            } else if (event == 0xf0 || event == 0xf7) {
                nbytes = readvarlen();
                  printf("  SYSEX event: %d %02X -- skipping %d bytes\n",dtime, event, nbytes);
                fseek(stdin, nbytes, 1);
            } else if (event == 0xff) {
                metatype = getchar();
                //   printf("  META event: %d %02X %02X\n", dtime, event, metatype);
                
                /* reading meta events */
                
                if (metatype >= 0x01 && metatype <= 0x07) {
                    nbytes = readvarlen();
                    //                    switch(metatype) {
                    //                        case 0x01: printf("    Text Event: %d ", nbytes); break;
                    //                        case 0x02: printf("    Copyright notice: %d ", nbytes); break;
                    //                        case 0x03: printf("    Sequence/Track name: %d ", nbytes); break;
                    //                        case 0x04: printf("    Instrument name: %d ", nbytes); break;
                    //                        case 0x05: printf("    Lyric: %d ", nbytes); break;
                    //                        case 0x06: printf("    Marker: %d ", nbytes); break;
                    //                        case 0x07: printf("    Cue Point: %d ", nbytes); break;
                    //                        default: printf("Fucked up\n%d ", nbytes); exit(1);
                    //                    }
                    while(nbytes > 0) {
                        ntoread = (nbytes > 999) ? 999 : nbytes;
                        fread(s, 1, ntoread, stdin);
                        s[ntoread] = '\0';
                      //  printf("%s", s);
                        nbytes -= ntoread;
                    }
                    
                    int len = strlen(s);
                    if ((metatype == 0x05 || metatype == 0x01) && len) {
                        char c = s[0];
                        NSString *lyric = nil;
                        BOOL reject = NO;
                        if (metatype == 0x01) {
                            NSString *test = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
                            test = [test lowercaseString];
                            if ([test hasPrefix:@"midstamp"]) {
                                reject=YES;
                            }
                        }
                        if (!reject) {
                            if (c == '/' || c == ' ' || c == '\\') {
                                if (len > 1) {
                                    lyric = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
                                    lyric = [lyric substringFromIndex:1];
                                } else {
                                    
                                }
                            } else if (('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == ',') {
                                lyric = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
                            }
                            if (lyric) {
                                RGNote *n = [RGNote new];
                                n.note = 0;
                                n.channel = 0;
                                n.lyrics = lyric;
                                n.time = time;
                                //  [bandNotes addObject:n];
                                if (metatype == 0x05) {
                                    [lyrics addObject:n];
                                } else {
                                    [maybeLyrics addObject:n];
                                }
                              //  [(NSMutableArray *)lyrics addObject:n];
                                hasLyrics = (metatype == 0x05) || hasLyrics || time > 100;
                                //    firstNoteOn = YES;
//                                if (lyrics.count > 1) {
//                                    RGNote *lyricNote = lyrics[lyrics.count-2];
//                                    lyricNote.duration = time - lyricNote.time;
//                                }
                            }
                        }
                        
                    }
                    //    printf("\n");
                } else {
                    nbytes = readvarlen();
                    //                    switch(metatype) {
                    //                        case 0x20: printf("  Midi Channel Prefix\n"); break;
                    //                        case 0x2F: printf("  End of Track\n"); break;
                    //                        case 0x51: printf("  Tempo change\n"); break;
                    //                        case 0x54: printf("  SMPTE offset\n"); break;
                    //                        case 0x58: printf("  Time Sig\n"); break;
                    //                        case 0x59: printf("  Key Sig\n"); break;
                    //                        default: printf("  Who cares\n");
                    //                    }
                   // if metatype ==
                    if (metatype == 0x51) {
                        int tempo = getchar() << 16;
                        tempo += getchar() << 8;
                        tempo += getchar();
                        SpecialEvent *e = [SpecialEvent new];
                        e.time = time;
                        e.type = SpecialEventTypeTempoChange;
                        e.value = tempo;
                        currentTempo = tempo;
                        int compare = e.type + e.time * 1000 + e.value * 100;
                        if (allEvents.find(compare) == allEvents.end()) {
                            allEvents[compare] = e;
                            [specialEvents addObject:e];
                        }
                    } else {
                        fseek(stdin, nbytes, 1);
                    }
                }
            }
        }
        NSLog(@"%d notes", soloNotes.count  - notes);
    }
     Song *song = [Song new];
    [soloNotes sortUsingSelector:@selector(compare:)];
    [lyrics sortUsingSelector:@selector(compare:)];
    [maybeLyrics sortUsingSelector:@selector(compare:)];
    if (lyrics.count > 5 && [[lyrics lastObject] time] > 5) {
        [bandNotes addObjectsFromArray:lyrics];
        song.lyrics = lyrics;
    } else if (maybeLyrics.count > 5 && [[maybeLyrics lastObject] time] > 5) {
        [bandNotes addObjectsFromArray:maybeLyrics];
        song.lyrics = maybeLyrics;
    }
    if (song.lyrics) song.hasLyrics = YES;
    else song.lyrics = @[];
    
    if (song.lyrics.count > 1) {
    for (int i = 0; i < song.lyrics.count-1; i++) {
        RGNote *thisNote = song.lyrics[i];
        RGNote *nextNote = song.lyrics[i+1];
        thisNote.duration = MAX(nextNote.time - thisNote.time - 1, 0);
    }
    }
    [(RGNote *)song.lyrics.lastObject setDuration:1000];
    [bandNotes sortUsingSelector:@selector(compare:)];
    [specialEvents sortUsingSelector:@selector(compare:)];

    int first = 0;
    if (soloNotes.count) {
        first = [soloNotes[0] time];
    }
    if (bandNotes.count) {
        int time = [bandNotes[0] time];
        if (time < first) {
            first = time;
        }
    }
//    if (hasLyrics) {
//        if (lyrics.count) {
//            int time = [lyrics[0] time];
//            if (time < first) {
//                first = time;
//            }
//        }
//    }
//    for (RGNote *n in soloNotes) {
//        NSLog(@"%d %d %d %d", n.time, n.duration, n.channel, n.note);
//    }
    if (first > 0) {
        for (RGNote *n in soloNotes) {
            n.time -= first;
        }
        for (RGNote *n in bandNotes) {
            n.time -= first;
        }
//        for (RGNote *n in lyrics) {
//            n.time -= first;
//        }
        for (SpecialEvent *e in specialEvents) {
            e.time -= first;
        }
    }
    
    NSLog(@"%d user notes, %d band notes", soloNotes.count, bandNotes.count);
   
    song.division = division;
    song.soloNotes = soloNotes;
    song.bandNotes = bandNotes;
    song.specialEvents = specialEvents;

    RGNote *lastSoloNote = soloNotes.lastObject;
    RGNote *lastBandNote = bandNotes.lastObject;
    song.totalTicks = MAX(lastBandNote.time+lastBandNote.duration, lastSoloNote.time+lastSoloNote.duration);
    NSLog(@"%f", CACurrentMediaTime() - time);
    return song;
}

+ (void)applyColumns:(NSArray *)notes {
    for (RGNote *n in notes) {
        int col =  [self columnForKey:n.qwerty];
        switch (col) {
            case 0:
                n.qwerty = 'A';
                break;
            case 1:
                n.qwerty = 'S';
                break;
            case 2:
                n.qwerty = 'D';
                break;
            case 3:
                n.qwerty = 'F';
                break;
            case 4:
                n.qwerty = 'J';
                break;
            case 5:
                n.qwerty = 'K';
                break;
            case 6:
                n.qwerty = 'L';
                break;
            case 7:
                n.qwerty = ';';
                break;
                
            default:
                break;
        }
        char q = n.qwerty;
//        if (n.qwerty >= '5') n.qwerty += 2;
//        if (n.qwerty == ':') {
//            n.qwerty = '0';
//        }
    }
}

// Creates chord grouping for notes that have the same start time and duration
+ (NSArray *)applyChording:(NSArray *)notes quantum:(int)quantum {
    NSMutableArray *newNotes = [NSMutableArray new];
    NSMutableArray *chord = [NSMutableArray array];
    int time = -1;
    int i = 0;
    
    // First we traverse the list and collect groups of notes with the same start time
    for (RGNote *n in notes) {
        i++;
        
        // If we are on a new chord, process the current group
        if (ABS(n.time - time) >= quantum) {
            
            // Now each note in the group has the same start time. We need to create subgroups according to duration
            [self extractChords:chord intoNotes:newNotes];
            [chord removeAllObjects];
            
            // update the time
            time = n.time;
        }
        
        // Add this note to the chord
        [chord addObject:n];
    }
    [self extractChords:chord intoNotes:newNotes];
    return newNotes;
}

+ (void) extractChords:(NSMutableArray *)chord intoNotes:(NSMutableArray *)notes {
    int maxCol = -1;
    RGNote *anchor;
    
    if (!chord.count) return;
    
    // The note with the shortest duration is the anchor
    RGNote *minNote = chord[0];
    for (RGNote *note in chord) {
        if (note.duration < minNote.duration) {
            minNote = note;
        }
    }
    anchor = minNote;
    
    NSMutableArray *ties = [NSMutableArray new];
    for (RGNote *note in chord) {
        if (note != anchor) {
            [ties addObject:note];
            note.tie = YES;
        }
    }
    
    if (ties.count) {
        anchor.tieNotes = ties;
    }
    [notes addObject:anchor];
    
    /*
    std::map<int, std::vector<RGNote *> > durations;
    [chord sortUsingComparator:^NSComparisonResult(RGNote *one, RGNote *two) {
        if (one.note > two.note) return NSOrderedDescending;
        if (two.note > one.note) return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    // group notes in the list by duration (all start times are the same)
    for (RGNote *note in chord) {
        durations[note.duration].push_back(note);
    }
    
    // for each duration, create a chord
    for (std::map<int, std::vector<RGNote *> >::iterator it = durations.begin(); it != durations.end(); it++) {
        int maxCol = -1;
        RGNote *anchor = nil;
        
        // The highest note is the anchor
        for (int i = 0; i < it->second.size(); i++) {
            int col = [self columnForKey:it->second[i].qwerty];
            if (col > maxCol) {
                maxCol = col;
                anchor = it->second[i];
            }
        }
        [notes addObject:anchor];
        
        // The rest of the notes are tied to the anchor
        if (it->second.size() > 1) {
            NSMutableArray *ties = [NSMutableArray new];
            for (int i = 0; i < it->second.size(); i++) {
                if (it->second[i] != anchor) {
                    [ties addObject:it->second[i]];
                }
            }
            anchor.tieNotes = ties;
        }
    }
     */
}

+ (NSInteger)columnForKey:(char)key withChord:(int)chord {
    int col = [self columnForKey:key];
    if (chord > 3) {
        
        if (col == 0) return  3;
        if (col == 1) return 2;
        if (col == 2) return 1;
        if (col == 3) return 0;
        if (col == 4) return 7;
        if (col == 5) return 6;
        if (col == 6) return 5;
        if (col == 7) return 4;
        
    }
    return col;
}

+ (NSInteger)columnForKey:(char)key {
    if (key < 'a' && key >= 'A') {
        key += 'a' - 'A';
    }
    
    if (key == '1' || key == 'q' || key =='a' || key == 'z') {
        return 7;
    }
    if (key == '2' || key == 'w' || key =='s' || key == 'x') {
        return 6;
    }
    if (key == '3' || key == 'e' || key =='d' || key == 'c') {
        return 5;
    }
    if (key == '4' || key == 'r' || key =='f' || key == 'v') {
        return 4;
    }
    if (key == '\0' || key == 't' || key =='g' || key == 'b') {
        return 4;
    }
    if (key == '5' || key == 'y' || key =='h' || key == 'n') {
        return 3;
    }
    if (key == '\0' || key == 'u' || key =='j' || key == 'm') {
        return 3;
    }
    if (key == '6' || key == 'i' || key =='k' || key == ',') {
        return 2;
    }
    if (key == '7' || key == 'o' || key =='l' || key == '.') {
        return 1;
    }
    if (key == '8' || key == 'p' || key ==';' || key == '/') {
        return 0;
    }
    return 4;
}

@end

@implementation SpecialEvent

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%d channel:%d value:%d time:%d", _type, _channel, _value, _time];
}

- (NSComparisonResult) compare:(SpecialEvent *)e {
    if (e.time == _time) return NSOrderedSame;
    if (e.time < _time) return NSOrderedDescending;
    return NSOrderedAscending;
}

@end

@implementation Song

@end


