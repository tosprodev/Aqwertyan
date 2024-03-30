//
//  LibraryManager.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "LibraryManager.h"
#import "Util.h"
#import <CommonCrypto/CommonDigest.h>
#import "InputHandler.h"
#import "Base64.h"
#import "NZURLRequest.h"

#define HASHES_KEY @"_song_hashes"
#define ARR_KEY @"_song_arrangements"
#define SETLIST_KEY @"_setlist"

static LibraryManager *theLibraryDelegate;

NSMutableSet *connections;

#define MELODY_TRACK_KEY(a) [NSString stringWithFormat:@"MTRK_%@", a]

@implementation LibraryManager

+ (void)initialize {
    [super initialize];
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Favorites"]) {
//        [[NSUserDefaults standardUserDefaults] setObject:[NSArray new] forKey:@"Favorites"];
//    }
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Arrangements"]) {
//        [[NSUserDefaults standardUserDefaults] setObject:[NSArray new] forKey:@"Arrangements"];
//    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray new] forKey:@"LibraryItems"];
    }
    theLibraryDelegate = [LibraryManager new];
}

+ (void)updateItem:(LibraryItem *)item {
    NSMutableArray *list = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"]];
    int index = [self findItem:item inList:list];
    if (index > -1) {
        [list replaceObjectAtIndex:index withObject:[item toDictionary]];
        [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"LibraryItems"];
       // [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [NSException raise:@"Bad call to updateItem:" format:@"Item is not in the library"];
    }
}

+ (BOOL)hasPurchasedSongWithData:(NSData *)songData {
    return [[self allHashes] containsObject:[self sha1:songData]];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}

+ (BOOL)addItem:(LibraryItem *)item {
    item.Date = [LibraryItem currentDateString];
    if ([InputHandler getTracks:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile]] == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"This midi file is invalid." delegate:theLibraryDelegate cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return NO;
    }
    int count = 2;
    NSString *base = item.Title;
    NSMutableArray *list = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"]];
    while ([self findItem:item inList:list] != -1) {
        item.Title = [base stringByAppendingFormat:@"-%d", count];
        count++;
    }
    [list addObject:[item toDictionary]];
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"LibraryItems"];
    if (item.Type == LibraryItemTypeFile) {
        [self addHashForFile:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile]];
    }
    return YES;
}

+ (void) getMelodyTrackForMidiFile:(NSString *)file completion:(void(^)(int track, BOOL isChannel))completion {
    [self getMelodyTrack:file completion:^(int track, BOOL isChannel, BOOL timedOut, BOOL alreadyGetting) {
        
        if (timedOut || alreadyGetting) {
            if (completion) {
                completion(-1, isChannel);
            }
        } else {
            [self setMelodyTrack:track isChannel:isChannel forMidiFile:file];
            if (completion) {
                completion(track, isChannel);
            }
        }
    }];
}

+ (void) getMelodyTrack:(NSString *)midiFile completion:(void(^)(int track, BOOL isChannel, BOOL timedOut, BOOL alreadyGetting))completion {
    if (!connections) connections = NSMutableSet.new;
    
    if ([connections containsObject:midiFile]) {
        completion(-1, NO,NO, YES);
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:midiFile];
    if (data) {
        NSString *base64 = [Base64 encode:data];
        NSDictionary *args = @{@"Base64Data" : base64, @"FileName" : [midiFile lastPathComponent]};
   

    [NZURLConnection postObject:args toURL:@"http://173.248.133.197/MelodyTrack/GetMelodyTrack" withTimeout:30 easyCompletionHandler:^(int status, NSDictionary *results) {
        [connections removeObject:midiFile];
        if (status == NZURL_SUCCESS) {
            int melodyTrack = [results[@"MelodyTrack"] intValue];
            BOOL isChannel = [results[@"IsChannel"] boolValue];
            completion(melodyTrack, isChannel, NO, NO);
        } else if (status == NZURL_ERROR_RESULTS) {
            completion(-1,NO, NO, NO);
        } else {
            completion(-1,NO, YES, NO);
        }
    }];
    }
}

+ (void) setMelodyTrack:(int)track isChannel:(BOOL)channel forMidiFile:(NSString *)midiFile {
    [[NSUserDefaults standardUserDefaults] setObject:@[@(track), @(channel)] forKey:MELODY_TRACK_KEY(midiFile)];
}

+ (BOOL) hasMelodyTrackForMidiFile:(NSString *)midiFile {
    NSArray *a = [[NSUserDefaults standardUserDefaults] objectForKey:MELODY_TRACK_KEY(midiFile)];
    if (a && [a isKindOfClass:[NSArray class]]) {
        return YES; //[a[1] intValue] > -1;
    }
    return NO;
}

