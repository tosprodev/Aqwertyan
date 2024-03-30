//
//  InfiniteScrollView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/10/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "InfiniteScrollView.h"

@implementation InfiniteScrollView {
    UIView *theContent;
}

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
    theContent = [UIView new];
    [theContent setFrame:CGRectMake(0, 0, self.frame.size.width * 4, self.frame.size.height)];
    self.contentSize = CGSizeMake(self.frame.size.width * 4, self.frame.size.height);
    [self addSubview:theContent];
    self.contentOffset = CGPointMake(self.frame.size.width * 2, 0);
}

- (void)setPattern:(UIColor *)aColor {
    theContent.backgroundColor = aColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.contentOffset.x - self.contentSize.width/2 > self.contentSize.width/5.0) {
        self.contentOffset = CGPointMake(self.contentOffset.x - self.contentSize.width/5.0, 0);
    } else if (self.contentOffset.x - self.contentSize.width/2 < -self.contentSize.width/5.0) {
        self.contentOffset = CGPointMake(self.contentOffset.x + self.contentSize.width/5.0, 0);
    }
}

- (void)setFrame:(CGRect)frame {
    [theContent setFrame:CGRectMake(0, 0, self.frame.size.width * 4, self.frame.size.height)];
    self.contentSize = CGSizeMake(self.frame.size.width * 4, self.frame.size.height);
    self.contentOffset = CGPointMake(self.frame.size.width * 2, 0);
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
