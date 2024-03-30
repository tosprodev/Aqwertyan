//
//  StatsViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 1/6/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "StatsViewController.h"
//#import "NotationDisplay.h"
#import "NZInputHandler.h"
#import "MusicFile.h"
#import "PerformanceViewController.h"
#import "StatsHistoryViewController.h"
#import "NZEvents.h"
#import "OverlayView.h"
#import "StatsMailer.h"

static StatsViewController *theStatsViewController;

@interface StatsViewController () {
    IBOutlet UILabel *label;
    IBOutlet UIView *saveFileBox;

    IBOutlet UITextField *saveFileTextField;
    NSMutableArray *labels;
    IBOutlet UIButton *historyButton;
    UIPopoverController *pc;
    CGRect _realBounds;
    BOOL stopAnimating;
}

@property (nonatomic) IBOutlet UIView *missedView, *tooEarlyView, *tooLateView, *onTimeView, *perfectView, *scoreBackground, *backgroundView;
@property (nonatomic) IBOutlet UILabel *thisScore, *bestScore, *previousScore;

- (IBAction)share:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)showHistory:(id)sender;
- (IBAction)saveFile:(id)sender;
@end

@implementation StatsViewController

+ (StatsViewController *)sharedController {
    return  theStatsViewController;
}

- (void)saveFile:(id)sender {
    if (saveFileBox.alpha) {
    [[PerformanceViewController sharedController] saveArrangementWithName:saveFileTextField.text];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.45];
        saveFileBox.alpha=0;
        [UIView commitAnimations];
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NZEvents startTimedFlurryEvent:@"Stats screen opened"];
    
    stopAnimating = NO;
    
        [self animateScoreBackground];
}

- (void) animateScoreBackground {
    if (stopAnimating) return;
    
    [UIView transitionWithView:self.thisScore duration:.67 options:UIViewAnimationOptionCurveLinear animations:^(void) {
        self.thisScore.alpha = 0.2;
    }completion:^(BOOL finished) {
        [UIView transitionWithView:self.scoreBackground duration:.67 options:UIViewAnimationOptionCurveLinear animations:^(void) {
            self.thisScore.alpha = 1;
        }completion:^(BOOL finished) {
            [self animateScoreBackground];
        }];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NZEvents stopTimedFlurryEvent:@"Stats screen opened"];
    stopAnimating = YES;
}

- (void)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[PerformanceViewController sharedController] regainKeyboardControl];
    }];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [[PerformanceViewController sharedController] dismissStats];
}

- (void) setupLabels:(int)number {
    labels = [NSMutableArray new];
    float height = 44;
    
    static float titleWidth = 261;
    static float statWidth = 140;
    
    for (int x = 0; x < 4; x++) {
        [labels addObject:[NSMutableArray new]];
        float xOrigin = 174;
        if (x > 0) {
            xOrigin += titleWidth + statWidth * (x-1);
        }
        float width = x == 0 ? titleWidth : statWidth;
        for (int i = 0; i < number; i++) {
            UILabel *l = [UILabel new];
            l.textAlignment = UITextAlignmentCenter;
            
            if (x > 0) {
                l.font = [UIFont fontWithName:@"Futura-Medium" size:24];
            } else {
                l.font = [UIFont fontWithName:@"Futura-Medium" size:18];
            }
            if (x == 0) {
                l.textColor = [UIColor colorWithRed:154.0/255.0 green:112.0/255.0 blue:57.0/255.0 alpha:1];
            } else if (x == 1) {
                 l.textColor = [UIColor colorWithRed:93.0/255.0 green:53.0/255.0 blue:34.0/255.0 alpha:1];
            } else if (x == 2) {
                 l.textColor = [UIColor colorWithRed:140.0/255.0 green:122.0/255.0 blue:109.0/255.0 alpha:1];
            } else {
                 l.textColor = [UIColor colorWithRed:154.0/255.0 green:112.0/255.0 blue:57.0/255.0 alpha:1];
            }
            l.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
            l.shadowOffset =CGSizeMake(0,1);
            l.backgroundColor = [UIColor clearColor];
            l.frame = CGRectMake(xOrigin, 118 + height + height*i, width, height);
            [self.view addSubview:l];
            [labels[x] addObject:l];
        }
        
        if (x > 0) {
            UILabel *l = [UILabel new];
            if (x == 1) {
               // l.text = @"This";
            } else if (x == 2) {
              //  l.text = @"Previous";
            } else {
               // l.text = @"Best";
            }
            l.textAlignment = UITextAlignmentCenter;
            //[self.view addSubview:l];
            l.frame = CGRectMake(xOrigin, 100, width, height);
        }
    }
    [self showLabels];
}

