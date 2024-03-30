//
//  FileConverter.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/20/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "mus.h"
//#import "mid2jmid.h"
//#import "Structs.h"

#define TEMPO_TO_TPS(tempo,div) (double)div / (double)tempo * 1000000.0;

int NoteToColumn(unichar note);

@class Song;
@interface Conversions : NSObject

//+ (void) doChording:(Piece *)aPiece;
//+ (void) removeExmatch:(Piece *)aPiece;
//+ (void) doColumns:(Piece *)aPiece;
//+ (void) normalizeNoteWidths:(Piece *)aPiece;

+ (void) applyColumns:(NSArray *)notes;

+ (NSInteger)columnForKey:(char)key withChord:(int)chord;
+ (void) normalizeWidths:(NSArray *)notes;
+ (NSArray *) applyChording:(NSArray *)notes quantum:(int)quantum;
+ (NSArray *)getTracks:(NSString *)aFile;
+ (NSArray *)getEvents:(NSString *)aFile;
+ (NSInteger) columnForKey:(char)key;
+ (void) getKeysForKey:(char)key buffer:(int *)array;
+ (Song *) getSong:(NSString *)aFile soloChannels:(NSArray *)channelsToSolo mutedChannels:(NSArray *)channelsToMute;

@end

typedef NS_ENUM(int, SpecialEventType) {
    SpecialEventTypeTempoChange,
    SpecialEventTypeProgramChange,
    SpecialEventTypePedal
};

@interface SpecialEvent : NSObject

@property (nonatomic) SpecialEventType type;
@property (nonatomic) int channel;
@property (nonatomic) int value;
@property (nonatomic) int value2;
@property (nonatomic) int time;


@end

@interface Song : NSObject

@property (nonatomic) int division;
@property (nonatomic) int totalTicks;
@property (nonatomic) NSArray *specialEvents;
@property (nonatomic) NSArray *soloNotes;
@property (nonatomic) NSArray *bandNotes;
@property (nonatomic) NSArray *lyrics;
@property (nonatomic) BOOL hasLyrics;

@end
