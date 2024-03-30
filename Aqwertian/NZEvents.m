//
//  NZEvents.m
//  PodcastTestCreator
//
//  Created by Nathan Ziebart on 5/3/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "NZEvents.h"
#import "Flurry.h"

#define PREFIX @"NZEV_"
#define DATE_PREFIX @"D_"

@implementation NZEvents

BOOL _enableFlurry = YES;
BOOL _debugLogging = NO;
NSString *flurryAppID = FLURRY_ID_PRODUCTION;

+ (void)initialize {
#ifdef DEBUG
    _debugLogging = YES;
    flurryAppID = FLURRY_ID_DEV;
#else
    flurryAppID = FLURRY_ID_PRODUCTION;
#endif // DEBUG
    [Flurry setAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
}

+ (void)logCrash:(NSString *)title exception:(NSException *)e {
    if (_enableFlurry) {
        [Flurry logError:title message:[e callStackSymbols].description exception:e];
        [Flurry logEvent:title withParameters:@{@"StackTrace" : [e callStackSymbols].description, @"Exception" : [e description], @"Reason": e.reason}];
    }
    if (_debugLogging) {
        NSLog(@"#NZEV(crash) - %@ - %@", title, [e callStackSymbols].description);
    }
}

+ (void)logEventNoFlurry:(NSString *)event {
    [self logEvent:event flurry:NO args:nil];
}

+ (void)logEvent:(NSString *)event {
    [self logEvent:event flurry:YES args:nil];
}

+ (void)logEvent:(NSString *)event args:(NSDictionary *)args {
    [self logEvent:event flurry:YES args:args];
}

+ (void)logError:(NSString *)error message:(NSString *)message error:(NSError *)err {
    if (_enableFlurry) {
        [Flurry logError:error message:message error:err];
    }
}

+ (void)startSession {
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:flurryAppID];
}

+ (void)logEvent:(NSString *)event flurry:(BOOL)sendToFlurry args:(NSDictionary *)args {
    if (sendToFlurry && _enableFlurry) {
        if (args) {
            [Flurry logEvent:event withParameters:args];
        } else {
            [Flurry logEvent:event];
        }
    }
    
    if (_debugLogging) {
        NSLog(@"#NZEV - %@ - %@", event, args ? args.description : @"");
    }
    
    event = [PREFIX stringByAppendingString:event];
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:event];
    NSNumber *new = @([num intValue] + 1);
    [[NSUserDefaults standardUserDefaults] setObject:new forKey:event];
    event = [DATE_PREFIX stringByAppendingString:event];
    [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:event];
}

+ (int)countForEvent:(NSString *)event {
    event = [PREFIX stringByAppendingString:event];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:event] intValue];
}

+ (NSDate *)lastDateForEvent:(NSString *)event {
     event = [PREFIX stringByAppendingString:event];
    event = [DATE_PREFIX stringByAppendingString:event];
    return [[NSDate alloc] initWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults] objectForKey:event] intValue]];
}

+ (void)startTimedFlurryEvent:(NSString *)event {
    if (_enableFlurry)
        [Flurry logEvent:event timed:YES];
    if (_debugLogging) {
        NSLog(@"#NZEV(timed) - %@", event);
    }
}

+ (void)stopTimedFlurryEvent:(NSString *)event {
    if (_enableFlurry)
        [Flurry endTimedEvent:event withParameters:nil];
    if (_debugLogging) {
        NSLog(@"#NZEV(end timed) - %@", event);
    }
}

@end
