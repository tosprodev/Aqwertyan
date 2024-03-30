//
//  LibraryManager.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Arrangement.h"
#import "LbraryItem.h"

@interface LibraryManager : NSObject <UIAlertViewDelegate>

//+ (void) addSong:(NSString *)aFilePath;
//+ (void) addFavorite:(NSString *)aSong;
//+ (void) removeFavorite:(NSString *)aSong;
+ (BOOL) addItem:(LibraryItem *)item;
+ (NSArray *)getAllItems;
+ (void) setItemAsFavorite:(LibraryItem *)item;
+ (void) removeItemFromFavorites:(LibraryItem *)item;
//+ (int) melodyTrackForMidiFile:(NSString *)midiFile;
+ (void) setItemAsJukebox:(LibraryItem *)item;
+ (void) removeItemFromJukebox:(LibraryItem *)item;
+ (LibraryItem *)addSong:(NSString *)aFilePath;
+ (void) updateItem:(LibraryItem *)item;
+ (void) setNewTitle:(NSString *)title forItem:(LibraryItem *)item;
+ (void) deleteItem:(LibraryItem *)item;
+ (BOOL) fileItemHasDependenciesThatWillBeDeleted:(LibraryItem *)item;
+ (void) noteArrangementForFutureSong:(Arrangement *)arr;
+ (BOOL) hasPurchasedSongWithData:(NSData *)songData;
+ (NSString *) findUniquePathName:(NSString *)path;
+ (void) getMelodyTrackForMidiFile:(NSString *)file completion:(void(^)(int track, BOOL isChannel))completion;
+ (BOOL) hasMelodyTrackForMidiFile:(NSString *)midiFile;
+ (int) melodyTrackForMidiFile:(NSString *)midiFile isChannel:(BOOL *)channel;

+ (NSArray *) setlist;
+ (void) saveSetlist:(NSArray *)songTitles;
+ (LibraryItem *) findItemWithTitle:(NSString *)title;
+ (LibraryItem *) setlistItemAfterItem:(LibraryItem *)item;
//
//+ (NSArray *) getAllSongs;
//+ (NSArray *) getArrangements;
//+ (NSArray *) getFavorites;
//+ (void) addArrangement:(Arrangement *)anArrangement;

@end
