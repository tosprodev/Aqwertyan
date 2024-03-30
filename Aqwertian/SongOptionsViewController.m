//
//  SongOptionsViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "SongOptionsViewController.h"
#import "InputHandler.h"
#import "ChannelsView.h"
#import "AudioPlayer.h"
#import "PerformanceViewController.h"
#import "SongOptions.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import "StoreViewController.h"
#import "LibraryManager.h"
#import "KSCustomPopoverBackgroundView.h"

@interface SongOptionsViewController () {

    IBOutlet ChannelsView *theChannelsView;

    BOOL failed;
    UIImageView *helpView;
}

@property (nonatomic) IBOutlet UILabel *titleLabel, *performLabel, *optionsLabel;
@property (nonatomic) IBOutlet UIButton *chordingButton, *exmatchButton, *pianoButton, *backButton, *performButton, *optionsButton;



- (IBAction)goBack:(id)sender;
- (IBAction)optionPressed:(id)sender;
- (IBAction)apply:(id)sender;
- (IBAction)showHelp:(id)sender;

@end

SongOptionsViewController *theSongOptionsViewController;

@implementation SongOptionsViewController {
    IBOutlet UIButton *theSongTitleButton;
    NSMutableArray *programs;

    NSString *theMidiFile;
    NSArray *theChannels;
    
    MBProgressHUD *melodyTrackHUD;
}

////
# pragma mark - INIT
//

+ (SongOptionsViewController *)sharedController {
    return  theSongOptionsViewController;
}

#define _ARR_VIEWED_KEY @"ArrangementFirstView6"
- (BOOL) isFirstView {
    if (self.isForStore) return NO;
    return [[NSUserDefaults standardUserDefaults] objectForKey:_ARR_VIEWED_KEY] == nil;
}

- (void) setFirstView {
    if (self.isForStore) return;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:_ARR_VIEWED_KEY];
}

- (void) loadFromSongOptions {
    self.keyboardType = [SongOptions keyboardType];
    self.chorded = [SongOptions isChorded];
    self.twoRow = [SongOptions isTwoRow];
    self.exmatch = [SongOptions isExmatch];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
   
    theSongOptionsViewController = self;
       return self;
}

- (void) revertOptions {
    [SongOptions setKeyboardType:self.keyboardType];
    [SongOptions setChorded:self.chorded];
    [SongOptions setExmatch:self.exmatch];
    [SongOptions setTwoRow:self.twoRow];
}

# pragma mark - path
- (BOOL)pathPressed:(int)screen {
    
    
    switch (screen) {
        case PERFORMANCE:
            if (self.isForStore) {
                [self goBack:nil];
                double delayInSeconds = 0.7;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[StoreViewController sharedController] pathPressed:PERFORMANCE];
                });
            } else {
                [self revertOptions];
                [[PerformanceViewController sharedController] dismissSongOptions];
            }
            break;
        case OPTIONS:
            if (self.isForStore) {
                [self goBack:nil];
                double delayInSeconds = 0.7;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[StoreViewController sharedController] pathPressed:OPTIONS];
                });
            } else {
            [[PerformanceViewController sharedController] dismissSongOptions];
            [[PerformanceViewController sharedController] performSelector:@selector(showOptions) withObject:nil afterDelay:0.75];
            }
            break;
        case ARRANGEMENT:
            return NO;
            break;
        case STORE:
            if (self.isForStore) {
                [self goBack:nil];
              
            } else {
                [[PerformanceViewController sharedController] dismissSongOptions];
                [[PerformanceViewController sharedController] performSelector:@selector(showStore) withObject:nil afterDelay:0.75];
            }
            
            break;
        case LIBRARY:
            if (self.isForStore) {
                [self goBack:nil];
                double delayInSeconds = 0.7;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[StoreViewController sharedController] pathPressed:LIBRARY];
                });
            } else {
            [[PerformanceViewController sharedController] dismissSongOptions];
            [[PerformanceViewController sharedController] performSelector:@selector(showLibrary) withObject:nil afterDelay:0.75];
            }
            break;
        case INSTRUMENTS:
            if (self.isForStore) {
                [self goBack:nil];
                double delayInSeconds = 0.7;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[StoreViewController sharedController] pathPressed:INSTRUMENTS];
                });
            } else {
            [[PerformanceViewController sharedController] dismissSongOptions];
            [[PerformanceViewController sharedController] performSelector:@selector(showInstruments) withObject:nil afterDelay:0.75];
            }
            break;
        case COLLAB:
            return NO;
            break;
        case USER_GUIDE:
            if (self.isForStore) {
                [self goBack:nil];
                double delayInSeconds = 0.7;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[StoreViewController sharedController] pathPressed:USER_GUIDE];
                });
            } else {
                [[PerformanceViewController sharedController] dismissSongOptions];
                [[PerformanceViewController sharedController] performSelector:@selector(showGuide) withObject:nil afterDelay:0.75];
            }
            break;
            break;
            
        default:
            return nil;
            break;
    }
    return YES;
}


