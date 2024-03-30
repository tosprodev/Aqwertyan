//
//  OverlayView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/15/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "OverlayView.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"


@implementation OverlayView {
    CAShapeLayer *maskLayer;
}

+ (void)initialize {
    OverlayViewPerfectBorderColor = [UIColor colorWithRed:1 green:215./255. blue:0 alpha:1];
    OverlayViewOkBorderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
    UIColor * c = [[UIColor yellowColor] colorWithAlphaComponent:.4];
    OverlayViewEarlyColor = c;
    OverlayViewLateColor = [[UIColor redColor] colorWithAlphaComponent:.4];
    OverlayViewOnTimeColor = [[UIColor greenColor] colorWithAlphaComponent:.4];
    OverlayViewMissedColor = [[UIColor darkGrayColor] colorWithAlphaComponent:.4];
    
    OverlayViewEarlyColorBold = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
    OverlayViewLateColorBold = [[UIColor redColor] colorWithAlphaComponent:.5];
    OverlayViewOnTimeColorBold = [[UIColor greenColor] colorWithAlphaComponent:.5];
    OverlayViewMissedColorBold = [[UIColor darkGrayColor] colorWithAlphaComponent:.5];
    
    OverlayViewPerfectImage = [[UIImage imageNamed:@"overlay-perfect"] resizableImageWithCapInsets:UIEdgeInsetsMake(24, 7, 24, 7)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.moving = YES;
        self.position = OverlayViewPositionLeft;
    }
    return self;
}

- (void)setPosition:(OverlayViewPosition)position {
    _position = position;
    CGRect originalBounds =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect originalFrame = self.frame;
    CGRect maskRect = originalBounds;
// self.bounds;
    CGRect newBounds = originalBounds;// self.bounds;// CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect newFrame = originalFrame;
    if (!_moving) {
        if (position == OverlayViewPositionCenter) {
            maskRect.origin.x += 4;
            newFrame.origin.x -= 4;
            newFrame.size.width += 8;
           // newBounds.origin.x -= 4;
          //  newBounds.size.width += 8;
        } else if (position == OverlayViewPositionLeft) {
            newFrame.size.width += 4;
            maskRect.origin.x -= 20;
            maskRect.size.width += 20;
        } else if (position == OverlayViewPositionRight) {
            newBounds.origin.x -= 4;
           // newBounds.size.width += 4;
            newFrame.origin.x -= 4;
            newFrame.size.width += 4;
            maskRect.origin.x += 4;
            maskRect.size.width += 20;
        } else {
            
        }
    }
    
    maskRect.origin.y -= 10;
    maskRect.size.height += 20;

    
    if (position == OverlayViewPositionNone) {
        self.layer.cornerRadius = _moving ? 0 : 4;
        self.layer.mask = nil;
    } else if (_moving) {
        self.layer.cornerRadius = 0;
        self.layer.mask = nil;
    } else {

        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:maskRect];
        if (maskLayer == nil) maskLayer = [CAShapeLayer layer];
        maskLayer.frame = originalBounds;
        maskLayer.path = maskPath.CGPath;
        
      //  self.bounds = newBounds;
        self.frame = newFrame;
        self.layer.cornerRadius = _moving ? 0 : 4;
        self.layer.mask = maskLayer;
        
    }
}

- (void)setMoving:(BOOL)moving {
    _moving = moving;
    if (moving) {
        self.layer.mask = nil;
    } else {
       // self.position = self.position;
     //   self.layer.mask = (self.position == OverlayViewPositionNone) ? nil : maskLayer;
    }
}

