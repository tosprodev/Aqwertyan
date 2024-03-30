//
//  ScrollPaperTableView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/23/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "ScrollPaperTableView.h"

@implementation ScrollPaperTableView {
    UIImageView *shadesView, *highlightsView;
    UIScrollView *paperView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPrefix:(NSString *)prefix {
    if (_prefix) return;
    _prefix = prefix;
    self.backgroundColor = [UIColor clearColor];
    
    shadesView = [UIImageView new];
    highlightsView = [UIImageView new];
    paperView = [UIScrollView new];
    
    shadesView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-paper-shades.png", prefix]];
    highlightsView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-paper-lights.png", prefix]];
    paperView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-paper.png", prefix]]];
    
    CGRect frame = self.frame;
    frame.size = shadesView.image.size;
    self.frame = frame;
    shadesView.frame = highlightsView.frame = paperView.frame = frame;//CGRectMake(122,169,780,308);
    [self.superview addSubview:paperView];
    [self.superview addSubview:highlightsView];
    [self.superview bringSubviewToFront:self];
    [self.superview addSubview:shadesView];
}

//- (void)reloadData {
//    [super reloadData];
//    paperView.contentSize = self.contentSize;
//}

- (void)didScroll {
     paperView.contentSize = self.contentSize;
    paperView.contentOffset = self.contentOffset;
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
