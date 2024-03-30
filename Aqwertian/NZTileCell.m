//
//  NZTileCell.m
//  Bridge
//
//  Created by Nathan Ziebart on 11/17/12.
//
//

#import "NZTileCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation NZTileCell {
     CAGradientLayer *theTopGradient, *theBottomGradient;
    UIImageView *theImage;
    bool setup;
    UIColor *theColor;
    BOOL shouldReverse;
    BOOL sized;
    UIView *topHighlight, *bottomHighlight;
    NZTileCellPosition thePosition;
    UILabel *theLabel;
}

+ (UIImage *)bgImage {
    static UIImage *theImage = nil;
    
    if (!theImage) {
        theImage = [[UIImage imageNamed:@"c_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10,10,10,10)];
    }
    
    return theImage;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self doSetup];
    }
    return self;
}

- (void)setLabel:(UILabel *)Label {
    theLabel = Label;
}

- (UILabel *)Label {
    return theLabel;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self doSetup];
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.Label.shadowOffset = selected ? (CGSize){0,0} : (CGSize){0,1};
}
//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//    self.textLabel.shadowOffset = selected ? (CGSize){0,0} : (CGSize){0,1};
//}
//
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
//    [super setHighlighted:highlighted animated:animated];
//}
//
//- (void)setHighlighted:(BOOL)highlighted {
//    [super setHighlighted:highlighted];
//  //  self.textLabel.shadowOffset = highlighted ? (CGSize){0,0} : (CGSize){0,1};
//}

- (void)setPosition:(NZTileCellPosition)Position {
    thePosition = Position;
}

- (NZTileCellPosition)Position {
    return thePosition;
}

- (void) doSetup {
    if (setup) return;
    setup = YES;
    thePosition = NZTileCellPositionMiddle;
    theColor = [UIColor blackColor];
    topHighlight = [UIView new];
    bottomHighlight = [UIView new];
    topHighlight.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    bottomHighlight.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.contentView addSubview:topHighlight];
    [self.contentView addSubview:bottomHighlight];
    //self.contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
//    theImage = [UIImageView new];
//    [theImage setImage:[NZTileCell bgImage]];
//    [self.contentView addSubview:theImage];
//    [self.contentView sendSubviewToBack:theImage];
    self.backgroundColor = self.contentView.backgroundColor = [UIColor whiteColor];
    //theTopGradient.cornerRadius = 3;
    self.layer.shadowOffset = (CGSize){0,1};
    self.clipsToBounds = NO;
   // self.contentView.clipsToBounds = YES;
   //self.contentView.layer.masksToBounds = YES;
    self.Reverse = YES;

    UIView *theView = [UIView new];
    theView.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];
    self.selectedBackgroundView = theView;
    self.Label.backgroundColor = [UIColor clearColor];
    self.Label.shadowColor = [UIColor whiteColor];
    self.Label.shadowOffset = (CGSize){0,1};
    [self setup];
    [self updateAppearance];
    
    
}

- (void)setTintColor:(UIColor *)TintColor {
    if (theColor != TintColor) {
         theColor = TintColor;
        [self updateAppearance];
    }
   
}

- TintColor {
    return theColor;
}

- (BOOL)Reverse {
    return shouldReverse;
}

- (void)setReverse:(BOOL)Reverse {
    if (shouldReverse != Reverse) {
        shouldReverse = Reverse;
        [self updateAppearance];
    }
}

- (void) updateAppearance {
    if (theTopGradient) {
        [theTopGradient removeFromSuperlayer];
    }
    theTopGradient = [CAGradientLayer new];
    if (self.Reverse) {
        theTopGradient.colors = [NSArray arrayWithObjects:self.TintColor.CGColor, [UIColor whiteColor].CGColor, nil];
    } else {
        theTopGradient.colors = [NSArray arrayWithObjects:[UIColor whiteColor].CGColor, self.TintColor.CGColor, nil];
    }
    //[self.contentView.layer addSublayer:theTopGradient];
    [self.contentView.layer insertSublayer:theTopGradient atIndex:0];
    theTopGradient.opacity = 0.075;
    theTopGradient.frame = self.layer.frame;
}

- (void) layerSize {
    CGRect frame = self.frame;
    frame.origin = (CGPoint){0,0};
    frame.origin.y = 1;
    frame.size.height -= 2;
    [theTopGradient setFrame:frame];
    sized = NO;
}

- (void)setup {
    // override
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    NSLog(@"%@", self);
}
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
//    frame.origin = (CGPoint){0,0};
//    NSLog(@"%f", self.contentView.frame.size.height);
//    theImage.frame = frame;
//    if (frame.size.height < oldFrame.size.height) {
//        if (!sized) {
//            [self performSelector:@selector(layerSize) withObject:nil afterDelay:0.25];
//            sized = YES;
//        }
//    } else {
//        frame.origin.y  = 1;
//        frame.size.height -= 2;
//        [theTopGradient setFrame:frame];
//    }
    //self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //[[self contentView] setFrame:self.bounds];
    CGRect frame = self.contentView.frame;
    frame.origin.y  = 1;
    frame.origin.x = 0;
    frame.size.height -= 2;
    [theTopGradient setFrame:frame];
    [topHighlight setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
    [bottomHighlight setFrame:CGRectMake(0, self.contentView.frame.size.height-1, self.contentView.frame.size.width, 1)];
    if (self.Position == NZTileCellPositionFirst) {
        self.layer.shadowOpacity = 0;
      //  self.layer.shadowOpacity = 1;
     //   self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-10)].CGPath;
    } else if (self.Position == NZTileCellPositionLast) {
        self.layer.shadowOpacity = 1;
      //   self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height-10)].CGPath;
    } else if (self.Position == NZTileCellPositionBoth) {
        self.layer.shadowOpacity = 1;
      //  self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    } else {
        self.layer.shadowOpacity = 0;
    }
}


@end
