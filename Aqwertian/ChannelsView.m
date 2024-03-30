//
//  ChannelsView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//
#import "ChannelView.h"
#import "ChannelsView.h"

ChannelsView *theChannelsView;

@implementation ChannelsView {
    NSMutableArray *views;
    NSMutableArray *theChannelViews;
    NSArray *theChannels;
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

- (id)init {
    self = [super init];
    [self setup];
    return self;
}

- (void)setClocks:(int)clocks {
    for (ChannelView *view in theChannelViews) {
        [view.scrollView setContentOffset:CGPointMake(clocks,0)];
    }
}

+ (ChannelsView *)sharedView {
    return theChannelsView;
}

- (void)setMelodyTrack:(int)track isChannel:(BOOL)channel {
    for (ChannelView *cv in theChannelViews) {
        if (!channel && cv.channel.Track == track) {
            [cv setMelody:YES];
        } else if (channel && cv.channel.Number == track) {
            [cv setMelody:YES];
        } else {
            [cv setMelody:NO];
        }
    }
}

- (void)setActiveTrack:(int)track isChannel:(BOOL)channel {
    for (ChannelView *cv in theChannelViews) {
        if (!channel && cv.channel.Track == track) {
            [cv setActive:CH_ACTIVE];
            [self channelView:cv chanedTo:CH_ACTIVE];
            break;
        } else if (channel && cv.channel.Number == track) {
            [cv setActive:CH_ACTIVE];
            [self channelView:cv chanedTo:CH_ACTIVE];
            break;
        }
    }
}

- (void)noteOff:(int)key channel:(int)channel {
    [views[channel] noteOff:key];
}

- (void)noteOn:(int)key channel:(int)channel {
    [views[channel] noteOn:key];
}

- (void)clearNotes {
    for (ChannelView *view in views) {
        [view clearNotes];
    }
}

- (void) setup {
    views = [NSMutableArray new];
    for (int i = 0; i < 16; i++) {
        [views addObject:[ChannelView new]];
    }
    theChannelsView =self;
    theChannelViews = [NSMutableArray new];
}

- (void)channelView:(ChannelView *)v chanedTo:(int)state {
    if (state == CH_ACTIVE) {
        for (ChannelView *view in theChannelViews) {
            if (view == v) continue;
            if ([view active] == CH_ACTIVE) {
                [view setActive:CH_ACCOMP];
            }
        }
    } else {
        BOOL found=NO;
        for (ChannelView *view in theChannelViews) {
            if ([view active] == CH_ACTIVE) {
                found=YES;
                break;
            }
        }
        if (!found) {
            if (theChannelViews.count == 1) {
                [(ChannelView *)theChannelViews[0] setActive:CH_ACTIVE];
            } else {
            for (ChannelView *view in theChannelViews) {
                 if (view == v) continue;
                [view setActive:CH_ACTIVE];
                break;
            }
            }
        }
    }
}

- (void)displayChannels:(NSArray *)channels {
    theChannels = channels;
    for (UIView *theView in theChannelViews) {
        [theView removeFromSuperview];
    }
    [theChannelViews removeAllObjects];
    for (Channel *c in theChannels) {
        int i = c.Number;
    
        ChannelView *theView = [views objectAtIndex:i];
        theView.channel = c;
        [theChannelViews addObject:theView];
        [self addSubview:theView];
    }
    [theChannelViews sortUsingSelector:@selector(compare:)];
    [self clearNotes];
    [self layoutSubviews];
   // [self setAllMuted:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
#define ROWS 4
#define COLS 4
#define H_PADDING 22
#define V_PADDING 8
    
    double width = 212;//(self.frame.size.width - ((COLS + 1)*H_PADDING))/COLS;
    double height = 123;//(self.frame.size.height - ((ROWS + 1)*V_PADDING))/ROWS;
    
    CGRect frame = self.frame;
    
    for (NSInteger i = 0; i < ROWS; i++) {
        for (NSInteger j = 0; j < COLS; j++) {
            if (theChannelViews.count > i*COLS + j) {
                ChannelView *theChannelView = [theChannelViews objectAtIndex:i*COLS+j];
                [theChannelView setFrame:CGRectMake(H_PADDING*(j+1) + width*j, V_PADDING*(i+1) + height*i, width, height)];
            } else {
                break;
            }
        }
    }
    
}



//- (void)setAllMuted:(BOOL)muted {
//    for (ChannelView *theView in theChannelViews) {
//        theView.muted = muted;
//    }
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
