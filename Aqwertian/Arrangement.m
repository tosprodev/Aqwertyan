//
//  Arrangement.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/4/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "Arrangement.h"
#import "Util.h"
#import "Base64.h"
#import "MusicFile.h"

@implementation Arrangement

//@property NSString *Title;
//@property NSString *UserMusFile;
//@property NSString *BandMusFile;
//@property NSString *MidiFile;
//@property NSArray *ActiveChannels;
//@property BOOL Chorded, Exmatch, Columned;
//@property NSInteger UserInstrument;

//@property (nonatomic, assign) int channel;
//@property (nonatomic, assign) int time;
//@property (nonatomic, assign) int duration;
//@property (nonatomic, assign) int note;
//@property (nonatomic, assign) int volume;
//@property (nonatomic, assign) int rate;
//@property (nonatomic, assign) unichar qwerty;
//@property (nonatomic, copy) NSString *reason;
//
//@property (nonatomic, assign) int state;
//@property (nonatomic, assign) UIView *noteView;
//@property (nonatomic, retain) NSArray *tieNotes;

+ (NSString *)stringFromNote:(RGNote *)n {
    return [NSString stringWithFormat:@"%d %d %d %d %d %d %d", n.channel, n.time, n.duration, n.note, n.volume, n.rate, n.qwerty];
}

+ (RGNote *)noteFromString:(NSString *)s {
    RGNote *n = [RGNote new];
    NSScanner *scanner = [NSScanner scannerWithString:s];
    int result;
    [scanner scanInt:&result];
    n.channel = result;
    [scanner scanInt:&result];
    n.time = result;
    [scanner scanInt:&result];
    n.duration = result;
    [scanner scanInt:&result];
    n.note = result;
    [scanner scanInt:&result];
    n.volume = result;
    [scanner scanInt:&result];
    n.rate = result;
    [scanner scanInt:&result];
    n.qwerty = result;
    return n;
}

+ (Arrangement *)fromDictionary:(NSDictionary *)aDict {
    Arrangement *arr = [[Arrangement alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:aDict];
    [dict removeObjectForKey:@"Channels"];
    [dict removeObjectForKey:@"FileData"];
    [dict removeObjectForKey:@"Notes"];
    [arr setValuesForKeysWithDictionary:dict];
    arr.Channels = [Channel arrayFromSerializedArray:[aDict objectForKey:@"Channels"]];
    arr.fileData = [Base64 decode:aDict[@"FileData"]];
    NSMutableArray *notes = [NSMutableArray arrayWithArray:aDict[@"Notes"]];
    for (int i = 0; i < notes.count; i++) {
        notes[i] = [self noteFromString:notes[i]];
    }
    @try {
        NSMutableArray *stats = [NSMutableArray arrayWithArray:aDict[@"statsHistory"]];
        for (int i = 0; i < stats.count; i++) {
            stats[i] = [Statistics fromString:stats[i]];
        }
        arr.statsHistory = stats;
    } @catch (NSException *e) {
        NSLog(@"%@",e);
        arr.statsHistory = [NSMutableArray new];
    }
    arr.Notes = notes;
    if (!aDict[@"UserChannel"]) {
        arr.UserChannel = -1;
    }
    return arr;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //NSLog(@"undefined key: %@", key);
    if ([key isEqualToString:@"Columned"]) {
        if ([value boolValue]) {
            self.keyboardType = KeyboardTypeFullPiano;
        } else {
            self.keyboardType = KeyboardTypeFullQwerty;
        }
    }
}

- (id)init {
    self = [super init];
    self.Exmatch = YES;
    self.MidiFile = self.Title = @"";
    _statsHistory = [NSMutableArray new];
    return self;
}

- (BOOL)isInitialized {
    return self.Channels != nil && self.Channels.count > 0;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithValuesForKeys:@[@"Title",@"MidiFile",@"Chorded",@"Exmatch", @"keyboardType",@"TwoRow", @"UserInstrument", @"tempo", @"settings", @"UserChannel"]]];
    [theDict setObject:[Channel arrayForSerializationFromArray:self.Channels] forKey:@"Channels"];
    if (self.fileData) {
        theDict[@"FileData"] = [Base64 encode:self.fileData];
    }
    NSMutableArray *notes = [NSMutableArray new];
    for (RGNote *n in self.Notes) {
        [notes addObject:[Arrangement stringFromNote:n]];
    }
    theDict[@"Notes"] = notes;
    NSMutableArray *stats = [NSMutableArray new];
    for (Statistics *stat in _statsHistory) {
        [stats addObject:[stat toString]];
    }
    theDict[@"statsHistory"] = stats;
    if (!self.settings) {
        [theDict removeObjectForKey:@"settings"];
    }
    return theDict;
}