////
# pragma mark - VIEW CONTROLLER
//

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFromSongOptions];
    [self displaySong];
    [AudioPlayer sharedPlayer].sendToChannelsView = YES;
    [AudioPlayer sharedPlayer].sendToInputHandler = NO;
    if (self.isForStore) {
        _backButton.hidden = NO;
        _pianoButton.hidden = _chordingButton.hidden = _exmatchButton.hidden = YES;
        _optionsButton.hidden = _optionsLabel.hidden = YES;
      //  _performButton.hidden = YES;
        _performLabel.text = @"TRANSLATE";
    } else {
        _backButton.hidden = YES;
        _pianoButton.hidden = _chordingButton.hidden = _exmatchButton.hidden = NO;
        _optionsButton.hidden = _optionsLabel.hidden = NO;
        _performLabel.text = @"PERFORM";
    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    NSLog(@"loaded");
    [_exmatchButton addTarget:self action:@selector(logOptionTapped:) forControlEvents:UIControlEventTouchDown];
    [_chordingButton addTarget:self action:@selector(logOptionTapped:) forControlEvents:UIControlEventTouchDown];
    [_pianoButton addTarget:self action:@selector(logOptionTapped:) forControlEvents:UIControlEventTouchDown];
}

- (void) logOptionTapped:(id)sender {
    [NZEvents logEvent:@"Performance option selected"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[AudioPlayer sharedPlayer] setVolume:[AudioPlayer sharedPlayer].maxVolume];
    [AudioPlayer sharedPlayer].sendToChannelsView = NO;
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(playTapped:) object:nil];
}

////
# pragma mark - DISPLAYING OPTIONS
//

- (void)optionPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}

- (NSString *)songToPlay {
    if (self.isForStore) {
        return self.songPath;
    } else {
    if ([SongOptions CurrentItem]) {
    return [[Util uploadedSongsDirectory] stringByAppendingPathComponent:[SongOptions CurrentItem].Arrangement.MidiFile];
    }
    }
    return nil;
}

