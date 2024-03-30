//
//  NoteView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "NoteView.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "NZNotationDisplay.h"


@implementation NoteView {
    UILabel *theLabel;
    NSInteger theHand;
    BOOL column;
    int _state;
    int _modifier;
    NSMutableArray *attachedViews;
    UIView *aLeft, *aRight;
    BOOL attachedViewsHidden;
    float _oldWidth;
    BOOL collapsed;
    UIView *cover;
    CGRect realFrame, cFrame;
    UIImageView *cView;
    UIView *tint;
}

+ (void)initialize {

}

- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.width == 0 && frame.size.height == 0) {
    frame.size = CGSizeMake(1, 1);
}
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init {
    self = [super init];
    [self setup];
    return self;
}

- (void) showAttachedViews {
    if (collapsed == NO) return;
    collapsed = NO;
    if (!attachedViews.count) return;
    
    for (NoteView *v in attachedViews) {
        [v setHidden:NO];
    }
    if (attachedViews.count) {
        self.attachRight = YES;
    }
    
    CGRect frame = self.frame;
    for (NoteView *v in attachedViews) {
        frame.size.width -= v.frame.size.width;
    }
    [self setFrame:frame];
}

- (void) collapseAttachedViews {
    if (collapsed == YES) return;
        collapsed = YES;
    if (!attachedViews.count) return;
//    for (NoteView *v in attachedViews) {
//      
//    }

    _oldWidth = self.frame.size.width;
    
    CGRect frame = self.frame;
    for (NoteView *v in attachedViews) {
        frame.size.width += v.frame.size.width;
          [v setHidden:YES];
    }
    [self setFrame:frame];
    
    if (attachedViews.count) {
        self.attachRight = NO;
    }
 //   [self setupImage];
}

+ (UIImage *) rightBasic {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        theImage = [[UIImage imageNamed:@"note-basic-right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 4)];
    }
    
    return theImage;
}

+ (UIImage *) basic {
    UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)];
    }
    
    return theImage;
}

+ (UIImage *) leftBasic {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-basic-left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 1)];
    }
    
    return theImage;
}

+ (UIImage *) rightNext {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-next-right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 4)];
    }
    
    return theImage;
}

+ (UIImage *) next {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-next.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)];
    }
    
    return theImage;
}

+ (UIImage *) nextMiddle {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-next-middle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 1)];
    }
    
    return theImage;
}


+ (UIImage *) basicMiddle {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-basic-middle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 1)];
    }
    
    return theImage;
}


+ (UIImage *) currentMiddle {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-current-middle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 1, 18, 1)];
    }
    
    return theImage;
}

+ (UIImage *) leftNext {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-next-left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 1)];
    }
    
    return theImage;
}

+ (UIImage *) rightCurrent {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-current-right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 1,18, 7)];
    }
    
    return theImage;
}

+ (UIImage *) current {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-current.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 7, 18, 7)];
    }
    
    return theImage;
}

+ (UIImage *) leftCurrent {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-current-left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 7, 18, 1)];
    }
    
    return theImage;
}

+ (UIImage *)rightHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-right-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 4)];
    }
    
    return theImage;
}

+ (UIImage *)leftHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-right-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 4)];
    }
    
    return theImage;
}

+ (UIImage *)smallLeftHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-right-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 8)];
    }
    
    return theImage;
}

+ (UIImage *)smallRightHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-right-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 8)];
    }
    
    return theImage;
}

+ (UIImage *)leftAttachLeftHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-right-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 8)];
    }
    
    return theImage;
}

+ (UIImage *)leftAttachRightHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-right-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 8)];
    }
    
    return theImage;
}

+ (UIImage *)rightAttachLeftHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        theImage = [[UIImage imageNamed:@"note-brown-side-left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 3, 14, 0)];
    }
    
    return theImage;
}

+ (UIImage *)rightAttachRightHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        
        theImage = [[UIImage imageNamed:@"note-right-basic.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 1, 14, 8)];
    }
    
    return theImage;
}

+ (UIImage *)bothAttachRightHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        theImage = [[UIImage imageNamed:@"note-red-middle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 14, 0)];
    }
    
    return theImage;
}

