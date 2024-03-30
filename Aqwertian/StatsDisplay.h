//
//  StatsDisplay.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/7/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Arrangement.h"

@interface StatsDisplay : UIView

//@property (nonatomic) IBOutlet UILabel *thisNotes, *bestNotes, *previousNotes, *thisOnTime, *bestOnTime, *previousOnTime, *onTimeLabel1, *notesLabel,
@property (nonatomic) IBOutlet UILabel *thisScore, *bestScore, *previousScore;
@property (nonatomic) IBOutlet UIButton *saveArrangementButton;
@property (nonatomic) NSArray *stats;

@property (nonatomic) IBOutlet UIView *missedView, *tooEarlyView, *onTimeView, *tooLateView, *perfectView;
@property (nonatomic) IBOutlet UILabel *missedLabel, *tooEarlyLabel, *onTimeLabel, *tooLateLabel, *perfectLabel,*saveArrangementsLabel;

@end
