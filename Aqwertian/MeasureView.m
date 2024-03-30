//
//  MeasureView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/11/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "MeasureView.h"

@implementation MeasureView

- (id)initWithFrame:(CGRect)frame
{
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

- (void) setup {
    self.image = [UIImage imageNamed:@"note-grid.png"];
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 1;
    frame.size.width -= 1;
  //  frame.size.height = 167;
    [super setFrame:frame];
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
