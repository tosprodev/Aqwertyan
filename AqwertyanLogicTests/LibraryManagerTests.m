//
//  LibraryManagerTests.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/16/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "LibraryManagerTests.h"
#import "LibraryManager.h"
#import "SongOptions.h"

@implementation LibraryManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


- (void) testSongOptions_SetNewSong_SetsLastPlayedTime {
    LibraryItem *item = [LibraryManager getAllItems].lastObject;
    [SongOptions setCurrentItem:item isSameItem:NO];
    STAssertEqualsWithAccuracy(item.lastPlayed, (int)[[NSDate date] timeIntervalSince1970], 2, @"lastPlayed should be now");
}

- (void) testLibraryItem_SortByLastPlayedTime_Succeeds {
    LibraryItem *item1 = [LibraryItem new];
    item1.lastPlayed = 234;
    LibraryItem *item2 = [LibraryItem new];
    item2.lastPlayed = 222;
    LibraryItem *item3 = [LibraryItem new];
    item3.lastPlayed = 300;
    
    NSArray *items = @[item1, item2, item3];
    items = [items sortedArrayUsingSelector:@selector(compareLastTimePlayed:)];
    
    NSArray *expected = @[item3, item1, item2];
    STAssertEqualObjects(expected, items, @"");
}

- (void) testSongOptions_SetNewSong_SavesSongToLibraryManager {
    NSArray *items = [LibraryManager getAllItems];
    LibraryItem *item = items[arc4random()%items.count];
    [SongOptions setCurrentItem:item isSameItem:NO];
    items = [[LibraryManager getAllItems] sortedArrayUsingSelector:@selector(compareLastTimePlayed:)];
    STAssertEqualObjects(item.Arrangement.MidiFile, [items[0] Arrangement].MidiFile, @"");
}

@end
