//
//  AnimationView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/11/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationView : UIView

- (void) setImage:(UIImage *)anImage numberOfFrames:(NSInteger)frames;
- (void) setImageFrame:(NSInteger)frame;

@end