- (void) calcStats {
    Statistics *s;
    float totalNotes;
    float notes, onTime;
    
    [self clearStats];
    
    NSArray *_stats = [SongOptions currentStats];
    
    if (_stats.count) {
        s = _stats[0];
        totalNotes = s.rightNotes + s.skippedNotes;
        [self showStats:s index:1];
        self.thisScore.text = [NSString stringWithFormat:@"%d", s.totalScore];
    } else {
        self.thisScore.text = nil;
    }
    
    
    if (_stats.count > 1) {
        s = _stats[1];
        totalNotes = s.rightNotes + s.skippedNotes;
        [self showStats:s index:2];
          self.previousScore.text = [NSString stringWithFormat:@"%d", s.totalScore];
    } else {
        self.previousScore  .text = nil;
    }
    
    if (_stats.count) {
        Statistics  *max = nil;
        float maxRightNotes = 0, minWrongNotes = MAXFLOAT, minSkippedNotes = MAXFLOAT, maxOnTime = 0, maxAccuracy = MAXFLOAT;
        for (Statistics *s in _stats) {
            if (s.totalScore > max.totalScore) {
                max = s;
            }
        }
        [self showStats:max index:3];
        self.bestScore.text = [NSString stringWithFormat:@"%d", max.totalScore];
    } else {
        self.bestScore.text = nil;
    }

}

- (void)share:(id)sender {
    UIView *view = (UIView *)sender;
    [[StatsMailer instance] showActionSheetFromRect:view.frame inView:view.superview forScreenshot:self.view withFrame:CGRectZero forViewController:self];
}

- (void) showLabels {
    [labels[0][0] setText:[NSString stringWithFormat:@"Total Notes"]];
    [labels[0][1] setText:[NSString stringWithFormat:@"%% Notes Played"]];
    [labels[0][2] setText:[NSString stringWithFormat:@"Total Key Hits"]];
    [labels[0][3] setText:[NSString stringWithFormat:@"%% Correct Key Hits"]];
    [labels[0][4] setText:[NSString stringWithFormat:@""]];
    [labels[0][5] setText:[NSString stringWithFormat:@"Missed"]];
    [labels[0][6] setText:[NSString stringWithFormat:@"Too Early"]];
    [labels[0][7] setText:[NSString stringWithFormat:@"On Time"]];
    [labels[0][8] setText:@"Too Late"];
    [labels[0][9] setText:[NSString stringWithFormat:@"Perfect"]];
    [labels[0][10] setText:[NSString stringWithFormat:@""]];
    [labels[0][11] setText:[NSString stringWithFormat:@""]];
}

- (void) clearStats {
    for (int x = 1; x < 4; x++) {
        for (UILabel *label in labels[x]) {
            label.text = @"";
        }
    }
}

- (void)showStats:(Statistics *)s index:(int)index; {
    double totalNotes = s.total;
    double totalKeyHits = s.rightNotes + s.wrongNotes;
    [labels[index][0] setText:[NSString stringWithFormat:@"%d", s.total]];
    [labels[index][1] setText:[NSString stringWithFormat:@"%.0f%%", s.notesPlayedPercent]];
    [labels[index][2] setText:[NSString stringWithFormat:@"%d", s.totalKeyHits]];
    [labels[index][3] setText:[NSString stringWithFormat:@"%.0f%%", s.correctKeyHitsPercent]];
    [labels[index][4] setText:[NSString stringWithFormat:@""]];
    [labels[index][5] setText:[NSString stringWithFormat:@"%.0f%%", s.missedPercent]];
    [labels[index][6] setText:[NSString stringWithFormat:@"%.0f%%", s.tooEarlyPercent]];
    [labels[index][7] setText:[NSString stringWithFormat:@"%.0f%%", s.onTimePercent]];
    [labels[index][8] setText:[NSString stringWithFormat:@"%.0f%%", s.tooLatePercent]];
    [labels[index][9] setText:[NSString stringWithFormat:@"%.0f%%", s.perfectPercent]];
    [labels[index][10] setText:[NSString stringWithFormat:@""]];
    [labels[index][11] setText:[NSString stringWithFormat:@""]];
    
    }


- (void) showOrHideSaveFileBox {
//    if ([SongOptions CurrentItem].Type != LibraryItemTypeArrangement) {
//        saveFileTextField.text = [SongOptions CurrentItem].Title;
//        saveFileBox.alpha = 1;
//        historyButton.alpha = 0;
//    } else {
//        saveFileBox.alpha=0;
//        historyButton.alpha=1;
//    }
}

