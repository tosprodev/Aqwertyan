//
//  DoubleSelectSegmentedControl.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/15/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "DoubleSelectSegmentedControl.h"

@implementation DoubleSelectSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    if (current == self.selectedSegmentIndex)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
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
