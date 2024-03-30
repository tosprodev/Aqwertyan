//
//  StatsDisplay.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/7/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "StatsDisplay.h"
#import "SongOptions.h"
#import "OverlayView.h"

@implementation StatsDisplay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.hidden = YES;
    self.alpha = 0;
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.tooEarlyView.backgroundColor = OverlayViewEarlyColorBold;
        self.tooLateView.backgroundColor = OverlayViewLateColorBold;
        self.missedView.backgroundColor = OverlayViewMissedColorBold;
        self.onTimeView.backgroundColor = OverlayViewOnTimeColorBold;

        UIImageView *iv = (UIImageView *)self.perfectView;
        iv.image = OverlayViewPerfectImage;
        CGRect frame = CGRectInset(iv.frame, -2, -4);
        frame.origin.y += 1;
        frame.size.height -= 1;
        iv.frame = frame;
        self.tooEarlyView.layer.cornerRadius = 4;
        self.tooLateView.layer.cornerRadius = 4;
        self.missedView.layer.cornerRadius = 4;
        self.onTimeView.layer.cornerRadius = 4;

    });

    
    return self;
}

- (void)setStats:(NSArray *)stats {
    
    _stats = stats;
    [self calcStats];
    [self determineLayout];
  }

- (void) determineLayout {
//    if ([SongOptions isExmatch]) {
//        _thisOnTime.hidden = _bestOnTime.hidden = _previousOnTime.hidden = _onTimeLabel.hidden = NO;
//        _notesLabel.text = @"RIGHT NOTES";
//    } else {
//        _thisOnTime.hidden = _bestOnTime.hidden = _previousOnTime.hidden = _onTimeLabel.hidden = YES;
//        _notesLabel.text = @"RIGHT TIME";
//    }
    _saveArrangementButton.hidden = _saveArrangementsLabel.hidden = [SongOptions CurrentItem].Type == LibraryItemTypeArrangement;
}

- (void) calcStats {
    Statistics *s;
    float totalNotes;
    float notes, onTime;
    
    BOOL exmatch = [SongOptions isExmatch];
    
    if (_stats.count) {
        s = _stats[0];
//        totalNotes = s.rightNotes + s.skippedNotes;
//        notes = 100.0 * (float)(s.rightNotes - s.wrongNotes) / totalNotes;
//        onTime = 100.0 * (float)s.notesPlayedOnTime / totalNotes;
//        if (exmatch) {
            _thisScore.text = [NSString stringWithFormat:@"%d", s.totalScore];
//            _thisOnTime.text = [NSString stringWithFormat:@"%.0f%%", onTime];
//        } else {
//            _thisNotes.text = [NSString stringWithFormat:@"%.0f%%", onTime];
//        }
        _onTimeLabel.text = [NSString stringWithFormat:@"%.0f%%", s.onTimePercent];
        _tooEarlyLabel.text = [NSString stringWithFormat:@"%.0f%%", s.tooEarlyPercent];
        _tooLateLabel.text = [NSString stringWithFormat:@"%.0f%%", s.tooLatePercent];
        _perfectLabel.text = [NSString stringWithFormat:@"%.0f%%", s.perfectPercent];
        _missedLabel.text = [NSString stringWithFormat:@"%.0f%%", s.missedPercent];
    } else {
        _thisScore.text = @"";
      //  _thisOnTime.text = @"";
    }
    
    
    if (_stats.count > 1) {
        s = _stats[1];
//        totalNotes = s.rightNotes + s.skippedNotes;
//        notes = 100.0 * (float)(s.rightNotes - s.wrongNotes) / totalNotes;
//        onTime = 100.0 * (float)s.notesPlayedOnTime / totalNotes;
//        if (exmatch) {
            _previousScore.text = [NSString stringWithFormat:@"%d", s.totalScore];
          //  _previousOnTime.text = [NSString stringWithFormat:@"%.0f%%", onTime];
//        } else {
//            _previousNotes.text = [NSString stringWithFormat:@"%.0f%%", onTime];
//        }
    } else {
        _previousScore.text = @"";
       // _previousNotes.text = @"";
    }
    
    if (_stats.count) {
//        float maxNotes = 0, maxOnTime = 0;
//        for (Statistics *s in _stats) {
//            totalNotes = s.rightNotes + s.skippedNotes;
//            notes = 100.0 * (float)(s.rightNotes - s.wrongNotes) / totalNotes;
//            onTime = 100.0 * (float)s.notesPlayedOnTime / totalNotes;
//            
//            if (notes > maxNotes) {
//                maxNotes = notes;
//            }
//            if (onTime > maxOnTime) {
//                maxOnTime = onTime;
//            }
//        }
//        if (exmatch) {
//        _bestNotes.text = [NSString stringWithFormat:@"%.0f%%", maxNotes];
//        _bestOnTime.text = [NSString stringWithFormat:@"%.0f%%", maxOnTime];
//        } else {
//            _bestNotes.text = [NSString stringWithFormat:@"%.0f%%", maxOnTime];
//        }
        
        int bestScore = 0;
        for (Statistics *s in _stats) {
            if (s.totalScore > bestScore) bestScore = s.totalScore;
        }
        
        _bestScore.text = [NSString stringWithFormat:@"%d", bestScore];
        

        
        if ([_onTimeLabel.text.lowercaseString rangeOfString:@"nan"].location != NSNotFound) {
            NSLog(@"break");
        }
        
    } else {
        _bestScore.text = @"";
      //  _bestOnTime.text = @"";
        _tooEarlyLabel.text = @"";
        _tooLateLabel.text = @"";
        _onTimeLabel.text = @"";
        _missedLabel.text = @"";
        _perfectLabel.text = @"";
    }

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
