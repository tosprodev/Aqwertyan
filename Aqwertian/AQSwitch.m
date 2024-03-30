//
//  AQSwitch.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/28/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "AQSwitch.h"

@implementation AQSwitch{
    BOOL setup;
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
    self.image = [UIImage imageNamed:@"op-switch.png"];
    self.contentMode = UIViewContentModeCenter;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)]];
     self.userInteractionEnabled=YES;
}

- (void)setOn:(BOOL)on {
    _on = on;
    [UIView transitionWithView:self duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        if (on) {
            self.image = [UIImage imageNamed:@"op-switch-pressed.png"];
        } else {
            self.image = [UIImage imageNamed:@"op-switch.png"];
        }
    }completion:nil];
  
}

- (void) tapped {
    self.on = !_on;
    if (_target && _selector) 
        [_target performSelector:_selector];
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
