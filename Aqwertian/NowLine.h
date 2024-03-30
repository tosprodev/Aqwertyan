//
//  NowLine.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/11/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACMagnifyingGlass.h"

@interface NowLine : UIImageView

@property ACMagnifyingGlass *glass;

- (void) animateCenter:(CGPoint)center time:(NSTimeInterval) time;
- (void) animateCenter:(CGPoint)center callbackTarger:(id)target selector:(SEL)selector time:(NSTimeInterval) time;
- (BOOL) animating;
@end
