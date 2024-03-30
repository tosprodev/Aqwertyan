//
//  NZNotationDisplay.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 1/10/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicFile.h"
#import "StatsDisplay.h"

#define NOTATION_MOVING_NOW 0
#define NOTATION_STATIONARY_NOW 1

@interface NZNotationDisplay : UIScrollView <UIScrollViewDelegate>

@property (nonatomic) int mode;
@property (nonatomic) float widthMultiplier;
@property (nonatomic) BOOL autoCalculateWidthMultiplier;
@property (nonatomic) float animationDuration;
@property (nonatomic) int division;
@property (nonatomic) BOOL showLyrics, exmatch, hasPendingNoteWidthChange;
@property (nonatomic) float widthBase;
@property (nonatomic) IBOutlet StatsDisplay *statsDisplay;
@property (nonatomic) BOOL isTwoRow;
@property (nonatomic) BOOL performanceHighlightingEnabled;



+ (NZNotationDisplay *)sharedDisplay;

- (void) setupLayout;
- (void) displayNotes:(NSArray *)notes lyrics:(NSArray *)lyrics;

- (void) noteChangedState:(RGNote *)note;

- (void) startOneSecond;

- (void) showStats:(BOOL)animated;
- (void) hideStats:(BOOL)animated;

- (void) noteOn:(RGNote *)note timing:(int)earlyLate;
- (void) noteOff:(RGNote *)note wasPerfect:(BOOL)perfect heldForRightLength:(BOOL)rightLength;
- (void) cancelOverlaysForNote:(RGNote *)n;

- (float) minimumTicksWidthForDivision:(int)division singleKeyPerHand:(BOOL)twoRow;


@end