+ (int) melodyTrackForMidiFile:(NSString *)midiFile isChannel:(BOOL *)channel {
    NSArray *a = [[NSUserDefaults standardUserDefaults] objectForKey:MELODY_TRACK_KEY(midiFile)];
    if (a && [a isKindOfClass:[NSArray class]]) {
        *channel = [a[1] intValue];
        return [a[0] intValue];
    }
    return -2;
}

+ (NSArray *)getAllItems {
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"];
    NSMutableArray *items = [NSMutableArray new];
    for (NSDictionary *dict in list) {
        [items addObject:[LibraryItem fromDictionary:dict]];
    }
    return items;
}

+ (BOOL) fileItemHasDependenciesThatWillBeDeleted:(LibraryItem *)anItem {
    if (anItem.Type != LibraryItemTypeFile) {
        return NO;
    }
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"];
    if (!list) return NO;
    for (NSDictionary *item in list) {
        if ([item[@"Type"] intValue] == LibraryItemTypeArrangement && [item[@"Arrangement"][@"MidiFile"] isEqualToString:anItem.Arrangement.MidiFile]) {
            return YES;
        }
    }
    return NO;
}

+ (void)deleteItem:(LibraryItem *)item {
    NSMutableArray *list = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"]];
    int index = [self findItem:item inList:list];
    if (index > -1) {
        [list removeObjectAtIndex:index];
        
        
        if (item.Type == LibraryItemTypeFile) {
            NSString *path = [[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile];
            [self removeHashForData:[NSData dataWithContentsOfFile:path]];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            for (int i = list.count-1; i > -1; i--) {
                NSDictionary *libItem = list[i];
                if ([libItem[@"Arrangement"][@"MidiFile"] isEqualToString:item.Arrangement.MidiFile]) {
                    [list removeObjectAtIndex:i];
                }
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"LibraryItems"];
        
    } else {
        [NSException raise:@"Bad call to updateItem:" format:@"Item is not in the library"];
    }
}

+ (void)setNewTitle:(NSString *)title forItem:(LibraryItem *)item {
    NSMutableArray *list = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"]];
    int index = [self findItem:item inList:list];
    if (index > -1) {
        item.Title = title;
        [list replaceObjectAtIndex:index withObject:[item toDictionary]];
        [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"LibraryItems"];
    } else {
        [NSException raise:@"Bad call to updateItem:" format:@"Item is not in the library"];
    }
}

+ (void) setItemAsFavorite:(LibraryItem *)item {
    if (!item.Favorite) {
        [NSException raise:@"Bad call to setItemAsFavorite:" format:@"Item is not a favorite"];
    }
    [self updateItem:item];
}
+ (void) removeItemFromFavorites:(LibraryItem *)item {
    if (item.Favorite) {
        [NSException raise:@"Bad call to removeItemFromFavorites:" format:@"Item is a favorite"];
    }
    [self updateItem:item];
}

+ (void)setItemAsJukebox:(LibraryItem *)item {
    if (!item.Jukebox) {
        [NSException raise:@"Bad call to setItemAsJukebox:" format:@"Item is not a jukebox"];
    }
    [self updateItem:item];
}

+ (void)removeItemFromJukebox:(LibraryItem *)item    {
    if (item.Jukebox) {
        [NSException raise:@"Bad call to removeItemFromJukebox:" format:@"Item is a jukebox"];
    }
    [self updateItem:item];
}



+ (NSInteger) findItem:(LibraryItem *)item inList:(NSArray *)list {
    int i = 0;
    for (NSDictionary *dict in list) {
        if  ([[dict objectForKey:@"Title"] isEqualToString:item.Title] && [[dict objectForKey:@"Type"] intValue] == item.Type) {
            return i;
        }
        i++;
    }
    return -1;
}

+ (NSArray *) allHashes {
    NSArray *set = [[NSUserDefaults standardUserDefaults] objectForKey:HASHES_KEY];
    if (!set) {
        set = [NSArray new];
    }
    return set;
}

+ (void) removeHashForData:(NSData *)songData {
    if (!songData) {
        return;
    }
    NSMutableArray *hashes = [NSMutableArray arrayWithArray:[self allHashes]];
    [hashes removeObject:[self sha1:songData]];
    [self saveHashes:hashes];
}

+ (void) addHashForData:(NSData *)songData {
    if (!songData) {
        return;
    }
    NSMutableArray *hashes = [NSMutableArray arrayWithArray:[self allHashes]];
    [hashes addObject:[self sha1:songData]];
    [self saveHashes:hashes];
    
}

+ (NSString*) sha1:(NSData*)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

+ (void) saveHashes:(NSArray *)hashes {
    [[NSUserDefaults standardUserDefaults] setObject:hashes forKey:HASHES_KEY];
}

+ (void)noteArrangementForFutureSong:(Arrangement *)arr {
    NSDictionary *arrs = [[NSUserDefaults standardUserDefaults] objectForKey:ARR_KEY];
    if (!arrs) {
        arrs = [NSDictionary new];
    }
    NSMutableDictionary *mutArrs = [NSMutableDictionary dictionaryWithDictionary:arrs];
    
    if (arr.fileData) {
        NSData *tmp = arr.fileData;
        arr.fileData = nil;
        [mutArrs setObject:[arr toDictionary] forKey:[self sha1:tmp]];
        arr.fileData = tmp;
    } else {
        NSString *path = [[Util uploadedSongsDirectory] stringByAppendingPathComponent:arr.MidiFile];
        [mutArrs setObject:[arr toDictionary] forKey:[self sha1:[NSData dataWithContentsOfFile:path]]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutArrs forKey:ARR_KEY];
}

+ (void) addHashForFile:(NSString *)path {
    [self addHashForData:[NSData dataWithContentsOfFile:path]];
}

+ (LibraryItem *)addSong:(NSString *)aFilePath {
    NSString *base = [[Util uploadedSongsDirectory] stringByAppendingPathComponent:[aFilePath lastPathComponent]];
    NSString *newPath = [self findUniquePathName:base];
    NSData *data = [NSData dataWithContentsOfFile:aFilePath];
    [[NSFileManager defaultManager] moveItemAtPath:aFilePath toPath:newPath error:nil];
    
    
    // Check if this song has any associated arrangements waiting on it
    NSDictionary *arrs = [[NSUserDefaults standardUserDefaults] objectForKey:ARR_KEY];
    NSString *hash = [self sha1:data];
    NSDictionary *a = [arrs objectForKey:hash];
    
    if (a) {
        Arrangement *arr = [Arrangement fromDictionary:a];
        arr.MidiFile = [newPath lastPathComponent];
        if ([self addItem:[LibraryItem withArrangement:arr]]) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:arrs];
            [d removeObjectForKey:hash];
            [[NSUserDefaults standardUserDefaults] setObject:d forKey:ARR_KEY];
        } else {
            //return NO; //meh
        }
    }
    LibraryItem *item = [LibraryItem itemWithFile:[newPath lastPathComponent]];
    return [self addItem:item] ? item : nil;
}

+ (NSString *) findUniquePathName:(NSString *)path {
    NSString *base = path;
    int ct = 2;
    while ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[base stringByDeletingPathExtension] stringByAppendingFormat:@"-%d.mid", ct++];
    }
    return path;
}

