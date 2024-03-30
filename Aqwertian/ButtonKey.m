//
//  ButtonKey.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/21/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "ButtonKey.h"
#import <QuartzCore/QuartzCore.h>
#import "Conversions.h"
#import <CoreGraphics/CoreGraphics.h>
#import "NZInputHandler.h"
#import "KeyboardView.h"

const float ButtonKeyHorizontalOffset = 15;
const float ButtonKeyAngle = 0.175;

@interface ButtonKey ()

+ (UIImage *)downImage;

+ (UIImage *)upImage;

@end

@implementation ButtonKey {
    UILabel *theLabel;
    CGSize theSize;
    UIImage *theUpImage, *theDownImage;
    char theKey;
    bool columned;
    UIImage *highlightImage;
    BOOL thumb;
    CGPoint corners[4];
    CGRect buttonRect;
    BOOL isSlantedRight;
    UIView *rectView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

+ (UIImage *)downImage {
    static UIImage *image = nil;
    
    if (image == nil) {
        image = [[UIImage imageNamed:@"button_bg_pressed_clear.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        
    }
    return image;
}

+ (UIImage *)upImage {
    static UIImage *image = nil;
    
    if (image == nil) {
        image = [[UIImage imageNamed:@"button_bg_clear.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        
    }
    return image;
}

- (UIColor *)colorForKey:(char)key {
    int col = [Conversions columnForKey:key];
    switch (col) {
        case 0:
            return [UIColor blueColor];
            break;
            
        case 1:
            return [UIColor yellowColor];
            break;
        case 2:
            return [UIColor orangeColor];
            break;
        case 3:
            return [UIColor redColor];
            break;
        case 4:
            return [UIColor purpleColor];
            break;
        case 5:
            return [UIColor greenColor];
            break;
        case 6:
            return [UIColor brownColor];
            break;
        case 7:
            return [UIColor cyanColor];
            break;
        case 8:
            return [UIColor yellowColor];
            break;
        case 9:
            return [UIColor redColor];
            break;
            
    }
}

- (void)setColumned:(BOOL)isColumned {
    if (columned != isColumned) {
        columned = isColumned;
        [self setNeedsDisplay];
    }
}

- (CGPoint) rotatePoint:(CGPoint)point {
    float angle = isSlantedRight ? (-ButtonKeyAngle) : (ButtonKeyAngle);
    float x = cosf(angle) * (point.x-self.center.x) - sinf(angle) * (point.y-self.center.y) + self.center.x;
    float y = sinf(angle) * (point.x-self.center.x) + cosf(angle) * (point.y-self.center.y) + self.center.y;
    return (CGPoint){x,y};
}

- (BOOL) containsPoint:(CGPoint)point withExpansion:(float)expansionWidth {
    point = [self rotatePoint:point];
    CGRect bounds =  CGRectInset(buttonRect, -expansionWidth, -expansionWidth);
    return CGRectContainsPoint(bounds, point);
}

- (void)drawRect:(CGRect)rect {

   // [super drawRect:rect];
    if (!columned) {
        if (self.highlighted) {
            [theDownImage drawInRect:rect];
        } else {
            [theUpImage drawInRect:rect];
        }
        if (self.selected) {
            [highlightImage drawInRect:rect];
        }
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor *tintColor = [self colorForKey:theKey];
        
        UIImage *theImage = self.highlighted ? theDownImage : theUpImage;
        
        CGContextTranslateCTM(context, 0, theImage.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode (context, kCGBlendModeMultiply);
        
        CGContextDrawImage(context, rect, theImage.CGImage);
        
        CGContextClipToMask(context, rect, theImage.CGImage);
        
        CGContextSetFillColorWithColor(context, tintColor.CGColor);
        
        CGContextFillRect(context, rect);
    }
}


- (void) setup {
//    [self setBackgroundImage:[ButtonKey upImage] forState:UIControlStateNormal];
//    [self setBackgroundImage:[ButtonKey downImage] forState:UIControlStateHighlighted];
//    
//    theLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
//    theLabel.backgroundColor = [UIColor clearColor];
//    theLabel.font = [UIFont boldSystemFontOfSize:22];
//    theLabel.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:1 alpha:0.75];
//    theLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
//    theLabel.shadowOffset = CGSizeMake(0,-0.5);
//    theLabel.textAlignment = UITextAlignmentCenter;
//    [self addSubview:theLabel];
    
//    [self addTarget:self action:@selector(keyDown:) forControlEvents:UIControlEventTouchDown];
//    [self addTarget:self action:@selector(keyUp:) forControlEvents:UIControlEventTouchUpInside];
//   // [self addTarget:self action:@selector(drag:) forControlEvents:UIControlEventTouchUpOutside];
//    [self addTarget:self action:@selector(keyUp:) forControlEvents:UIControlEventTouchDragExit];
//  //  [self addTarget:self action:@selector(keyDown:) forControlEvents:UIControlEventTouchDragOutside];
//    [self addTarget:self action:@selector(keyDown:) forControlEvents:UIControlEventTouchDragEnter];
//    //[theButton addTarget:self action:@selector(keyDown:) forControlEvents:UIControlEventTouchDragEnter];
}

BOOL isBlack(char c) {
    return (c == '2' || c == '4' || c == '6' || c == '8');
}
- (BOOL) charIsSlantedRight:(char)c {
    static NSString *const right = @"QWERTASDFGZXCVB";
    for (int i = 0; i < right.length; i++) {
        if ([right characterAtIndex:i] == c) {
            return YES;
        }
    }
    return NO;
}


- (void) setChar:(char)aChar thumb:(BOOL)isthumb{
    isSlantedRight = [self charIsSlantedRight:aChar];
    self.tag = aChar;
    thumb = isthumb;
    NSString *theUpImageName, *theDownImageName;
    if ('A' <= aChar && aChar <= 'Z') aChar += 'a' - 'A';
   
    NSString *theChar = [NSString stringWithFormat:@"%c", aChar];
    theKey = aChar;
    
    if (aChar == '/') {
        theChar = @":";
    }
    
    if (thumb) {
        if (!theLabel) {
            theLabel = [UILabel new];
            [self addSubview:theLabel];
           
           
        
            theLabel.backgroundColor = [UIColor clearColor];
            theLabel.font = [UIFont boldSystemFontOfSize:30];
            theLabel.textAlignment = UITextAlignmentCenter;
            
        }
        theLabel.text = [NSString stringWithFormat:@"%c", aChar];
        
       // theUpImageName = [NSString stringWithFormat:@"piano-key-%@.png", theChar];
       // theDownImageName = [NSString stringWithFormat:@"piano-key-%@-pressed.png", theChar];
        if (isBlack(aChar)) {
            theUpImageName = @"thumb-key-black.png";
            theDownImageName = @"thumb-key-black-down.png";
            theLabel.textColor = [UIColor whiteColor];
            theLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:1];
             theLabel.shadowOffset = CGSizeMake(0,-1);
                theLabel.alpha = 0.3;
        } else {
            theUpImageName = @"thumb-key.png";
            theDownImageName = @"thumb-key-down.png";
            theLabel.textColor = [UIColor brownColor];
            theLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
             theLabel.shadowOffset = CGSizeMake(0,1);
                theLabel.alpha = 0.4;
        }
        highlightImage = [UIImage imageNamed:@"thumb-key-focus.png"];
        
    } else {
        
        
        if (aChar >= '1' && aChar <= '9') {
            theUpImageName = [NSString stringWithFormat:@"piano-key-%@.png", theChar];
            theDownImageName = [NSString stringWithFormat:@"piano-key-%@-pressed.png", theChar];
            highlightImage = [UIImage imageNamed:[NSString stringWithFormat:@"piano-key-%@-focus.png", theChar]];
        } else {
            if (aChar == ' ') {
                theUpImageName = @"sustain-left.png";
                theDownImageName = @"sustain-left-pressed.png";
            } else if (aChar == '_') {
                theUpImageName = @"sustain-right.png";
                theDownImageName = @"sustain-right-pressed.png";
            } else {
                theUpImageName = [NSString stringWithFormat:@"key-%@.png", theChar];
                theDownImageName = [NSString stringWithFormat:@"key-%@-pressed.png", theChar];
                highlightImage = [UIImage imageNamed:[NSString stringWithFormat:@"key-%@-focus.png", theChar]];
            }
        }
    }
//    if (aChar > 'Z') aChar += 'A' - 'a';
//    [theLabel setText:[NSString stringWithFormat:@"%c", aChar]];
 //   [self setTitle:[NSString stringWithFormat:@"%c", aChar] forState:UIControlStateHighlighted];
    
    UIImage *theImage = [UIImage imageNamed:theUpImageName];
    theUpImage = theImage;
    theDownImage = [UIImage imageNamed:theDownImageName];
  //[self setBackgroundImage:theImage forState:UIControlStateNormal];
  //[self setBackgroundImage:[UIImage imageNamed:theDownImageName] forState:UIControlStateHighlighted];
    theSize = theImage.size;
//    if(isthumb) {
//        theSize.width*= 0.7;
//        theSize.height*= 0.7;
//    }
    //[self setTintColor:[self colorForKey:aChar]];
    self.layer.shadowColor = [self colorForKey:aChar].CGColor;
    self.layer.shadowOffset = (CGSize){0,0};
  //  self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 10;
   // [self setNeedsDisplay];
}

- (void) calculateCorners {
//    float x = self.frame.origin.x;
//    float y = self.frame.origin.y;
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float verticalOffset = ((width - ButtonKeyHorizontalOffset) * tanf(ButtonKeyAngle));
//    if (isSlantedRight) {
//        corners[0] = CGPointMake(x + ButtonKeyHorizontalOffset, y);
//        corners[3] = CGPointMake(x + width - ButtonKeyHorizontalOffset, y + height);
//        corners[1] = CGPointMake(x + width, y + verticalOffset);
//        corners[2] = CGPointMake(x, y + height - verticalOffset);
//    } else {
//        corners[1] = CGPointMake(x + width - ButtonKeyHorizontalOffset, y);
//        corners[2] = CGPointMake(x + ButtonKeyHorizontalOffset, y + height);
//        corners[0] = CGPointMake(x, y + verticalOffset);
//        corners[3] = CGPointMake(x + width, y + height - verticalOffset);
//    }

    float angle = ButtonKeyAngle;
    float tWidth = verticalOffset / sinf(angle);
    float tHeight = ButtonKeyHorizontalOffset / sinf(angle);
    float xDiff = (self.frame.size.width - tWidth)/2;
    float yDiff = (self.frame.size.height - tHeight)/2;
    buttonRect = CGRectMake(self.frame.origin.x + xDiff, self.frame.origin.y + yDiff, tWidth, tHeight);
//    if (!rectView && self.frame.size.width > 0) {
//        rectView = [UIView new];
//        rectView.frame = [self convertRect:buttonRect fromView:self.superview];
//        rectView.backgroundColor = [UIColor clearColor];
//        rectView.layer.borderColor = [UIColor whiteColor].CGColor;
//        rectView.layer.borderWidth = 3;
//        if (isSlantedRight) {
//            rectView.transform = CGAffineTransformMakeRotation(ButtonKeyAngle);
//            rectView.backgroundColor = [UIColor blueColor];
//        } else {
//            rectView.transform = CGAffineTransformMakeRotation(-ButtonKeyAngle);
//            rectView.backgroundColor = [UIColor redColor];
//        }
//        rectView.alpha = 0.2;
//        [self addSubview:rectView];
//    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
}



- (void) keyDown:(id)sender {
    if ((self.tag == ' ' || self.tag == '_') && [NZInputHandler sharedHandler].autoPedal) {
        return;
    }
    if (![super isHighlighted]) {
   // UIButton *theButton = (UIButton *)sender;
        
    
//        [UIView transitionWithView:self
//                          duration:0.1
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
                            [super setHighlighted:YES];
                            self.selected=NO;
//                        }
//                        completion:nil];
        [self setNeedsDisplay];
       // theLabel.textColor = [UIColor whiteColor];
        theLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 0.5);
    [self.Delegate keyDown:self];
    }
}

- (void) keyUp:(id)sender {
    if ((self.tag == ' ' || self.tag == '_') && [NZInputHandler sharedHandler].autoPedal) {
        return;
    }
    if ([super isHighlighted]) {
//        [UIView transitionWithView:self
//                          duration:0.1
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
                            [super setHighlighted:NO];
//                           }
//                        completion:nil];
        [self setNeedsDisplay];
       // theLabel.textColor = [UIColor blueColor];
        theLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
  //  UIButton *theButton = (UIButton *)sender;
    [self.Delegate keyUp:self];
    }
}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
  //  [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.2];
}

- (void)setCenter:(CGPoint)center {
    [super setFrame:CGRectMake(0, 0, theSize.width, theSize.height)];
    [super setCenter:center];
    [self calculateCorners];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    theLabel.frame = CGRectMake(0,0,theSize.width, theSize.width);
}


// Only override drawRect: if you perform custom drawing.
/*
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