- (void) wasHeldForRightLength {
//    if (self.position == OverlayViewPositionCenter) {
//        self.selectiveBordersWidth = 2;
//        self.selectiveBorderFlag = AUISelectiveBordersFlagTop | AUISelectiveBordersFlagBottom;
//        self.selectiveBordersColor = OverlayViewBorderColor;
//    } else if (self.position == OverlayViewPositionLeft) {
//        self.selectiveBordersWidth = 2;
//        self.selectiveBorderFlag = AUISelectiveBordersFlagTop | AUISelectiveBordersFlagBottom | AUISelectiveBordersFlagLeft;
//        self.selectiveBordersColor = OverlayViewBorderColor;
//    } else if (self.position == OverlayViewPositionRight) {
//        self.selectiveBordersWidth = 2;
//        self.selectiveBorderFlag = AUISelectiveBordersFlagTop | AUISelectiveBordersFlagBottom | AUISelectiveBordersFlagRight;
//        self.selectiveBordersColor = OverlayViewBorderColor;
//    } else {
      //  self.layer.borderWidth = 1;
      // self.layer.borderColor = OverlayViewPerfectBorderColor.CGColor;
    
//    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius];
//    
//    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 4, 4) cornerRadius:4]];
    //path.usesEvenOddFillRule = YES;
    

  //  self.layer.shadowPath = path.CGPath;
 //   }
}

- (void) wasPerfect {
//    [self wasHeldForRightLength];
//    self.layer.borderWidth = 2;
    

    UIImageView *imageView = [[UIImageView alloc] initWithImage:OverlayViewPerfectImage];
    imageView.frame = CGRectMake(0,0,self.frame.size.width + 4, self.frame.size.height + 8);
    imageView.center = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)+2};
    [self addSubview:imageView];
    
    float scale = self.frame.size.height > 50 ? 1.1 : 1.2;
    
    if (scaleBack) {
        self.backgroundColor = [UIColor clearColor];
    } else {
//        self.backgroundColor = [UIColor greenColor];
//        double delayInSeconds = 0.1;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            self.backgroundColor = [UIColor clearColor];
//        });
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [imageView.layer setValue:[NSNumber numberWithFloat:scale] forKeyPath:@"transform.scale.y"];
            // self.backgroundColor = [UIColor yellowColor];
        } completion:^(BOOL finished) {
            self.backgroundColor = [UIColor clearColor];
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [imageView.layer setValue:[NSNumber numberWithFloat:1] forKeyPath:@"transform.scale.y"];
                //  self.backgroundColor = [UIColor clearColor];
            } completion:nil];
        }];
    }

 //   [self flash];
//    self.layer.shadowOpacity = .5;
//    self.layer.shadowRadius = 2;
//    self.layer.shadowOffset = (CGSize){0,0};
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4].CGPath;
}

- (void) flash {
//        UIColor *oldColor = self.backgroundColor;
//    [UIView animateWithDuration:0.1 animations:^(void) {
//        self.backgroundColor = [UIColor greenColor];
//        self.alpha = 1;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.2 animations:^(void) {
//            self.backgroundColor = oldColor;
//            self.alpha = 0.3;
//        } completion:^(BOOL finished) {
//            if (completion) {
//                completion();
//            }
//        }];
//    }];
//
    
//    if (self.position == OverlayViewPositionNone) {
//        self.layer.borderColor = [UIColor yellowColor].CGColor;
//        double delayInSeconds = 0.15;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            self.layer.borderColor = OverlayViewOkBorderColor.CGColor;
//        });
//    } else {
//        self.selectiveBordersColor = [UIColor yellowColor];
//        double delayInSeconds = 0.15;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            self.selectiveBordersColor = OverlayViewBorderColor;
//        });
//    }
//    
//    self.layer.shadowColor = [UIColor yellowColor].CGColor;
//    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
//    theAnimation.autoreverses = YES;
//    theAnimation.duration = 0.15;
//    theAnimation.toValue = [NSNumber numberWithDouble:1.0];
//    [self.layer addAnimation:theAnimation forKey:@"shadowOpacity"];
//    theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
//    theAnimation.autoreverses = YES;
//    theAnimation.duration = 0.15;
//    theAnimation.toValue = [NSNumber numberWithDouble:10.0];
//    [self.layer addAnimation:theAnimation forKey:@"shadowRadius"];

    self.backgroundColor = [UIColor yellowColor];
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.backgroundColor = [UIColor clearColor];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.backgroundColor = [UIColor yellowColor];
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.backgroundColor = [UIColor clearColor];
            });
        });
    });

}

//- (void)layoutSubviews {
//    maskLayer.frame = self.layer.bounds;
//}

//- (id)init {
//    self = [super init];
//    return self;
//}
//
//- (void)setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    if (maskLayer) {
//        maskLayer.frame = self.bounds;
//        self.layer.mask = maskLayer;
//    }
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
