//
//  SongOptions.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/30/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

typedef NS_ENUM(int, KeyboardType) {
    KeyboardTypeFullQwerty,
    KeyboardTypeFullPiano,
    KeyboardTypeThumbPiano,
    KeyboardTypeThumbQwerty
};

#define IS_COLUMN_FINGERING(keyboardType,isTwoRow) (keyboardType == KeyboardTypeFullPiano || keyboardType == KeyboardTypeThumbPiano || isTwoRow)

#import <Foundation/Foundation.h>
#import "mus.h"
#import "Aqwertian.h"
#import "MusFileManager.h"
#import "Conversions.h"
#import "LbraryItem.h"



@class LibraryItem;
@class  Statistics;
@class Arrangement;



@interface SongOptions : NSObject


////
/// SONG OPTIONS
//

+ (void) setChannels:(NSArray *)channels;

+ (NSArray *)Channels;
+ (NSString *)MidiFile;
+ (NSString *)MusFile1;
+ (NSString *)MusFile2;
+ (NSString *)FileName;
+ (NSString *)FilePath;

+ (int)activeChannel;

+ (NSArray *)activeChannels;
+ (NSArray *)inactiveChannels;
- (int) activeChannel;
+ (LibraryItem *)CurrentItem;
+ (void) setCurrentItem:(LibraryItem *)item isSameItem:(BOOL)same;
+ (void) setCurrentItem:(LibraryItem *)item isSameItem:(BOOL)same setList:(BOOL)setlist;
+ (void) revertToDefaults;
+ (void) addStats:(Statistics *)stats;
+ (NSArray *)currentStats;

+ (void) setVolume:(float)volume;
+ (float) volume;

+ (void) loadIntroSong;

+ (BOOL) isCurrentItemJukebox;


////
/// DIFFICULTY
//

+ (void) setChorded:(BOOL)chorded;
//+ (void) setColumned:(BOOL)columned;
+ (void) setExmatch:(BOOL)exmatch;
+ (void) setTwoRow:(BOOL)twoRow;

+ (BOOL) isChorded;
//+ (BOOL) isColumned;
+ (BOOL) isTwoRow;
+ (BOOL) isExmatch;
+ (void) invalidate;
+ (KeyboardType) keyboardType;
+ (void) setKeyboardType:(KeyboardType)type;

char toNumberKey(char letterKey);


////
/// PIECE
//

+ (Piece *) getPiece;
+ (Piece *) getPieceForAutoplay;
+ (Piece *) getBandPiece;
+ (BOOL) hasBandPiece;
+ (BOOL) needsToLoad;
//+ (NSArray *)getNotes;
+ (NSArray *)midiFile;
+ (Song *)getSong;



////
/// SAVING
//

+ (void) saveToDefaults;
+ (void) loadFromDefaults;


@end