- (void) displaySong {
    failed=NO;
    if (self.isForStore) {
        theChannels = [[InputHandler getTracks:self.songPath] lastObject];
        [_titleLabel setText:[[self.songPath lastPathComponent] stringByDeletingPathExtension]];
        
        if (theChannels.count) {
            failed=NO;
            for (Channel *c in theChannels) {
                c.Active = CH_ACCOMP;
            }
            BOOL found = NO;
//            int track = [LibraryManager melodyTrackForMidiFile:self.songPath isChannel:<#(BOOL *)#>];
//            
//            if (track >= 0) {              
//                for (Channel *c in theChannels) {
//                    if (c.Track == track) {
//                        [c setActive:CH_ACTIVE];
//                        found = YES;
//                        break;
//                    }
//                }
//            }
            if (!found) {
                [(Channel *)theChannels[0] setActive:CH_ACTIVE];
            }
        } else {
            failed=YES;
        }

      //  [[AudioPlayer sharedPlayer] setMidiFile:self.songPath];
         [theChannelsView displayChannels:theChannels];
        
       // [self displayDifficultyOptions];

        
    } else if ([SongOptions CurrentItem] == nil) {
        
    } else {
        [_titleLabel setText:[SongOptions CurrentItem].Title];
        if ([[SongOptions CurrentItem].Arrangement isInitialized]) {
            failed=NO;
          
            theChannels = [Channel copyArray:[SongOptions CurrentItem].Arrangement.Channels];
            //  [self performSelector:@selector(loadMelodyTrack) withObject:nil afterDelay:0.1];
//            BOOL found = NO;
//            int track = [LibraryManager melodyTrackForMidiFile:[SongOptions CurrentItem].Arrangement.MidiFile];
//            
//            if (track >= 0) {
//                for (Channel *c in theChannels) {
//                    [c setActive:CH_ACCOMP];
//                }
//                for (Channel *c in theChannels) {
//                    if (c.Track == track) {
//                        [c setActive:CH_ACTIVE];
//                        break;
//                    }
//                }
//                if (!found) {
//                    [(Channel *)theChannels[0] setActive:CH_ACTIVE];
//                }
//            } else {
//                [self loadMelodyTrack];
//            }
            
        } else {
              [SongOptions CurrentItem].Arrangement.Chorded = YES;
            theChannels = [[InputHandler getTracks:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:[SongOptions MidiFile]]] lastObject];
            if (theChannels.count) {
                failed=NO;
                for (Channel *c in theChannels) {
                    c.Active = CH_ACCOMP;
                }
                
                BOOL found = NO;
         
     
                [(Channel *)theChannels[0] setActive:CH_ACTIVE];
                //if (![SongOptions CurrentItem].Arrangement.isInitialized) {
                 [self performSelector:@selector(loadMelodyTrack) withObject:nil afterDelay:0.1];
                //}
            } else {
                failed=YES;
            }
        }

        
        if (!failed) {


        }
        [theChannelsView displayChannels:theChannels];
        [self displayDifficultyOptions];
    }
    
    
}

- (void) loadMelodyTrack {
    if (!self.isForStore) {
        NSString *file = [self songToPlay];
        BOOL channel = NO;
        int track = [LibraryManager melodyTrackForMidiFile:file isChannel:&channel];
        if (track >= 0) {
            [theChannelsView setMelodyTrack:track isChannel:channel];
        } else {
            if (track != -1) {
                [self showGettingMelodyTrackHUD];
                
                __weak NSArray *channels = theChannels;
                __weak id this = self;
                __weak ChannelsView *channelsView = theChannelsView;
                [LibraryManager getMelodyTrackForMidiFile:[self songToPlay] completion:^(int track, BOOL isChannel) {
                    if (this) {
                        [this hideGettingMelodyTrackHUD:(track > -1 ? nil : @"Could not determine melody track")];
                        if (track >= 0) {
                            // [channelsView setActiveTrack:track isChannel:isChannel];
                            [channelsView setMelodyTrack:track isChannel:isChannel];
                        }
                    }
                }];
            }
        }
    }
}

- (void) showGettingMelodyTrackHUD {
    [melodyTrackHUD hide:NO];
    melodyTrackHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    melodyTrackHUD  .userInteractionEnabled = NO;
    melodyTrackHUD  .labelText = @"Determining melody track...";
    melodyTrackHUD.mode = MBProgressHUDModeText;
    melodyTrackHUD  .yOffset = -300;
    double delayInSeconds = .001;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGRect frame = melodyTrackHUD.frame;
        CGPoint center = melodyTrackHUD.center;
        frame.size.height -= 20;
        melodyTrackHUD.frame = frame;
        melodyTrackHUD.center = center;
    });

}

