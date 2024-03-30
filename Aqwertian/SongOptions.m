//
//  SongOptions.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/30/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "SongOptions.h"
//#import "InputHandler.h"
#import "Util.h"
#import "LibraryManager.h"
#import "MusicFile.h"
#import "NZNotationDisplay.h"

static BOOL _isCurrentItemJukebox;

char ToNumberKey(char key) {
    if (key == ' ' || key == '_') return key;
    switch (key) {
        case 'A':
            return '1';
            break;
        case 'S':
            return '2';
            break;
        case 'D':
            return '3';
            break;
        case 'F':
            return '4';
            break;
        case 'J':
            return '5';
            break;
        case 'K':
            return '6';
            break;
        case 'L':
            return '7';
            break;
        case ';':
            return '8';
            break;
            
            
        default:
            return '1';
            break;
    }
}


char keyForColumn(int col) {
    switch (col) {
        case 7:
            return 'A';
            break;
        case 6:
            return 'S';
            break;
        case 5:
            return 'D';
            break;
        case 4:
            return 'F';
            break;
        case 3:
            return 'J';
            break;
        case 2:
            return 'K';
            break;
        case 1:
            return 'L';
            break;
        case 0:
            return ';';
            break;
            
            
        default:
            break;
    }
}



BOOL IsLeftHand(char qwerty) {
    switch (qwerty) {
        case 'A':
            return YES;
            break;
        case 'S':
            return YES;
            break;
        case 'D':
            return YES;
            break;
        case 'F':
            return YES;
            break;
        case 'J':
            return NO;
            break;
        case 'K':
            return NO;
            break;
        case 'L':
            return NO;
            break;
        case ';':
            return NO;
            break;
            
        default:
            return YES;
            break;
    }
}

BOOL DontOverlap(RGNote *a, RGNote *b, int minWidth) {
    if (!a) return YES;
    if (a.time + a.duration > b.time) return NO;
    if (a.time + minWidth > b.time) return NO;
    return YES;
}

////
/// STATIC VARIABLES
//


Piece *thePiece1 = nil, *thePiece2 = nil;
NSData *theLastHash;
LibraryItem *theItem = nil;
NSArray *theNotes;
NSMutableArray *theStats;
Song *theSong;
float theVolume;

@implementation SongOptions {
    
}

+ (void)initialize {
    [self loadFromDefaults];
    theStats = [NSMutableArray new];
    theVolume = 10.0;
}

+ (void) invalidate {
    theLastHash = nil;
}


////
# pragma mark - SONG OPTIONS
//

+ (NSArray *)Channels {
    return theItem.Arrangement.Channels;
}

+ (NSString *)MidiFile {
    return theItem.Arrangement.MidiFile;
}
+ (void)setVolume:(float)aVolume {
    theVolume = aVolume;
}

+ (float)volume {
    return theVolume;
}

+ (void)setCurrentItem:(LibraryItem *)item isSameItem:(BOOL)same {
    [self setCurrentItem:item isSameItem:same setList:NO];
}

+ (void)setCurrentItem:(LibraryItem *)item isSameItem:(BOOL)same setList:(BOOL)setlist {
    _isCurrentItemJukebox = setlist;
    theItem = item;
    
    if (item) {
        item.lastPlayed = (int)[NSDate.date timeIntervalSince1970];
        @try {
            [LibraryManager updateItem:item];
        } @catch (NSException *e) {
            NSLog(@"%@", e);
        }
    }
    theLastHash = nil;
    if (same) {
        theLastHash = [self getHash];
    }
    if (!item) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SongOptions"];
    }
}
+ (BOOL)isCurrentItemJukebox {
    return  _isCurrentItemJukebox;
}

+ (LibraryItem *)CurrentItem {
    return theItem;
}

+ (void) setChannels:(NSArray *)channels {
    if (![self MidiFile]) {
        [NSException raise:@"Invalid call to setChannels" format:@"setChannels was called when there was no midi file specified"];
    }
    theItem.Arrangement.Channels = channels;
}

+ (NSArray *)activeChannels {
    NSMutableArray *theList = [NSMutableArray new];
    for (Channel *theChannel in [self Channels]) {
        if (theChannel.Active == CH_ACTIVE) {
            [theList addObject:[NSNumber numberWithInt:theChannel.Number]];
        }
    }
    if (theList.count == 0 && [[self Channels] count]) {
        [theList addObject:@(0)];
    }
    return theList;
}

