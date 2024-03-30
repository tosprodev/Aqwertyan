//
//  Arrangement.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/4/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongOptions.h"


@interface Arrangement : NSObject

@property NSString *Title;
@property NSString *MidiFile;
@property NSData *fileData;
@property NSArray *Channels;
@property BOOL Chorded, Exmatch, TwoRow;
@property (nonatomic) KeyboardType keyboardType;
@property NSInteger UserInstrument, UserChannel;
@property NSArray *Notes;
@property int Division;
@property (nonatomic) float tempo;
@property (nonatomic) NSMutableArray *statsHistory;
@property (nonatomic) NSDictionary *settings;

- (NSDictionary *)toDictionary;
- (BOOL) isInitialized;

+ (Arrangement *)fromDictionary:(NSDictionary *)aDict;

@end

#define CH_ACTIVE 1
#define CH_ACCOMP 0
#define CH_MUTE 2

@interface Channel : NSObject

@property NSInteger Number;
@property NSMutableArray *Instruments;
@property int Active, Track;

- (NSDictionary *)toDictionary;
+ (NSArray *)arrayForSerializationFromArray:(NSArray *)channels;
+ (NSArray *)arrayFromSerializedArray:(NSArray *)dicts;
+ (NSArray *)copyArray:(NSArray *)channels;
+ (Channel *)fromDictionary:(NSDictionary *)aDict;
- (NSComparisonResult) compare:(Channel *)anotherChannel;
- (Channel *)copy;

@end

@interface Statistics : NSObject

@property (nonatomic) int rightNotes;
@property (nonatomic) int skippedNotes;
@property (nonatomic) int wrongNotes;
@property (nonatomic) int notesPlayedOnTime;
@property (nonatomic) float tempoAccuracy;
@property (nonatomic) NSDate *date;

@property (nonatomic) int onTime, tooEarly, tooLate, missed, perfect, total, totalNotAutoplayed;

+ (Statistics *)fromString:(NSString *)s;
- (NSString *)toString;
- (BOOL) isBetterThan:(Statistics *)s;

- (float) onTimePercent;
- (float) missedPercent;
- (float) perfectPercent;
- (float) tooLatePercent;
- (float) tooEarlyPercent;

- (float) correctKeyHitsPercent;
- (float) notesPlayedPercent;
- (int) totalScore;
- (int) totalKeyHits;

@end