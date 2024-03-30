//
//  ChannelView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mid2jmid.h"

@interface ChannelView : UIImageView

//@property BOOL muted;
@property int active;
@property (nonatomic) BOOL melody;
@property Channel *channel;
@property UIScrollView *scrollView;

+ (UIImage *)upImage;
+ (UIImage *)downImage;
+ (UIColor *)scrollViewColor;

+ (NSString *)nameForProgram:(NSInteger)program channel:(NSInteger)channel;

- (NSComparisonResult) compare:(ChannelView *)anotherView;

- (void) clearNotes;
- (void) noteOn:(int)key;
- (void) noteOff:(int)key;
//- (void) setClock:(int)clock;

@end
