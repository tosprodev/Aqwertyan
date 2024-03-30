//
//  InsetShadowView.m
//  Bridge
//
//  Created by Nathan Ziebart on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InsetShadowView.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@implementation InsetShadowView {
    CAGradientLayer *theGradient;
}

@synthesize cornerRadius, shadowOpacity, shadowOffset, shadowRadius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
     //   self.image = [[UIImage imageNamed:@"inset.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
       [self setup];
    //   self.image = [[UIImage imageNamed:@"inset.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        [self setup];
      // self.image = [[UIImage imageNamed:@"inset.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return self;
}

- (void) setup {
//    self.shadowOffset = 1;
//    self.cornerRadius = 5;
//    self.shadowOpacity = 1;
//    self.shadowRadius = 5;
//    self.layer.cornerRadius = self.cornerRadius;
//    self.opaque = NO;
//    self.userInteractionEnabled = NO;
//    self.layer.masksToBounds = YES;
//    self.clipsToBounds = YES;
//    self.layer.shouldRasterize=YES;
//    self.layer.rasterizationScale=[[UIScreen mainScreen] scale];
    self.borderStyle = UITextBorderStyleRoundedRect;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    
}

- (void)goGradient {
   // self.image = [[UIImage imageNamed:@"inset_gradient.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [self addGradient];
}

- (void)goWhite {
   // self.image = [[UIImage imageNamed:@"inset_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)goGray {
   // self.image = [[UIImage imageNamed:@"inset_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
  //  self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
}

- (void)addGradient {
    theGradient = [[CAGradientLayer alloc] init];
    theGradient.colors = [NSArray arrayWithObjects:[UIColor whiteColor].CGColor, [UIColor blackColor].CGColor, nil];
    theGradient.opacity = 0.2;
    theGradient.cornerRadius = self.cornerRadius;
    theGradient.masksToBounds = YES;
    [self.layer addSublayer:theGradient];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UIResponder *theResponder = self.nextResponder;
    [theResponder touchesBegan:touches withEvent:event]; 
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (theGradient) [theGradient setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

//- (void)drawRect:(CGRect)rect
//{
// CGRect bounds = [self bounds];
//   // bounds.origin.y += 1;
// CGContextRef context = UIGraphicsGetCurrentContext();
//    CGFloat radius = self.cornerRadius;
// 
// 
// // Create the "visible" path, which will be the shape that gets the inner shadow
// // In this case it's just a rounded rect, but could be as complex as your want
// CGMutablePathRef visiblePath = CGPathCreateMutable();
//    CGRect bounds2 = bounds;
//    bounds2.origin.y += 1;
// CGRect innerRect = CGRectInset(bounds2, radius, radius);
// CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
// CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
// CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
// CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
// CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
// CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
// CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
// CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
// CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
// CGPathCloseSubpath(visiblePath);
// 
// // Fill this path
// UIColor *aColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
//
// 
// 
// // Now create a larger rectangle, which we're going to subtract the visible path from
// // and apply a shadow
// CGMutablePathRef path = CGPathCreateMutable();
// //(when drawing the shadow for a path whichs bounding box is not known pass "CGPathGetPathBoundingBox(visiblePath)" instead of "bounds" in the following line:)
// //-42 cuould just be any offset > 0
// CGPathAddRect(path, NULL, CGRectInset(bounds, -42, -42));
// 
// // Add the visible path (so that it gets subtracted for the shadow)
// CGPathAddPath(path, NULL, visiblePath);
// CGPathCloseSubpath(path);
// 
// // Add the visible paths as the clipping path to the context
// CGContextAddPath(context, visiblePath); 
// CGContextClip(context);         
// 
// 
// // Now setup the shadow properties on the context
// aColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
// CGContextSaveGState(context);
// CGContextSetShadowWithColor(context, CGSizeMake(0.0f, self.shadowOffset), self.shadowRadius, [aColor CGColor]);   
// 
// // Now fill the rectangle, so the shadow gets drawn
// [aColor setFill];   
// CGContextSaveGState(context);   
// CGContextAddPath(context, path);
// CGContextEOFillPath(context);
// 
// // Release the paths
// CGPathRelease(path);    
// CGPathRelease(visiblePath);
//}


@end