- (void) hideGettingMelodyTrackHUD:(NSString *)error {
    if (error) {
        melodyTrackHUD.labelText = error;
        melodyTrackHUD.labelTextColor = [UIColor redColor];
        [melodyTrackHUD hide:YES afterDelay:2.5];
    } else {
        [melodyTrackHUD hide:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NZEvents stopTimedFlurryEvent:@"Arrangement screen opened"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     [NZEvents startTimedFlurryEvent:@"Arrangement screen opened"];
    
    if (failed) {
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"This midi file is invalid." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        
//        if ([self isFirstView] && [SongOptions CurrentItem]) {
//            [self presentHelp];
//            
//        } else {
            [self performSelector:@selector(playTapped:) withObject:nil afterDelay:.5];
 //       }
    }
    
    failed=NO;
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}

- (void) displayDifficultyOptions {
    _pianoButton.selected = [SongOptions keyboardType] == KeyboardTypeFullPiano;
    _chordingButton.selected = [SongOptions isChorded];
    _exmatchButton.selected = [SongOptions isExmatch];
}

////
# pragma mark - IBACTIONS
//

- (void)apply:(id)sender {
    if (self.isForStore) {
        [[StoreViewController sharedController] importTapped:nil];
        [self goBack:nil];
        return;
    }
    if ([SongOptions CurrentItem]) {
        if ([SongOptions CurrentItem].Type != LibraryItemTypeRecording) {
//            [SongOptions setChorded:_chordingButton.selected];
//            [SongOptions setExmatch:_exmatchButton.selected];
//            if (_pianoButton.selected) {
//                [SongOptions setKeyboardType:KeyboardTypeFullPiano];
//            } else {
//                [SongOptions setKeyboardType:KeyboardTypeFullQwerty];
//            }
//            [SongOptions setKeyboardType:self.keyboardType];
//            [SongOptions setChorded:self.chorded];
//            [SongOptions setExmatch:self.exmatch];
//            [SongOptions setTwoRow:self.twoRow];
            [SongOptions setChannels:theChannels];
            [[PerformanceViewController sharedController] loadCurrentSong];
        }
        [NZEvents logEvent:@"New arrangement created" args:@{@"Song": [SongOptions CurrentItem].Title}];
    }
    
    [self goBack:nil];
}

- (void)goBack:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
   // [self.navigationController popViewControllerAnimated:YES];
    if (!self.isForStore)
    [[PerformanceViewController sharedController] dismissSongOptions];
   // [[PerformanceViewController sharedController] dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showHelp:(id)sender {
    [NZEvents logEvent:@"Arrangement help shown"];
    [self presentHelp];
    
}

- (void) presentHelp {
    if (!helpView) {
        
        helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-arrangement.png"]];
        
        [helpView sizeToFit];
        [helpView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHelp)]];
        helpView.userInteractionEnabled = YES;
    }
    [self.view addSubview:helpView];
    helpView.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.01];
    [UIView setAnimationDuration:0.5];
    helpView.alpha = 1;
    [UIView commitAnimations];
}

//- (void) showSecondHelp {
//    helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-arrangement-2.png"]];
//    
//    [helpView sizeToFit];
//    [helpView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSecondHelp)]];
//    helpView.userInteractionEnabled = YES;
//    
//    [self.view addSubview:helpView];
//    helpView.alpha = 0;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelay:0.01];
//    [UIView setAnimationDuration:0.5];
//    helpView.alpha = 1;
//    [UIView commitAnimations];
//}
//
//- (void) hideSecondHelp {
//    [UIView transitionWithView:helpView duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^(void) {
//        helpView.alpha = 0;
//    }completion:^(BOOL finished ) {
//        [helpView removeFromSuperview];
//        helpView = nil;
//         [self playTapped:nil];
//    }];
//   
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ArrangementOptions"]) {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        popoverSegue.popoverController.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
    }
}

- (void) hideHelp {
    [UIView transitionWithView:helpView duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^(void) {
        helpView.alpha = 0;
    }completion:^(BOOL finished ) {
        [helpView removeFromSuperview];
        helpView = nil;
    }];
}

@end
