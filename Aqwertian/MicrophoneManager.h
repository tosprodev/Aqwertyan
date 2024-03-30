//
//  MicrophoneManager.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/9/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MicrophoneManager : NSObject

+ (BOOL) startPassthrough;
+ (void) stop;
+ (void) setVolume:(double)volume;
+ (float) volume;
+ (BOOL) isOn;

@end
