//
//  Synchronizer.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/19/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"

@protocol SynchronizerDelegate <NSObject>

- (void) processBeat:(int)beat;

@end

@interface Synchronizer : NSObject

@property int beats;
@property (readonly) BOOL paused;

@property id<SynchronizerDelegate> Delegate;

+ (Synchronizer *)sharedSynchronizer;
- (int) tempo;
- (void) restart;
- (void) stop;
- (void) resume;
@end
