//
//  StatsViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 1/6/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongOptions.h"

@interface StatsViewController : UIViewController

@property NSString *text;

+ (StatsViewController *)sharedController;

+ (Statistics *)getStats;

+ (BOOL) stats:(Statistics *)s isBetterThan:(Statistics *)other;

- (void) displayStats:(Statistics *)stats;

@end