+ (NSArray *)mutedChannels {
    NSMutableArray *channels = [NSMutableArray new];
    for (Channel *theChannel in [self Channels]) {
        if (theChannel.Active == CH_MUTE) {
            [channels addObject:[NSNumber numberWithInt:theChannel.Number]];
        }
    }
    return channels;
}

+ (int)activeChannel {
    for (Channel *theChannel in [self Channels]) {
        if (theChannel.Active == CH_ACTIVE) {
            return theChannel.Number;
        }
    }
    return 0;
}

+ (NSArray *)inactiveChannels {
    //    NSMutableSet *theSet = [NSMutableSet new];
    //    for (int i = 0; i < 16; i++) {
    //        [theSet addObject:[NSNumber numberWithInt:i]];
    //    }
    //
    //    for (Channel *theChannel in [self Channels]) {
    //        if (theChannel.Active) {
    //            [theSet removeObject:[NSNumber numberWithInt:theChannel.Number]];
    //        }
    //    }
    //
    //    return [theSet allObjects];
    
    NSMutableArray *channels = [NSMutableArray new];
    for (Channel *theChannel in [self Channels]) {
        if (theChannel.Active == CH_ACCOMP) {
            [channels addObject:[NSNumber numberWithInt:theChannel.Number]];
        }
    }
    return channels;
}


////
# pragma mark - DIFFICULTY
//

+ (void) setChorded:(BOOL)chorded {
    [theItem.Arrangement setChorded:chorded];
}

//+ (void) setColumned:(BOOL)columned {
//    [theItem.Arrangement setColumned:columned];
//}

+ (void)setKeyboardType:(KeyboardType)type {
    theItem.Arrangement.keyboardType = type;
}

+ (void)setTwoRow:(BOOL)twoRow {
    [theItem.Arrangement setTwoRow:twoRow];
}

+ (void) setExmatch:(BOOL)exmatch {
    [theItem.Arrangement setExmatch:exmatch];
}

+ (BOOL) isChorded {
    return theItem.Arrangement.Chorded;
}

//+ (BOOL) isColumned {
//    return theItem.Arrangement.Columned;
//}

+ (KeyboardType)keyboardType {
    return  theItem.Arrangement.keyboardType;
}

+ (BOOL)isTwoRow {
    return  theItem.Arrangement.TwoRow;
}

+ (BOOL) isExmatch {
    return theItem.Arrangement.Exmatch;
}

+ (BOOL)needsToLoad {
    return !theLastHash || ![theLastHash isEqualToData:[self getHash]];
}

+ (void)loadIntroSong {
    NSArray *items = [LibraryManager getAllItems];
    for (LibraryItem *item in items) {
        if ([item.Title hasPrefix:@"Jingle"] && item.Type == LibraryItemTypeArrangement) {
            [SongOptions setCurrentItem:item isSameItem:NO];
        }
    }
//    theSong = [Conversions getSong:[[NSBundle mainBundle] pathForResource:@"0Jingle" ofType:@"mid"  soloChannels:<#(NSArray *)#> mutedChannels:<#(NSArray *)#>]
}