+ (UIImage *)bothAttachLeftHandImage {
    static UIImage *theImage = nil;
    
    if (theImage == nil) {
        theImage = [[UIImage imageNamed:@"note-brown-middle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 14, 0)];
    }
    
    return theImage;
}

- (void) setup {
    //self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOffset = CGSizeMake(0,2);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    _state = NORMAL;
    self.clipsToBounds = NO;
    _oldWidth = 0;
    collapsed = NO;
//    cover = [UIView new];
//    cover.alpha = 0;
//    cover.layer.cornerRadius = 3;
//    [self addSubview:cover];
    cView = [UIImageView new];
    [self addSubview:cView];
    cView.hidden=YES;
}

- (void)setHand:(NSInteger)Hand {
    column = NO;
    theHand = Hand;
    self.layer.cornerRadius = 0;
//    if (theHand == LEFT_HAND) {
//        self.image = self.frame.size.height > 10 ? [NoteView leftHandImage] : [NoteView smallLeftHandImage];
//    } else {
//        self.image = self.frame.size.height > 10 ? [NoteView rightHandImage] : [NoteView smallRightHandImage];
//    }
//    if (theHand == 1) {
//        theLabel.textColor = [UIColor yellowColor];
//    } else {
//        theLabel.textColor = [UIColor whiteColor];
//    }
    [self setupImage];
    for (NoteView *view in attachedViews) {
        [view setHand:Hand];
    }
}

- (void)setIsFirstHalf:(BOOL)isFirstHalf {
    _isFirstHalf = isFirstHalf;
    [self setupImage];
}

- (NSInteger)Hand {
    return  theHand;

}
//
//- (void)setColor:(UIColor *)Color {
//    self.backgroundColor = Color;
//}
//
//- Color {
//    return self.backgroundColor;
//}

- (void)setNote:(NSString *)Note {
    if (!theLabel) {
        theLabel = [UILabel new];
        theLabel.textColor = [UIColor whiteColor];
      
        theLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:25];
        
        theLabel.backgroundColor = [UIColor clearColor];
        theLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        theLabel.shadowOffset = CGSizeMake(0,1);
        [self addSubview:theLabel];
        theLabel.adjustsFontSizeToFitWidth = NO;
        [theLabel setFrame:CGRectMake(2, 0, self.frame.size.width-2, self.frame.size.height)];
    }
    theLabel.text = Note;
//    for (NoteView *view in attachedViews) {
//        [view setNote:Note];
//    }
}

- (void)addAttachedView:(NoteView *)view {

    if (attachedViews == nil) {
        attachedViews = [NSMutableArray new];
    }
    self.attachRight = YES;
    [view setHand:self.Hand];
    [attachedViews addObject:view];
    
    BOOL evenAttachRight = _isFirstHalf;
    for (int i = 0; i < attachedViews.count; i++) {
        NoteView *nv = attachedViews[i];
        if (i < attachedViews.count - 1) {
            if (i%2 == 0) {
                if (evenAttachRight) {
                    [nv setAttachRight:YES];
                    [nv setAttachLeft:YES];
                } else {
                    [nv setAttachLeft:YES];
                    [nv setAttachRight:YES];
                }
            } else {
                if (evenAttachRight) {
                    [nv setAttachRight:YES];
                    [nv setAttachLeft:YES];
                } else {
                    [nv setAttachLeft:YES];
                    [nv setAttachRight:YES];
                }
            }
           
        } else {
            if (i%2 == 0) {
                if (evenAttachRight) {
                    [nv setAttachLeft:YES];
                } else {
                    [nv setAttachLeft:YES];
                }
            } else {
                if (evenAttachRight) {
                    [nv setAttachLeft:YES];
                } else {
[nv setAttachLeft:YES];
                }
            }
        }
    if (_isFirstHalf) {
        [nv setIsFirstHalf:(i%2 != 0)];
    } else {
        [nv setIsFirstHalf:(i%2 == 0)];
    }
        if (nv.isFirstHalf) {
           // [nv setNote:self.Note];
        }
    }
    [self setFrame:self.frame];
}

- (void)setAttachLeft:(BOOL)attachLeft {
    _attachLeft=attachLeft;
    [self setupImage];
    [self setupContinueView];
}

- (void)setAttachRight:(BOOL)attachRight {
    _attachRight=attachRight;
    [self setupImage];
    [self setupContinueView];
}
- (void) setupImage {
   
    if (_attachRight && _attachLeft) {
        if (_state == NORMAL) {
            self.image = [NoteView basicMiddle];
        } else if (_state == HIGHLIGHTED) {
            self.image = [NoteView nextMiddle];
        } else if (_state == SHADOW) {
            
        } else if (_state == PLAYING) {
            cView.image = [NoteView currentMiddle];
            cView.frame = CGRectMake(0,-2,self.frame.size.width, self.frame.size.height > 40 ? self.frame.size.height + 7 : 36);
        } else if (_state == PLAYED) {
            self.image = [NoteView basicMiddle];
        }
    } else if (_attachLeft) {
        if (_state == NORMAL) {
            self.image = [NoteView rightBasic];
        } else if (_state == HIGHLIGHTED) {
            self.image = [NoteView rightNext];
        } else if (_state == SHADOW) {
            
        } else if (_state == PLAYING) {
             cView.image = [NoteView rightCurrent];
            cView.frame = CGRectMake(0,-2,self.frame.size.width+2, self.frame.size.height > 40 ? self.frame.size.height + 7 : 36);
        } else if (_state == PLAYED) {
             self.image = [NoteView rightBasic];
        }
    } else if (_attachRight) {
        if (_state == NORMAL) {
             self.image = [NoteView leftBasic];
        } else if (_state == HIGHLIGHTED) {
             self.image = [NoteView leftNext];
        } else if (_state == SHADOW) {
            
        } else if (_state == PLAYING) {
             cView.image = [NoteView leftCurrent];
            cView.frame = CGRectMake(-2,-2,self.frame.size.width+2, self.frame.size.height > 40 ? self.frame.size.height + 7 : 36);
        } else if (_state == PLAYED) {
            self.image = [NoteView leftBasic];
        }
    } else {
        if (_state == NORMAL) {
             self.image = [NoteView basic];
        } else if (_state == HIGHLIGHTED) {
             self.image = [NoteView next];
        } else if (_state == SHADOW) {
            
        } else if (_state == PLAYING) {
             cView.image = [NoteView current];
            cView.frame = CGRectMake(-2,-2,self.frame.size.width+4, self.frame.size.height > 40 ? self.frame.size.height + 7 : 36);
        } else if (_state == PLAYED) {
             self.image = [NoteView basic];
        }
    }

    if (_state == PLAYED) {
        self.alpha = 0.33;
    } else {
        self.alpha = 1;
    }
    if (_state == PLAYING) {
        cView.hidden=NO;
    } else {
        cView.hidden=YES;
    }
    if (_modifier == PLAYED_TOO_EARLY || _modifier == PLAYED_TOO_LATE) {
        [self createTintView];
        tint.hidden = NO;
        tint.alpha = 0.5;
        if (_modifier == PLAYED_TOO_EARLY) {
            tint.backgroundColor = [UIColor orangeColor];
        } else if (_modifier == PLAYED_TOO_LATE) {
            tint.backgroundColor = [UIColor blueColor];
        }
        
    } else {
        tint.hidden = YES;
    }
}

- (void) createTintView {
    if (tint) return;
    tint = [UIView new];
        tint.frame = self.bounds;
    
    UIRectCorner corners;
    if (_attachLeft && _attachRight) {
        corners = 0;
    } else if (_attachRight) {
        corners = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    } else if (_attachLeft) {
        corners = UIRectCornerTopRight| UIRectCornerBottomRight;
    } else {
        corners = UIRectCornerAllCorners;
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:tint.bounds byRoundingCorners:corners                                                       cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = tint.bounds;
    maskLayer.path = maskPath.CGPath;
    tint.layer.mask = maskLayer;
    
    tint.hidden = YES;
    [self addSubview:tint];
    [self bringSubviewToFront:theLabel];
    
    
}

- (void) setColumn:(char)aColumn {
    column = YES;
    attachedViews = NO;
    self.image = nil;
    self.layer.cornerRadius = 4;
    switch (aColumn - '0') {
        case 0:
            self.backgroundColor = [UIColor blueColor];
            break;
        case 1:
            self.backgroundColor = [UIColor yellowColor];
            break;
        case 2:
            self.backgroundColor = [UIColor orangeColor];
            break;
        case 3:
            self.backgroundColor = [UIColor redColor];
            break;
        case 4:
            self.backgroundColor = [UIColor purpleColor];
            break;
        case 5:
            self.backgroundColor = [UIColor greenColor];
            break;
        case 6:
            self.backgroundColor = [UIColor brownColor];
            break;
        case 7:
            self.backgroundColor = [UIColor cyanColor];
            break;
        case 8:
            self.backgroundColor = [UIColor yellowColor];
            break;
        case 9:
            self.backgroundColor = [UIColor redColor];
            break;
    }
    for (NoteView *view in attachedViews) {
        [view setColumn:aColumn];
    }
}

- (NSString *)Note {
    return theLabel.text;
}

-(void)setState:(NSInteger)state duration:(NSTimeInterval)dur {
    [self setState:state modifier:0 duration:dur];
}

- (void)setState:(NSInteger)state modifier:(NSInteger)modifier duration:(NSTimeInterval)dur {
//    return;
//    if (state == NORMAL) {
//        static CABasicAnimation *anim = nil;
//        
//        if (!anim || anim.duration != dur) {
//            anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
//            anim.fromValue = [NSNumber numberWithFloat:1.0];
//            anim.toValue = [NSNumber numberWithFloat:0.0];
//            anim.duration = dur;
//            anim.autoreverses = NO;
//        }
//        self.layer.shadowOpacity = 0;
//        if (dur > 0) {
//            [self.layer addAnimation:anim forKey:@"shadowOpacity"];
//        }
//        if (_state == HIGHLIGHTED && dur > 0) {
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//            [UIView setAnimationDuration:dur];
//        }
//        theLabel.textColor = [UIColor whiteColor];
//        self.layer.shadowOpacity = 0;
//        self.transform = CGAffineTransformMakeScale(1, 1);
//        cover.alpha = 0;
//        if (_state == HIGHLIGHTED && dur > 0) {
//            [UIView commitAnimations];
//        }
//    } else if (state == HIGHLIGHTED) {
//        static CABasicAnimation *anim = nil;
//        
//        if (!anim || anim.duration != dur) {
//            anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
//            anim.fromValue = [NSNumber numberWithFloat:0.0];
//            anim.toValue = [NSNumber numberWithFloat:1.0];
//            anim.duration = dur;
//            anim.autoreverses = NO;
//        }
//        self.layer.shadowOpacity = 1;
//        if (dur > 0) {
//            [self.layer addAnimation:anim forKey:@"shadowOpacity"];
//        }
//        self.layer.shadowOpacity = 0.0;
//        self.layer.shadowOpacity = 1;
//        self.layer.shadowRadius = 3;
//        self.layer.shadowColor = [UIColor blueColor].CGColor;
//        self.layer.shadowOffset = CGSizeMake(0,1);
//        cover.backgroundColor = [UIColor blueColor];
//        
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        [UIView setAnimationDuration:dur];
//        
//        //theLabel.textColor = [UIColor yellowColor];
//        cover.alpha = 0.5;
//       // self.transform = CGAffineTransformMakeScale(1.0, 1.05);
//        [UIView commitAnimations];
//    } else if (state == PLAYED) {
//        theLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
//        theLabel.shadowOffset = CGSizeZero;
//        theLabel.shadowColor = [UIColor clearColor];
//        self.layer.shadowOpacity = 0;
//        cover.alpha = 0;
//      //  self.transform = CGAffineTransformMakeScale(1, 1);
//    } else if (state == SHADOW) {
//        self.layer.shadowRadius = 1;
//        self.layer.shadowOffset = CGSizeMake(0,1);
//        self.layer.shadowOpacity = 1;
//    } else if (state == PLAYING) {
//        self.transform = CGAffineTransformMakeScale(1, 1);
//        theLabel.textColor = [UIColor yellowColor];
//        cover.alpha = 0.5;
//        self.layer.shadowOpacity = 0;
//        self.layer.shadowOpacity = 1;
//        self.layer.shadowRadius = 4;
//        self.layer.shadowOffset = CGSizeMake(0,0);
//        self.layer.shadowColor = [UIColor yellowColor].CGColor;
//        cover.backgroundColor = [UIColor redColor];
//        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//            [self.layer setValue:[NSNumber numberWithFloat:1.2] forKeyPath:@"transform.scale.y"];
//            
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//                [self.layer setValue:[NSNumber numberWithFloat:1] forKeyPath:@"transform.scale.y"];
//            } completion:nil];
//        }];
//    }
    
    

    _state = state;
    _modifier = modifier;


//        if (_state == PLAYING) {
//            if (self.frame.size.height != 36) {
//                CGRect frame = self.frame;
//                frame.origin.y -= 2;
//                frame.size.height = 36;
//                frame.size.width += 2;
//                frame.origin.x -= 1;
//                self.frame = frame;
//            }
//        } else {
//            if (self.frame.size.height != 29) {
//                
//                CGRect frame = self.frame;
//                frame.origin.y += 2;
//                frame.size.width -= 2;
//                frame.origin.x += 1;
//                frame.size.height = 29;
//                self.frame = frame;
//            }
//        }
//
    
    
    

    if (state == PLAYING) {
        if (!ios5 && !scaleBack && dur > 0.01) {
            [self setupImage];
            float scale = self.frame.size.height > 50 ? 1.1 : 1.2;
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [self.layer setValue:[NSNumber numberWithFloat:scale] forKeyPath:@"transform.scale.y"];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [self.layer setValue:[NSNumber numberWithFloat:1] forKeyPath:@"transform.scale.y"];
                } completion:nil];
            }];
        } else {
              [self setupImage];
        }
        
    } else {
        if (!ios5 && !scaleBack && dur > 0.01) {
            [UIView transitionWithView:self
                              duration:dur
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self setupImage];
                            } completion:nil];
        } else {
            [self setupImage];
        }
    }
    
    if (!collapsed) {
        for (NoteView *view in attachedViews) {
            [view setState:state modifier:modifier duration:dur];
        }
    }
  //  [self setNeedsDisplay];
    
}

