//
//  PitchBendWheel.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/10/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PitchBendWheel : UIView <UIScrollViewDelegate>

+ (PitchBendWheel *) sharedWheel;

@property (nonatomic) float sensitivity;
@property (nonatomic) BOOL enabled;

- (void) doPitchBend:(float)offset;


@end
