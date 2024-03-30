//
//  OverlayView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/15/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicFile.h"

 UIColor *OverlayViewPerfectBorderColor;
UIColor *OverlayViewOkBorderColor;
 UIColor *OverlayViewEarlyColor;
 UIColor *OverlayViewOnTimeColor;
 UIColor *OverlayViewLateColor;
 UIColor *OverlayViewMissedColor;
UIColor *OverlayViewEarlyColorBold;
UIColor *OverlayViewOnTimeColorBold;
UIColor *OverlayViewLateColorBold;
UIColor *OverlayViewMissedColorBold;

UIImage *OverlayViewPerfectImage;

typedef NS_ENUM(NSInteger, OverlayViewPosition) {
    OverlayViewPositionNone = 0,
    OverlayViewPositionLeft,
    OverlayViewPositionCenter,
    OverlayViewPositionRight
};

@interface OverlayView : UIView

@property (nonatomic) RGNote *note;
@property (nonatomic) OverlayViewPosition position;
@property (nonatomic) BOOL moving;

- (void) wasPerfect;
- (void) wasHeldForRightLength;

@end
