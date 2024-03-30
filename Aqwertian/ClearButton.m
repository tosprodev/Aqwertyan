//
//  ClearButton.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/6/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "ClearButton.h"

@implementation ClearButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

+ (UIImage *)upImage {
    static UIImage *theImage = nil;
    if (!theImage) {
        theImage = [[UIImage imageNamed:@"button_bg_clear"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    return theImage;
}

+ (UIImage *)downImage {
    static UIImage *theImage = nil;
    if (!theImage) {
        theImage = [[UIImage imageNamed:@"button_bg_pressed_clear"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    return theImage;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void) setup {
    [self setBackgroundImage:[ClearButton upImage] forState:UIControlStateNormal];
    [self setBackgroundImage:[ClearButton downImage] forState:UIControlStateHighlighted];
    [self setTitleColor:[self titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
