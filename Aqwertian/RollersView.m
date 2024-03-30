//
//  RollersView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/11/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "RollersView.h"
#import "AnimationView.h"

@implementation RollersView {
    NSMutableArray *theRollers;
    NSInteger theFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (id)init {
    self = [super init];
    [self setup];
    return self;
}

- (void)setIndex:(NSInteger)index {
    NSInteger frame = index % 6;
  //  NSLog(@"-- %d", frame);
    for (AnimationView *theView in theRollers) {
        [theView setImageFrame:frame];
    }
}

- (void) setup {
    theRollers = [NSMutableArray new];
    theFrame = 0;
    self.userInteractionEnabled = NO;
    for (int i = 0; i < 8; i++) {
        AnimationView *theView = [AnimationView new];
        [theView setImage:[self imageForRoller:i] numberOfFrames:6];
        [theView setCenter:[self pointForRoller:i]];
        [self addSubview:theView];
        [theRollers addObject:theView];
    }
}

- (CGPoint) pointForRoller:(NSInteger)roller {
    switch (roller) {
        case 0:
            return CGPointMake(29, 8);
            break;
        case 1:
            return CGPointMake(348, 8);
            break;
        case 2:
            return CGPointMake(986, 8);
            break;
        case 3:
            return CGPointMake(667, 8);
            break;
        case 4:
            return CGPointMake(29, 248);
            break;
        case 5:
            return CGPointMake(348, 248);
            break;
        case 6:
            return CGPointMake(986, 248);
            break;
        case 7:
            return CGPointMake(667, 248);
            break;
            
        default:
            return CGPointMake(100, 100);
            break;
    }
}

- (UIImage *)imageForRoller:(NSInteger)roller {
    switch (roller) {
        case 0:
            return [UIImage imageNamed:@"roll-1-top.png"];
            break;
        case 1:
            return [UIImage imageNamed:@"roll-2-top.png"];
            break;
        case 2:
            return [UIImage imageNamed:@"roll-3-top.png"];
            break;
        case 3:
            return [UIImage imageNamed:@"roll-4-top.png"];
            break;
        case 4:
            return [UIImage imageNamed:@"roll-1-bottom.png"];
            break;
        case 5:
            return [UIImage imageNamed:@"roll-2-bottom.png"];
            break;
        case 6:
            return [UIImage imageNamed:@"roll-3-bottom.png"];
            break;
        case 7:
            return [UIImage imageNamed:@"roll-4-bottom.png"];
            break;
            
        default:
            return [UIImage imageNamed:@"roll-1-top.png"];
            break;
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
