//
//  AnimationView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/11/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "AnimationView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AnimationView {
    UIImageView *theImageView;
    NSInteger theNumberOfFrames;
    float theHeight;
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
    self = [super init];
    theImageView = [UIImageView new];
    //theImageView.layer.delegate = nil;
    [self addSubview:theImageView];
    self.clipsToBounds = YES;
    return self;
}

- (void)setImage:(UIImage *)anImage numberOfFrames:(NSInteger)frames {
    theNumberOfFrames = frames;
    theImageView.image = anImage;
    theHeight = anImage.size.height/(float)frames;
    [self setFrame:CGRectMake(0, 0, anImage.size.width, theHeight)];
    [theImageView setFrame:CGRectMake(0, 0, anImage.size.width, anImage.size.height)];
}

- (void)setImageFrame:(NSInteger)frame {
    [theImageView setFrame:CGRectMake(0, -frame*theHeight, theImageView.frame.size.width, theImageView.frame.size.height)];
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
