//
//  LbraryItem.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/4/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "LbraryItem.h"

@implementation LibraryItem

+ (NSString *)currentDateString {
    static NSDateFormatter *df;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
    }
    return [df stringFromDate:[NSDate date]];
}

- (NSDate *) getDate {
    static NSDateFormatter *df;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
    }
    return [df dateFromString:self.Date];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *theDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.Title, @"Title",[NSNumber numberWithBool:self.Favorite], @"Favorite", [NSNumber numberWithInt:self.Type], @"Type", self.Date, @"Date", @(self.Jukebox), @"Jukebox", @(self.lastPlayed), @"LastPlayed", nil];
    if (self.Arrangement) {
        [theDict setObject:[self.Arrangement toDictionary] forKey:@"Arrangement"];
    }
    return theDict;
}

- (id)init {
    self = [super init];
    self.Arrangement = [Arrangement new];
    return self;
}

+ (id)fromDictionary:(NSDictionary *)aDict {
    LibraryItem *item = [LibraryItem new];
    item.Title = [aDict objectForKey:@"Title"];
    item.Type = [[aDict objectForKey:@"Type"] intValue];
    item.Favorite = [[aDict objectForKey:@"Favorite"] boolValue];
    item.Date = aDict[@"Date"];
    item.Jukebox = [aDict[@"Jukebox"] boolValue];
    item.lastPlayed = [aDict[@"LastPlayed"] intValue];
    if ([aDict objectForKey:@"Arrangement"]) {
        item.Arrangement = [Arrangement fromDictionary:[aDict objectForKey:@"Arrangement"]];
    }
    return item;
}

+ (id)withArrangement:(Arrangement *)arr {
    LibraryItem *item  = [LibraryItem new];
    item.Type = LibraryItemTypeArrangement;
    item.Arrangement = arr;
    item.Title = arr.Title;
    item.Date = [LibraryItem currentDateString];
    return item;
}

+ (id)itemWithFile:(NSString *)aFile {
    LibraryItem *item  = [LibraryItem new];
    item.Type = LibraryItemTypeFile;
    item.Title = [[[aFile lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    item.Arrangement = [Arrangement new];
    item.Arrangement.MidiFile = [aFile lastPathComponent];
    item.Date = [LibraryItem currentDateString];
    return item;
}

- (NSComparisonResult)compareLastTimePlayed:(LibraryItem *)other {
    if (self.lastPlayed > other.lastPlayed) {
        return NSOrderedAscending;
    } else if (self.lastPlayed == other.lastPlayed) {
        return [[self getDate] compare:[other getDate]];
    }
    return NSOrderedDescending;
}

- (NSComparisonResult)compareName:(LibraryItem *)other {
    return [_Title caseInsensitiveCompare:other.Title];
}

- (NSComparisonResult)compareNameReverse:(LibraryItem *)other {
    return [other.Title caseInsensitiveCompare:_Title];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[LibraryItem class]]) {
        return [[object Title] isEqualToString:self.Title] && [object Type] == self.Type;
    }
    return false;
}

@end