@end


@implementation Channel

- (id)init {
    self = [super init];
    self.Instruments = [NSMutableArray new];
    self.Active = CH_ACTIVE;
    return self;
}

+ (NSArray *)arrayForSerializationFromArray:(NSArray *)channels {
    NSMutableArray *list = [NSMutableArray new];
    for (Channel *channel in channels) {
        [list addObject:[channel toDictionary]];
    }
    return list;
}

+ (NSArray *)arrayFromSerializedArray:(NSArray *)dicts {
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *dict in dicts) {
        [list addObject:[Channel fromDictionary:dict]];
    }
    return list;
}

+ (NSArray *)copyArray:(NSArray *)channels {
    NSMutableArray *list = [NSMutableArray new];
    for (Channel *channel in channels) {
        [list addObject:[channel copy]];
    }
    return list;
}

+ (Channel *)fromDictionary:(NSDictionary *)aDict {
    Channel *channel = [Channel new];
    channel.Number = [[aDict objectForKey:@"Number"] intValue];
    channel.Instruments = [aDict objectForKey:@"Instruments"];
    channel.Active = [[aDict objectForKey:@"Active"] intValue];
    return channel;
}

- (NSComparisonResult)compare:(Channel *)anotherChannel {
    if (self.Number > anotherChannel.Number)
        return NSOrderedDescending;
    else if (self.Number < anotherChannel.Number)
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}

- (Channel *)copy {
    Channel *channel = [Channel new];
    channel.Number = self.Number;
    channel.Active = self.Active;
    NSMutableArray *instruments = [NSMutableArray new];
    for (NSNumber *number in self.Instruments) {
        [instruments addObject:[NSNumber numberWithInteger:[number integerValue]]];
    }
    channel.Instruments = instruments;
    return channel;
}

- (NSDictionary *)toDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:NI(self.Active),@"Active",   NI(self.Number), @"Number", self.Instruments, @"Instruments",  nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Channel %d, Active: %d", _Number, _Active];
}

@end

@implementation Statistics

- (NSString *)toString {
    return [NSString stringWithFormat:@"%d %d %d %d %d %d %d %d %d", _rightNotes, _wrongNotes, _total, _missed, _tooEarly, _tooLate, _onTime, _perfect, (int)[_date timeIntervalSince1970]];
}

+ (Statistics *)fromString:(NSString *)s {
    Statistics *stats = [Statistics new];
    NSArray *items = [s componentsSeparatedByString:@" "];
    stats.rightNotes = [items[0] intValue];
    stats.wrongNotes = [items[1] intValue];
    stats.total = [items[2] intValue];
    stats.missed = [items[3] intValue];
    stats.tooEarly = [items[4] intValue];
    stats.tooLate = [items[5] intValue];
    stats.onTime = [items[6] intValue];
    stats.perfect = [items[7] intValue];
    stats.date = [NSDate dateWithTimeIntervalSince1970:[items[8] intValue]];
    
    return stats;
}

- (BOOL)isBetterThan:(Statistics *)s {
    return [self totalScore] > s.totalScore;
}

- (float)missedPercent {
    if (_total == 0) return 0;
    return 100.0* (float)_missed / (float)_total;
}

- (float)tooEarlyPercent {
     if (_total == 0) return 0;
    return  100.0*(float)_tooEarly / (float)_total;
}

- (float)tooLatePercent {
     if (_total == 0) return 0;
    return 100.0*(float)_tooLate / (float)_total;
}

- (float)onTimePercent {
     if (_total == 0) return 0;
    return 100.0*(float)_onTime / (float) _total;
}

- (float)perfectPercent {
     if (_total == 0) return 0;
    return 100.0*(float)_perfect / (float) _total;
}

- (int)totalKeyHits {
    return _rightNotes + _wrongNotes;
}

- (float)correctKeyHitsPercent {
    if (_rightNotes == 0 || self.totalKeyHits == 0) return 0;
    return 100.0*(float)_rightNotes / (float)(self.totalKeyHits);
}

- (float)notesPlayedPercent {
     if (_total == 0) return 0;
    return 100.0*(float)(_tooEarly + _tooLate + _onTime) / (float) _total;
}

- (NSString *)description {
    return [self toString];
}

- (int)totalScore {
    return (int)(self.onTimePercent + self.perfectPercent + self.correctKeyHitsPercent + 0.5);
}

@end