+ (Song *)getSong {
    if ([self needsToLoad]) {
        theSong = [Conversions getSong:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:[self CurrentItem].Arrangement.MidiFile] soloChannels:[self activeChannels] mutedChannels:[self mutedChannels]];
        //  NSLog(@"jreader notes - %.2f sec", CACurrentMediaTime() - time);
        char difficulty = 'i';
        if ([self isColumnFingering]) {
            difficulty = 'b';
        }
        long seed = 12523524;
        if ([[self CurrentItem].Title.lowercaseString rangeOfString:@"champions"].location == NSNotFound) {
            seed = (long)([self CurrentItem].Arrangement.MidiFile.hash + 55);
        }
        //float time = CACurrentMediaTime();
       
      //  NSLog(@"assign fingering: %.0f", 1000.0 * (CACurrentMediaTime() - time));
       // [self reduceChordsToTwoNotesMax];
        
        if ([[self CurrentItem].Title hasPrefix:@"Final Fantasy VI - Terra's Theme"]) {
            SpecialEvent *e = [SpecialEvent new];
            e.channel = [[[self activeChannels] lastObject] intValue];
            e.value = 75;
            e.time = 27450;
            e.type = SpecialEventTypeProgramChange;
            for (int i = 0; i < theSong.specialEvents.count; i++) {
                SpecialEvent *event = theSong.specialEvents[i];
                if (event.time > e.time) {
                    [(NSMutableArray *)theSong.specialEvents insertObject:e atIndex:i];
                    break;
                }
            }
        }
        
        if ([self isChorded]) {
            theSong.soloNotes = [Conversions applyChording:theSong.soloNotes quantum:theSong.division/24];
        }
        
         [ComAqwertianFingeringAqwertian assignFingering:theSong.soloNotes difficulty:'i' seed:seed chordQuantum:theSong.division*4/24 trillQuantum:theSong.division*5/24];
        
        [self fixNotes];
        
        if ([self isColumnFingering]) {
            [Conversions applyColumns:theSong.soloNotes];
        }
        
        if (![self isExmatch]) {
            [self arrangeNotesForNonExmatch];
        }
        
        
        if ([self keyboardType] == KeyboardTypeThumbPiano || [self isTwoRow]) {
            [self adjustNotesForSingleKeyPerHand];
        }
        if ([self keyboardType] == KeyboardTypeThumbPiano) {
            NSMutableArray *notes = (NSMutableArray *)theSong.soloNotes;
            for (RGNote *n in notes) {
                n.qwerty = ToNumberKey(n.qwerty);
            }
        }
        
        theLastHash = [self getHash];
        [theStats removeAllObjects];
        [self saveToDefaults];
    }
    return theSong;
}

+ (void) arrangeNotesForNonExmatch {
    //    NSMutableArray *notes = (NSMutableArray *)theSong.soloNotes;
    //    NSMutableArray *bandNotes = (NSMutableArray *)theSong.bandNotes;
    //    BOOL changes = NO;
    //    RGNote *current[8];
    //    for (int i = 0; i < 8; i++) {
    //        current[i] = nil;
    //    }
    //    for (int i = 0 ; i < notes.count; i++) {
    //        RGNote *n = notes[i];
    //        int col = [Conversions columnForKey:n.qwerty];
    //        RGNote *c = current[col];
    //        if (c) {
    //            if (c.time + c.duration > n.time) {
    //                [bandNotes addObject:n];
    //                [notes removeObjectAtIndex:i];
    //                i--;
    //                changes = YES;
    //                continue;
    //            }
    //        }
    //        current[col] = n;
    //    }
    //
    //
    //
    //
}

//+ (NSArray *)getNotes {
//    if ([self needsToLoad]) {
//        if (theItem.Type == LibraryItemTypeRecording && theItem.Arrangement.Notes) {
//            theNotes = theItem.Arrangement.Notes;
//        } else {
//            theNotes = [ComAqwertianFingeringAqwertian GetNotesForFile:[SongOptions CurrentItem].Arrangement.MidiFile difficulty:'a' channels:[SongOptions activeChannels] exmatch:YES];
//            [self fixNotes];
//            [self applySettings];
//        }
//        theLastHash = [self getHash];
//        theStats = nil;
//    }
//    return theNotes;
//}

+ (void)addStats:(Statistics *)stats {
    if ([self CurrentItem].Type == LibraryItemTypeArrangement) {
        LibraryItem *item = [self CurrentItem];
        if (item.Arrangement.statsHistory == nil) {
            item.Arrangement.statsHistory = [NSMutableArray new];
        }
        [[self CurrentItem].Arrangement.statsHistory insertObject:stats atIndex:0];
        [LibraryManager updateItem:[self CurrentItem]];
        [self saveToDefaults];
      //  [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [theStats insertObject:stats atIndex:0];
    }
}

+ (NSArray *)currentStats {
    if ([self CurrentItem].Type == LibraryItemTypeArrangement) {
        return [self CurrentItem].Arrangement.statsHistory;
    } else {
        return theStats;
    }
}

