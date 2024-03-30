//
//  NZEvents.h
//  PodcastTestCreator
//
//  Created by Nathan Ziebart on 5/3/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FLURRY_ID_DEV @"TTP4GSGQTYPBKYXSWSTB"
#define FLURRY_ID_PRODUCTION @"NBHTW8V3KNX4MR9GFBR9"

@interface NZEvents : NSObject

+ (void) logEventNoFlurry:(NSString *)event;
+ (void) logEvent:(NSString *)event;
+ (void) logEvent:(NSString *)event args:(NSDictionary *)args;
+ (void) logError:(NSString *)error message:(NSString *)message error:(NSError *)err;
+ (void) startSession;
+ (void) logCrash:(NSString *)title exception:(NSException *)e;

+ (int) countForEvent:(NSString *)event;
+ (NSDate *) lastDateForEvent:(NSString *)event;
+ (void) startTimedFlurryEvent:(NSString *)event;
+ (void) stopTimedFlurryEvent:(NSString *)event;

@end
