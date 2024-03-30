//
//  AQHTMLView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/9/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "AQHTMLView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AQHTMLView {
    UIView *topFadeView, *bottomFadeView;
    CAGradientLayer *topFadeLayer, *bottomFadeLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void) setup {
    id scrollview = [self.subviews objectAtIndex:0];
    for (UIView *subview in [scrollview subviews])
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.dataDetectorTypes = UIDataDetectorTypeLink;
    [self setFrame:self.frame];

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
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
