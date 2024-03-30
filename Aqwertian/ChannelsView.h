//
//  ChannelsView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelView.h"

@interface ChannelsView : UIView

- (void) setAllMuted:(BOOL)muted;
- (void) displayChannels:(NSArray *)channels;
+ (ChannelsView *)sharedView;
- (void) noteOn:(int)key channel:(int)channel;
- (void) noteOff:(int)key channel:(int)channel;
- (void) clearNotes;
- (void) setClocks:(int)clocks;
- (void) channelView:(ChannelView *)view chanedTo:(int)state;
- (void) setActiveTrack:(int)track isChannel:(BOOL)channel;
- (void) setMelodyTrack:(int)track isChannel:(BOOL)channel;
@end