//+ (void) reduceChordsToTwoNotesMax {
//    NSMutableArray *notes = (NSMutableArray *)theSong.soloNotes;
//    NSMutableArray *newNotes = @[].mutableCopy;
//    int quantum = theSong.division/24;
//    
//    NSMutableArray *chord = [NSMutableArray array];
//    int time = -1;
//    int i = 0;
//    
//    // First we traverse the list and collect groups of notes with the same start time
//    for (RGNote *n in notes) {
//        i++;
//        
//        // If we are on a new chord, process the current group
//        if (ABS(n.time - time) > quantum) {
//            
//            // Now each note in the group has the same start time. We need to create subgroups according to duration
//            [self extractChords:chord intoNotes:newNotes];
//            [chord removeAllObjects];
//            
//            // update the time
//            time = n.time;
//        }
//        
//        // Add this note to the chord
//        [chord addObject:n];
//    }
//    [self extractChords:chord intoNotes:newNotes];
//    theSong.soloNotes = newNotes;
//}
//
//
//
//+ (void) extractChords:(NSMutableArray *)chord intoNotes:(NSMutableArray *)notes {
//    RGNote *anchor;
//    RGNote *other;
//    
//    static NSSet *goodCombos = nil;
//    static char test[3];
//    if (!goodCombos) {
//        NSArray *all = @[@"ns", @"js"];
//        goodCombos = [NSSet setWithArray:all];
//        test[2] = '\0';
//    }
//    
//    if (!chord.count) return;
//    
//    if (chord.count <= 2) {
//        [notes addObjectsFromArray:chord];
//        return;
//    }
//    
//    // The note with the shortest duration is the anchor
//    RGNote *minNote = chord[0];
//    for (RGNote *note in chord) {
//        if (note.duration < minNote.duration) {
//            minNote = note;
//        } else if (!other && note != minNote) {
//            test[0] = minNote.qwerty;
//            test[1] = note.qwerty;
//            NSString *s = [[NSString alloc] initWithBytesNoCopy:test length:3 encoding:NSUTF8StringEncoding freeWhenDone:NO];
//            if ([goodCombos containsObject:s]) {
//                other = note;
//            }
//        }
//    }
//    anchor = minNote;
//    
//    if (!other) {
//        for (RGNote *n in chord) {
//            if (n != anchor) {
//                other = n;
//                break;
//            }
//        }
//    }
//    
//    NSMutableArray *ties = [NSMutableArray new];
//    for (RGNote *note in chord) {
//        if (note != anchor && note != other) {
//            [ties addObject:note];
//            note.tie = YES;
//        }
//    }
//    
//    if (ties.count) {
//        anchor.tieNotes = ties;
//    }
//    [notes addObject:anchor];
//    [notes addObject:other];
//}

+ (void) adjustNotesForSingleKeyPerHand {
    NSMutableArray *notes = (NSMutableArray *)theSong.soloNotes;
    NSMutableArray *bandNotes = (NSMutableArray *)theSong.bandNotes;
    BOOL changes = NO;
    RGNote *current[2];
    for (int i = 0; i < 2; i++) {
        current[i] = nil;
    }
    RGNote *currentNote;
    
    int minWidth = (int)[[NZNotationDisplay sharedDisplay] minimumTicksWidthForDivision:theSong.division singleKeyPerHand:YES];

    int rightLeft;
    for (int i = 0; i < notes.count; i++) {
        RGNote *n = notes[i];
        rightLeft = (int)IsLeftHand(n.qwerty);
        currentNote = current[rightLeft];
        if (!DontOverlap(currentNote, n, minWidth)) {
            rightLeft = rightLeft == 0 ? 1 : 0;
            currentNote = current[rightLeft];
             if (!DontOverlap(currentNote, n,minWidth)) {
                 [notes removeObjectAtIndex:i];
                 i--;
                 n.removedFromUserNotes = YES;
                 [bandNotes addObject:n];
                 changes = YES;
             } else {
                 n.qwerty = anyCharForHand(rightLeft);
                 current[rightLeft] = n;
             }
        } else {
            current[rightLeft] = n;
        }
    }
    
    if (changes) {
        [bandNotes sortUsingSelector:@selector(compare:)];
    }

}

char anyCharForHand(int rightLeft) {
    static char left[4] = {'A','S','D','F'};
    static char right[4] = {'J','K','L',';'};
    if (rightLeft == 1) {
        return left[arc4random()%4];
    } else {
        return right[arc4random()%4];
    }
}

+ (BOOL) isColumnFingering {
    return IS_COLUMN_FINGERING([self keyboardType], [self isTwoRow]);
}

