//
//  MidiSearchManager.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/13/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MidiSearchDelegate <NSObject>

- (void) searchFinished:(NSArray *)results;
- (void) searchFailed:(NSString *)reason;
- (void) downloadFailed:(NSString *)reason;
- (void) downloadFinished:(NSString *)path forSong:(NSString *)songName;

@end

@interface MidiSearchManager : NSObject

+ (BOOL) isSearching;
+ (void) searchFor:(NSString *)aQuery;
+ (void) cancel;
+ (void) setDelegate:(id<MidiSearchDelegate>)delegate;
+ (void) downloadSong:(int)result toDirectory:(NSString *)path;
+ (NSString *) downloadingSong;

@end
