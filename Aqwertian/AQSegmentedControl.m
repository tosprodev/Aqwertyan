//
//  AQSegmentedControl.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/28/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "AQSegmentedControl.h"

@implementation AQSegmentedControl {
    BOOL setup;
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
    [self setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setDividerImage:[UIImage imageNamed:@"blank.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self addTarget:self action:@selector(setupImages) forControlEvents:UIControlEventValueChanged];
    for (int i = 0; i < self.numberOfSegments; i++) {
    [self setTitle:@"" forSegmentAtIndex:i];

    }
    [self setupImages];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    [self setupImages];
}

- (void) setupImages {
    _image1.highlighted = self.selectedSegmentIndex == 0;
    _image2.highlighted = self.selectedSegmentIndex == 1;
    _image3.highlighted = self.selectedSegmentIndex == 2;
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
