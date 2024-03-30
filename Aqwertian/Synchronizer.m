//
//  Synchronizer.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/19/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "Synchronizer.h"
//#import "NotationDisplay.h"

@implementation Synchronizer {
    NSTimer *theTimer;
    int theCount;
    BOOL paused;
}

+ (Synchronizer *)sharedSynchronizer {
    static Synchronizer *theSynchronizer = nil;
    
    if (theSynchronizer == nil) {
        theSynchronizer = [Synchronizer new];
    }
    
    return theSynchronizer;
}

- (id)init {
    self = [super init];
    self.beats = 0;
    return self;
}

- (int)tempo {
    return 50000;
}

- (void) timerTick:(id)sender {
    if (theCount%3 == 0) {
        self.beats++;
        [[InputHandler sharedHandler] processBeat:self.beats];
    }
    [[NotationDisplay sharedDisplay] updateYAH];
}

- (void)stop {
    paused = YES;
    [theTimer invalidate];
}

- (void)resume {
    paused = NO;
    [self stop];
    theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

- (void)restart {
    paused = NO;
    [self stop];
    theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
 
    self.beats = 0;
}

- (BOOL)paused {
    return paused;
}

@end
