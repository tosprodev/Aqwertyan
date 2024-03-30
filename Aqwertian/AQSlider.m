//
//  AQSlider.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/28/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "AQSlider.h"

@implementation AQSlider

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
    UIImage *thumb = [UIImage imageNamed:@"st-slider-handle-centered.png"];
    [self setThumbImage:thumb forState:UIControlStateNormal];
    [self setMinimumTrackImage:[UIImage imageNamed:@"st-slider-fill-horizontal.png"] forState:UIControlStateNormal];
    [self setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
  //  [super setCenter:(CGPoint){CGRectGetMidX(frame), CGRectGetMidY(frame)}];
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