+ (void) fixNotes {
    //    for (int i = theNotes.count-1; i > -1; i--) {
    //        RGNote *n = theNotes[i];
    //        if (n.volume == 0 && n.note != 0) {
    //            [(NSMutableArray *)theNotes removeObjectAtIndex:i];
    //        } else if (n.duration > 3000) {
    //           // n.duration = 3000;
    //        }
    //    }
    
    
    
    NSMutableArray *notes = (NSMutableArray *)theSong.soloNotes;
    NSMutableArray *bandNotes = (NSMutableArray *)theSong.bandNotes;
    BOOL changes = NO;
    RGNote *current[8];
    for (int i = 0; i < 8; i++) {
        current[i] = nil;
    }
    int minWidth = (int)[[NZNotationDisplay sharedDisplay] minimumTicksWidthForDivision:theSong.division singleKeyPerHand:NO];
    
    BOOL canReposition = ![SongOptions isExmatch] || [self isColumnFingering];
    
    for (int i = 0 ; i < notes.count; i++) {
        RGNote *n = notes[i];
        int col = [Conversions columnForKey:n.qwerty];
        if (canReposition) {
            if (DontOverlap(current[col], n, minWidth)) {
                current[col] = n;
                // good
            } else {
                int above = col+1;
                int below = col-1;
                while (1) {
                    if (above < 8) {
                        if (DontOverlap(current[above], n,minWidth)) {
                            n.qwerty = keyForColumn(above);
                            current[above] = n;
                            break;
                        }
                    }
                    if (below > -1) {
                        if (DontOverlap(current[below], n,minWidth)) {
                            n.qwerty = keyForColumn(below);
                            current[below] = n;
                            break;
                        }
                    }
                    if (above > 7 && below < 0) {
                        [bandNotes addObject:n];
                        [notes removeObjectAtIndex:i];
                        n.removedFromUserNotes = YES;
                        i--;
                        changes = YES;
                        break;
                    }
                    above++;
                    below--;
                }
            }
        } else {
            RGNote *c = current[col];
            if (!DontOverlap(c, n,minWidth)) {
                [bandNotes addObject:n];
                [notes removeObjectAtIndex:i];
                n.removedFromUserNotes = YES;
                i--;
                changes = YES;
                continue;
                
            } else {
                current[col] = n;
            }
        }
        
    }
    
    if (changes) {
        [bandNotes sortUsingSelector:@selector(compare:)];
    }
}


//+ (void)applySettings {
//
//    if ([self isColumned]) {
//        [Conversions applyColumns:theSong.soloNotes];
//    }
//
//    if ([self isChorded]) {
//        theSong.soloNotes = [Conversions applyChording:theSong.soloNotes quantum:theSong.division/24];
//    }
// 
//}

//+ (Piece *) getPiece {
//    if (![self shouldCreatePiece]) {
//        [self saveToDefaults];
//        thePiece1->autoplay = 0;
//        return thePiece1;
//    }
//
//    if ([self shouldCreateMusFile]) {
//        [self createMusFile];
//    }
//
//    [self createPiece];
//    [self saveToDefaults];
//
//    thePiece1->bandplay = [self hasBandPiece];
//    return thePiece1;
//}

+ (Piece *)getPieceForAutoplay {
    Piece *piece = [self getPiece];
    piece->autoplay = 1;
    return piece;
}

+ (Piece *)getBandPiece {
    if (![self shouldCreatePiece]) {
        return thePiece2;
    }
    [self createPiece];
    if (thePiece2) {
        thePiece2->autoplay = 1;
        thePiece2->bandplay = YES;
    }
    return thePiece2;
}

+ (BOOL)hasBandPiece {
    return [self inactiveChannels].count > 0;
}

//+ (void) createMusFile {
//    // Remove the old mus file for this song
//    if ([self MusFile1] && [self MusFile1].length > 0) {
//        [Util deleteFile:[self MusFile1]];
//    }
//
//    if ([self MusFile2] && [self MusFile2].length > 0) {
//        [Util deleteFile:[self MusFile2]];
//    }
//    theItem.Arrangement.UserMusFile = [self musFileForMidiFile:[self MidiFile]];
//    theItem.Arrangement.BandMusFile = [[[theItem.Arrangement.UserMusFile stringByDeletingPathExtension] stringByAppendingString:@"__BAND"] stringByAppendingPathExtension:@"mus"];
//
//    // Create the new mus file
//    [ComAqwertianFingeringAqwertian ConvertToMusWithNSString:[self MidiFile] withNSString:[self MusFile1] withUnichar:'b' withJavaUtilArrayList:[SongOptions activeChannels] withBOOL:YES];
//    if ([self hasBandPiece]) {
//        [ComAqwertianFingeringAqwertian ConvertToMusWithNSString:[self MidiFile] withNSString:[self MusFile2] withUnichar:'b' withJavaUtilArrayList:[self inactiveChannels] withBOOL:YES];
//    }
//}

