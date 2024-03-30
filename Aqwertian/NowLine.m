//
//  NowLine.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/11/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "NowLine.h"
#import "AnimationView.h"
#import "ACMagnifyingView.h"
#import <QuartzCore/QuartzCore.h>

//#import "NotationDisplay.h"

@implementation NowLine {
    UIImageView *theTopCog, *theBottomCog;
    UIImageView *theImage;
    NSInteger theImageFrame;
    double toX;
    BOOL shouldCallback;
    BOOL _animating;
    SEL _selector;
    id _target;
    float increment;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init {
    static int i = 0;
    self = [super init];
    [self setup];
//    if (i == 0) {
//    self.glass = [[ACMagnifyingGlass alloc] initWithFrame:CGRectMake(0, 0, 150, 300)];
//    }i = 1;
//    self.glass.touchPointOffset = CGPointMake(0,0);
//    self.glass.scale = 1.4;
    return self;
}

- (BOOL)animating {
    return _animating;
}

- (void) setup {
    self.backgroundColor = [UIColor clearColor];
    
//    theBottomCog = [AnimationView new];
//    theTopCog = [AnimationView new];
//
//    [theBottomCog setImage:[UIImage imageNamed:@"position-cog-bottom"] numberOfFrames:5];
//    [theTopCog setImage:[UIImage imageNamed:@"position-cog-top"] numberOfFrames:5];
    
    theTopCog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"position-cog.png"]];
    theBottomCog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"position-cog.png"]];
    
    
    [self addSubview:theBottomCog];
    [self addSubview:theTopCog];
    
    theTopCog.center = CGPointMake(13.5,12.5);
    theBottomCog.center = CGPointMake(13.5,326.5);
    
    theImage = [UIImageView new];
    theImage.image = [UIImage imageNamed:@"position.png"];
    [theImage setFrame:CGRectMake(0, 0, theImage.image.size.width, theImage.image.size.height)];
    [self addSubview:theImage];
    [self setFrame:theImage.frame];
}

- (void)setCenter:(CGPoint)center {
    if (center.x != self.center.x) {
        theTopCog.transform = CGAffineTransformMakeRotation(0.1 + -2 * M_PI * center.x / (32*M_PI));
        
        theBottomCog.transform = CGAffineTransformMakeRotation(0.12 + 2 * M_PI * center.x / (32*M_PI));
         [super setCenter:center];
    }
   
}

//- (void) setImageFrame {
//    [theTopCog setImageFrame:theImageFrame];
//    [theBottomCog setImageFrame:theImageFrame];
//}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
}

- (void)moveCenter:(CGPoint)center {
    [self setCenter:center];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
//    [_glass setFrame:CGRectMake(frame.origin.x, frame.origin.y, 150, frame.size.height)];
//    int x = frame.origin.x;
//    [theTopCog setImageFrame:(x/2)%5];
//    [theBottomCog setImageFrame:(x/2)%5];
  //  [_glass setNeedsDisplay];
}

- (void) animateCenter:(CGPoint)center callbackTarger:(id)target selector:(SEL)selector time:(NSTimeInterval)time {
    shouldCallback = YES;
    _target = target;
    _selector = selector;
    _animating = YES;
    toX = center.x;
    [UIView cancelPreviousPerformRequestsWithTarget:self];
    increment = ABS(center.x - self.center.x)/(time/0.003);
    if (toX < self.center.x) {
        [self decreaseCenterAnimated:[NSNumber numberWithDouble:self.center.x - increment]];
    } else {
        [self increaseCenterAnimated:[NSNumber numberWithDouble:self.center.x + increment]];
    }
}

- (void)animateCenter:(CGPoint)center time:(NSTimeInterval)time {
    shouldCallback = NO;
    _animating = YES;
    toX = center.x;
    increment = ABS(center.x - self.center.x)/(time/0.003);
    [UIView cancelPreviousPerformRequestsWithTarget:self];
    if (toX < self.center.x) {
        [self decreaseCenterAnimated:[NSNumber numberWithDouble:self.center.x - increment]];
    } else {
        [self increaseCenterAnimated:[NSNumber numberWithDouble:self.center.x + increment]];
    }
}

- (void) increaseCenterAnimated:(NSNumber *)anX {
    double x = [anX doubleValue];
    
    if (x < toX) {
        [self setCenter:CGPointMake(x, self.center.y)];
        x += increment;
        [self performSelector:@selector(increaseCenterAnimated:) withObject:[NSNumber numberWithDouble:x] afterDelay:0.003];
    } else {
        [self setCenter:CGPointMake(toX, self.center.y)];
        if (shouldCallback) {
            [_target performSelector:_selector withObject:nil afterDelay:0.1];
        }
        _animating = NO;
    }
}

- (void) decreaseCenterAnimated:(NSNumber *)anX {
    double x = [anX doubleValue];
    
    if (x > toX) {
        [self setCenter:CGPointMake(x, self.center.y)];
        x -= increment;
        [self performSelector:@selector(decreaseCenterAnimated:) withObject:[NSNumber numberWithDouble:x] afterDelay:0.003];
    } else {
        [self setCenter:CGPointMake(toX, self.center.y)];
        if (shouldCallback) {
            [_target performSelector:_selector withObject:nil afterDelay:0.1];
        }
        _animating = NO;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.glass removeFromSuperview];
    [newSuperview addSubview:self.glass];
    self.glass.viewToMagnify = newSuperview;
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
