//
//  PushButton.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/1/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "PushButton.h"

@implementation PushButton {
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
    if (setup) return; setup=YES;
    self.contentMode = UIViewContentModeCenter;
    _ignoreTouchesOnTransparentRegions = YES;
    _upImage = [self imageForState:UIControlStateNormal];
    _downImage = [self imageForState:UIControlStateHighlighted];
    [self setImage:_upImage forState:UIControlStateHighlighted|UIControlStateSelected];
    [self setImage:_downImage forState:UIControlStateSelected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setImage:_downImage forState:UIControlStateHighlighted|UIControlStateSelected];
    [self setImage:_downImage forState:UIControlStateHighlighted];
    [super setHighlighted:highlighted];
}

- (void)setUpImage:(UIImage *)upImage {
    _upImage = upImage;
    //[self setSelected:self.selected];
}

- (void)setSelected:(BOOL)selected {
    //[super setSelected:selected];
    if(!selected)
    {
        [self setImage:_upImage forState:UIControlStateHighlighted];
        [self setImage:_upImage forState:UIControlStateSelected];
        [self setImage:_upImage forState:UIControlStateHighlighted | UIControlStateSelected];
        [self setImage:_upImage forState:UIControlStateNormal];
    }
    else
    {
        [self setImage:_downImage forState:UIControlStateHighlighted];
        [self setImage:_downImage forState:UIControlStateSelected];
        [self setImage:_downImage forState:UIControlStateHighlighted | UIControlStateSelected];
        [self setImage:_downImage forState:UIControlStateNormal];
    }
    [UIView transitionWithView:self
                      duration:0.1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  [super setSelected:selected];}
                    completion:nil];
    
    
    if (self.selected) {
        //pathView.hidden=NO;
      //  [self setImage:_downImage forState:UIControlStateNormal];
    } else {
       // pathView.hidden = YES;
      //  [self setImage:_upImage forState:UIControlStateNormal];
    }

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