+ (Statistics *)getStats {
     Statistics *s = [Statistics new];
    
    int wrongNotes = 0, skippedNotes = 0, rightNotes = 0, notesPlayedOnTime = 0;
    float tempoAccuracy = 0; // average time off from actual time (in seconds)
    RGNote *lastNote = nil;
    for (RGNote *n in [NZInputHandler sharedHandler].notes) {
        if (n.time >= [NZInputHandler sharedHandler].currentTicks) {
            break;
        }
        if (n.note == 0) continue;
        if (!n.autoPlayed) {
            
            s.totalNotAutoplayed++;
            if (n.timePlayed > -1 && !n.autoPlayed) {
                rightNotes++;
                int margin = 0.15 * n.rate;
                int diff = ABS(n.timePlayed - n.time);
                if (diff <= margin) {
                    notesPlayedOnTime++;
                }
                if (!n.autoPlayed) {
                    if (n.timing < 0) {
                        s.tooEarly++;
                    } else if (n.timing > 0) {
                        s.tooLate++;
                    } else {
                        s.onTime++;
                        if (n.heldForRightDuration) {
                            s.perfect++;
                        }
                    }
                }
                tempoAccuracy += (float)diff / (lastNote ? lastNote.rate : n.rate);
            } else {
                skippedNotes++;
                s.missed++;
            }
        } else {
            s.missed++;
        }
        
        // 0.15 seconds
        // 0.15 (s) * rate (ticks/min) * 1/60 (min/sec)
        lastNote = n;
        
        
    }
    wrongNotes = [NZInputHandler sharedHandler].wrongNotes;
    
    tempoAccuracy /= rightNotes;
    
   
    s.wrongNotes=wrongNotes;
    s.rightNotes=rightNotes;
    s.skippedNotes=skippedNotes;
    s.tempoAccuracy=tempoAccuracy;
    s.notesPlayedOnTime=notesPlayedOnTime;
    
    s.total = [NZInputHandler sharedHandler].notes.count;
    
    if (s.totalNotAutoplayed == 0) s.totalNotAutoplayed = 1;
    
    return s;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.view.superview.clipsToBounds = NO;
//    CGRect curFrame = self.view.superview.frame;
//    CGRect newFrame = CGRectInset(curFrame, -(810 - curFrame.size.width), -(740 - curFrame.size.height));
//    self.view.superview.frame = newFrame;
  //  self.view.frame = newFrame;
    self.view.superview.bounds = _realBounds;
    [self showOrHideSaveFileBox];
   // Statistics *s = [StatsViewController getStats];
    [self calcStats];
    //[self showStats:s.rightNotes wrongNotes:s.wrongNotes skippedNotes:s.skippedNotes noteOnTime:s.notesPlayedOnTime accuracy:s.tempoAccuracy];
}

- (void)showHistory:(id)sender {
    StatsHistoryViewController *shvc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"StatsHistory"];
    pc = [[UIPopoverController alloc] initWithContentViewController:shvc];
    [pc presentPopoverFromRect:historyButton.frame inView:historyButton.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

//- (void)displayStats:(Statistics *)stats {
//    [self showStats:stats.rightNotes wrongNotes:stats.wrongNotes skippedNotes:stats.skippedNotes noteOnTime:stats.notesPlayedOnTime accuracy:stats.tempoAccuracy];
//}

- (void)viewDidLoad
{
    self.scoreBackground    .alpha = 0;
    self.thisScore.layer.shadowOpacity = 1;
    self.thisScore.layer.shadowRadius = 10;
    self.thisScore  .layer.shadowColor = [UIColor whiteColor].CGColor;
    self.thisScore.layer.shadowOffset = CGSizeMake(0,0);
    [super viewDidLoad];
        _realBounds = self.view.bounds;
    [self setupLabels:12];
    theStatsViewController = self;
    
    self.tooEarlyView.backgroundColor = OverlayViewEarlyColorBold;
    self.tooLateView.backgroundColor = OverlayViewLateColorBold;
    self.missedView.backgroundColor = OverlayViewMissedColorBold;
    self.onTimeView.backgroundColor = OverlayViewOnTimeColorBold;
    
    UIImageView *iv = (UIImageView *)self.perfectView;
    iv.image = OverlayViewPerfectImage;
    CGRect frame = iv.frame;
    frame.size.height += 4;
    frame.origin.y -= 1;
    frame.size.width += 1;
    iv.frame = frame;
    
    self.tooEarlyView.layer.cornerRadius = 4;
    self.tooLateView.layer.cornerRadius = 4;
    self.missedView.layer.cornerRadius = 4;
    self.onTimeView.layer.cornerRadius = 4;
    
    self.scoreBackground.layer.cornerRadius = 8;

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
