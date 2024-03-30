//
//  HalfKeyboardView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/27/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "HalfKeyboardView.h"

@implementation HalfKeyboardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    CGPointApplyAffineTransform(point, self.transform);
//    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    rect.origin.x -= 60;
//    return CGRectContainsPoint(rect, point);
//  //  CGRectContainsPoint(self.f, <#CGPoint point#>)    return [super pointInside:point withEvent:event];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