- (int)state {
    return _state;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
  //  [cover setFrame:self.bounds];
//    if (_state == PLAYING) {
//        if (self.frame.size.height != 36) {
//            CGRect frame = self.frame;
//            frame.origin.y -= 2;
//            frame.size.height = 36;
//            frame.size.width += 2;
//            frame.origin.x -= 1;
//            self.frame = frame;
//        }
//    } else {
//        if (self.frame.size.height != 29) {
//            
//            CGRect frame = self.frame;
//            frame.origin.y += 2;
//            frame.size.width -= 2;
//            frame.origin.x += 1;
//            frame.size.height = 29;
//            self.frame = frame;
//        }
//    }

//    if (self.attachLeft) {
//        if (aLeft == nil) {
//            aLeft = [UIView new];
//            aLeft.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
//            [self addSubview:aLeft];
//            //aLeft.layer.cornerRadius = 4;
//           
//        }
//         [aLeft setFrame:CGRectMake(0, 0, 6, self.frame.size.height / 3)];
//        aLeft.center = CGPointMake(3, self.frame.size.height/2);
//        self.clipsToBounds = NO;
//        aLeft.alpha = 1;
//    } else {
//        aLeft.alpha = 0;
//    }

//}

- (void) setupContinueView {
    if (!_isFirstHalf && _attachRight) {
        if (aRight == nil) {
            aRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note-continue.png"]];
            //aRight.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
            [aRight sizeToFit];
            [self addSubview:aRight];
            //  aRight.layer.cornerRadius = 4;
            
        }
        //[aRight setFrame:CGRectMake(self.frame.size.width - 5, 0, 6, self.frame.size.height / 3)];
        aRight.center = CGPointMake(self.frame.size.width+1, self.frame.size.height/2+1);
        
        aRight.alpha = 1;
    } else {
        aRight.alpha = 0;
    }
    if (_isFirstHalf && _attachLeft) {
        if (aLeft == nil) {
            aLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note-continue.png"]];
            //aRight.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
            [aLeft sizeToFit];
            [self addSubview:aLeft];
            //  aRight.layer.cornerRadius = 4;
            aLeft.center = CGPointMake(-3, self.frame.size.height/2+1);
        }
    } else {
        aLeft.alpha = 0;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    char c = [self.Note characterAtIndex:0];
    BOOL needsEnlargement = (c == ';' || c == ',' || c == '.');
    
    
    if (frame.size.height > 40) {
        theLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:75];
    } else {
        if (needsEnlargement) {
             theLabel.font = [UIFont fontWithName:@"Futura-Medium" size:30];
        } else {
            theLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:25];
        }
    }
    CGRect f = self.frame;
    if (attachedViews.count && _isFirstHalf) {
        f.size.width += [attachedViews[0] frame].size.width;
    }
    float min = f.size.height > 50 ? 34 : 15;
    [theLabel setFrame:CGRectMake(2, 0, min, f.size.height)];
    if (f.size.width < min) {
        theLabel.transform = CGAffineTransformMakeScale((frame.size.width-2) / min, 1);
    } else {
        theLabel.transform = CGAffineTransformMakeScale(1,1);
        if (needsEnlargement) {
             [theLabel setFrame:CGRectMake(2, -10, min, f.size.height+10)];
        } else {
            [theLabel setFrame:CGRectMake(2, 0, min, f.size.height)];
        }
    }
    [theLabel setContentMode:UIViewContentModeCenter];
    [self setupContinueView];
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
