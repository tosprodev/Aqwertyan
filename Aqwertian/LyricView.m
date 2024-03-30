//
//  LyricView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/12/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "LyricView.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"


@implementation LyricView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

+ (void)initialize {

}


/*
 Font: Futura
 Font Weight: Medium
 Font Size: 18
 
 Text Color: RGB (93,53,34)
 Text Opacity: 100%
 
 Shadow Offset: 0,1
 Shadow Radius: 0
 Shadow Color: RGB (255,255,255)
 Shadow Opacity: 75%
 */
- (void) setup {
    self.backgroundColor = [UIColor clearColor];
    //self.textAlignment = UITextAlignmentCenter;
    self.adjustsFontSizeToFitWidth = YES;
    self.layer.anchorPoint = CGPointMake(.5,.5);
    self.font = [UIFont fontWithName:@"Futura-Medium" size:18];
    self.textColor = [UIColor colorWithRed:93.0/255.0 green:53.0/255.0 blue:34.0/255.0 alpha:1];
    self.shadowOffset= CGSizeMake(0,1);
    self.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
}

- (void)setLyric:(NSString *)lyric {
    self.text = lyric;
}

- (void)setState:(NSInteger)state animated:(BOOL)animated {
    if (state == PLAYED) {
        self.textColor = [UIColor grayColor];
    } else if (state == PLAYING) {
        self.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
        if (!ios5 && !scaleBack && animated) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [self.layer setValue:[NSNumber numberWithFloat:1.3] forKeyPath:@"transform.scale"];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [self.layer setValue:[NSNumber numberWithFloat:1] forKeyPath:@"transform.scale"];
                } completion:nil];
            }];
        }
    } else {
        self.textColor = [UIColor colorWithRed:93.0/255.0 green:53.0/255.0 blue:34.0/255.0 alpha:1];
    }
}

- (void)setState:(NSInteger)state {
    [self setState:state animated:YES];
}



- (void)layoutSubviews {
    [super layoutSubviews];

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