+ (void) createPiece {
    if (![self MidiFile]) {
        [NSException raise:@"Bad call to createPiece" format:@"createPiece was called with no file specified"];
    }
    
    // Delete the old piece
    if (thePiece1) {
        //  [InputHandler deletePiece:thePiece1];
        thePiece1 = nil;
    }
    if (thePiece2) {
        //[InputHandler deletePiece:thePiece2];
        thePiece2 = nil;
    }
    //thePiece1 = [[MusFileManager sharedManager] loadMusFile:[self MusFile1]];
    
    if ([self hasBandPiece]) {
        //  thePiece2 = [[MusFileManager sharedManager] loadMusFile:[self MusFile2]];
    }
    
    // Apply settings
    // [self applySettings];
    
    // Save
    theLastHash = [SongOptions getHash];
    
}

//+ (void) applySettings {
//    if (thePiece1 == nil) {
//        [NSException raise:@"Bad call to applySettings" format:@"applySettings was called with no piece"];
//    }
//
//    if (![self isExmatch]) {
//        [Conversions removeExmatch:thePiece1];
//    }
//    if ([self isChorded]) {
//        [Conversions doChording:thePiece1];
//    }
//    if ([self isColumned]) {
//        [Conversions doColumns:thePiece1];
//    }
//    [Conversions normalizeNoteWidths:thePiece1];
//}

+ (NSString *)filePathWithName:(NSString *)aName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:aName];
}

+ (NSString *)musFileForMidiFile:(NSString *)aFile {
    return [[Util musFilesDirectory] stringByAppendingPathComponent:[[[aFile lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"mus"]];
}


////
# pragma mark - STATE CHANGES
//

+ (NSDictionary *)getDictionary {
    NSMutableArray *tmp = theItem.Arrangement.statsHistory;
    theItem.Arrangement.statsHistory = [NSMutableArray array];
    NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[theItem toDictionary], @"Item", nil];
    theItem.Arrangement.statsHistory = tmp;
    
    return theDict;
}

+ (NSData *) getHash {
    return [NSJSONSerialization dataWithJSONObject:[self getDictionary] options:kNilOptions error:nil];
}

+ (BOOL)shouldCreatePiece {
    
    if (theLastHash == nil || thePiece1 == nil || ([self hasBandPiece] && thePiece2 == nil)) {
        return YES;
    }
    
    return ![theLastHash isEqualToData:[SongOptions getHash]];
}

+ (BOOL) shouldCreateMusFile {
    if (!theLastHash) {
        return ([self MusFile1] == nil || [self MusFile1].length == 0 || ![Util fileExists:[self MusFile1]] || [self MusFile2] == nil || [self MusFile2].length == 0 || ![Util fileExists:[self MusFile2]]);
    }
    NSDictionary *old = [NSJSONSerialization JSONObjectWithData:theLastHash options:kNilOptions error:nil];
    NSArray *oldChannels = [[old objectForKey:@"Item"] objectForKey:@"Channels"];
    
    if (oldChannels.count != [self Channels].count) {
        return YES;
    }
    
    for (int i = 0; i < [self Channels].count; i++) {
        if ([[[self Channels] objectAtIndex:i] Active] != [[oldChannels objectAtIndex:i] boolForKey:@"Active"]) {
            return YES;
        }
    }
    
    return NO;
}

+ (void) loadFromDictionary:(NSDictionary *)aDictionary {
    if (aDictionary == nil) {
        return;
    }
    theItem = [LibraryItem fromDictionary:[aDictionary objectForKey:@"Item"]];
}

+ (void) saveToDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:[self getDictionary] forKey:@"SongOptions"];
   // [[NSUserDefaults standardUserDefaults] synchronize];
    //[LibraryManager updateItem:theItem];
}

+ (void) loadFromDefaults {
    [self loadFromDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"SongOptions"]];
}

@end


