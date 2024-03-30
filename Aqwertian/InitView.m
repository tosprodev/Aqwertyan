//
//  InitView.m
//  Bridge
//
//  Created by Nathan Ziebart on 8/23/12.
//
//

#import "InitView.h"

@implementation InitView {
    BOOL setup;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!setup)
            [self setup];
        setup=YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (!setup)
            [self setup];
        setup=YES;
    }
    return self;
}

- init {
    self = [super init];
    if (self) {
        if (!setup)
            [self setup];
        setup=YES;
    }
    return self;
}

- (void)setup {
    
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
