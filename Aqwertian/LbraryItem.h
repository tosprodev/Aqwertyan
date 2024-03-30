//
//  LbraryItem.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/4/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Arrangement.h"

@class Arrangement;

typedef NS_ENUM(NSInteger, LibraryItemType) {
    LibraryItemTypeFile,
    LibraryItemTypeArrangement,
    LibraryItemTypeRecording
};

@interface LibraryItem : NSObject

@property (nonatomic) NSString *Title;
@property (nonatomic) LibraryItemType Type;
@property (nonatomic) Arrangement *Arrangement;
@property (nonatomic) BOOL Favorite, Jukebox;
@property (nonatomic) NSString *Date;
@property (nonatomic) int jukeboxOrder, lastPlayed;

+ (NSString *)currentDateString;

+ (id)fromDictionary:(NSDictionary *)aDict;
+ (id) itemWithFile:(NSString *)aFile;
+ (id) withArrangement:(Arrangement *)arr;
- (NSDictionary *)toDictionary;
- (NSComparisonResult) compareLastTimePlayed:(LibraryItem *)other;
- (NSComparisonResult) compareName:(LibraryItem *)other;
- (NSComparisonResult) compareNameReverse:(LibraryItem *)other;



@end