+(NSArray *)setlist {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETLIST_KEY];
}

+ (void)saveSetlist:(NSArray *)songTitles {
    [[NSUserDefaults standardUserDefaults] setObject:songTitles forKey:SETLIST_KEY];
}

+ (LibraryItem *)setlistItemAfterItem:(LibraryItem *)item {
    NSString *title = item.Title;
    NSArray *setlist = [self setlist];
    if ([setlist containsObject:title]) {
        int index = [setlist indexOfObject:title];
        if (index < setlist.count - 1) {
            NSString *nextTitle = setlist[index+1];
            return [self findItemWithTitle:nextTitle];
        } else {
            return [self findItemWithTitle:setlist[0]];
        }
    }
    return nil;
}

+ (LibraryItem *)findItemWithTitle:(NSString *)title {
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryItems"];
    for (NSDictionary *item in list) {
        if ([item[@"Title"] isEqualToString:title]) {
            return [LibraryItem fromDictionary:item];
        }
    }
    return nil;
}

//
//+ (NSArray *)getAllSongs {
//    return [Util allFilesAtPath:[Util uploadedSongsDirectory]];
//}
//
//+ (NSArray *)getArrangements {
//    NSArray *list =  [[NSUserDefaults standardUserDefaults] objectForKey:@"Arrangements"];
//    NSMutableArray *theList = [NSMutableArray new];
//    
//    for (NSDictionary *theDict in list) {
//        [theList addObject:[Arrangement fromDictionary:theDict]];
//    }
//    
//    return theList;
//}
//
//+ (NSArray *)getFavorites {
//    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Favorites"];
//}
//
//+ (void)addFavorite:(NSString *)aSong {
//    if ([[self getAllSongs] containsObject:aSong]) {
//        NSMutableArray *list = [NSMutableArray arrayWithArray:[self getFavorites]];
//        if ([list containsObject:aSong]) {
//            NSLog(@"warning - adding a favorite that already exists");
//        }
//        [list addObject:aSong];
//        [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"Favorites"];
//    }
//}
//
//+ (void)removeFavorite:(NSString *)aSong {
//    NSMutableArray *list = [NSMutableArray arrayWithArray:[self getFavorites]];
//    [list removeObject:aSong];
//    [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"Favorites"];
//}
//
//+ (void)addArrangement:(Arrangement *)anArrangement {
//    NSMutableArray *list = [NSMutableArray arrayWithArray:[self getArrangements]];
//    [list addObject:[anArrangement toDictionary]];
//    [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"Arrangements"];
//}

@end
