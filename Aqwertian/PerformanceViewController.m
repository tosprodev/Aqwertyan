//
//  ViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/2/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "PerformanceViewController.h"
#import "AudioPlayer.h"
#import "MusFileManager.h"
//#import "InputHandler.h"
//#import "NotationDisplay.h"
#import "KeyboardView.h"
#import "SongSelectionController.h"
#import "RotatingNamePlate.h"
#import "Aqwertian.h"
//#import "ConvertTest.h"
#import "Conversions.h"
#import "SongOptions.h"
#import "Arrangement.h"
#import "LibraryManager.h"
#import "Util.h"
#import "MicrophoneManager.h"
#import "NZInputHandler.h"
#import "NZNotationDisplay.h"
#import "ACMagnifyingGlass.h"
#import "ACMagnifyingView.h"
#import "MBProgressHUD.h"
#import "StatsViewController.h"
#import "SettingsViewController.h"
#import "ChannelView.h"
#import "SongOptionsViewController.h"
#import <Social/Social.h>
#import "NZEvents.h"
#import "KSCustomPopoverBackgroundView.h"
#import "IntroViewController.h"
#import "NSObject+NZHelpers.h"
#define SONG_LOAD_COUNT @"SongLoadCount3"
#define TIP_SHOWN @"TipShown2"
#import "StatsMailer.h"

PerformanceViewController *theViewController = nil;


@interface PerformanceViewController () {
    IBOutlet UISlider *tempoSlider;
    IBOutlet UIView *midiLight, *outLight;
    IBOutlet UISwitch *recordSwitch;
    LibraryItem *lastItem;
    IBOutlet UILabel *countdownLabel;
    IBOutlet UIView *metronomeView;
    BOOL _wantsPianoKeyboard;
    int countdown;
    int currentTime;
    BOOL wasAutoplaying;
    UITextField *hiddenTextView;
    BOOL keyboardShown;
    IBOutlet UISlider *volumeSlider;
    IBOutlet UISlider *userVolSlider;
    IBOutlet UISwitch *lyricsSwitch;
    IBOutlet UIImageView *lyricsImageView;
    IBOutlet UILabel *lyricsLabel, *instrumentLabel, *currentTimeLabel, *totalTimeLabel;
    IBOutlet UITextView *textView;
    IBOutlet UIView *pathView;
    IBOutlet UIImageView *rightCover, *leftCover;
    IBOutlet UIImageView *micImage, *midiInImage, *midiOutImage;
    IBOutlet UILabel *shareButtonLabel;
    IBOutlet UIView *controlPanelView;
    UIPopoverController *arrangementOptionsPopover;
    BOOL inThumbMode;
    BOOL introShown;
    IBOutlet UISlider *progressSlider;
    int originalWaitTicks;
    NSTimer *progressTimer;
    
    BOOL isSongLoading;
    
    IBOutlet UIView *pitchBendView;
    NSTimer *waitingTimer;
    UIView *statsBG;
    int waitingTicks;
    MBProgressHUD *waitingHUD;
    MBProgressHUD *countDownHUD;
    NSTimer *countdownTimer;
    NSString *previewPath;
    UIImageView *helpView;
    BOOL previewForStore;
    UIView *statsView;
    IBOutlet UIButton *pathButton, *restartButton, *autoplayButton, *nextButton, *previousButton, *keyUpButton, *keyDownButton, *playButton, *shareButton, *OKButton, *fullStatsButton;
    UIViewController *songOptionsVC, *storeVC;
    BOOL didPause;
    UIActionSheet *actionSheet;
    BOOL loaded;
    BOOL alertShown;
    BOOL didLogAppearance;
    BOOL storeShown, arrangementShown;
    
}

@property  IBOutletCollection(UIView) NSArray *controlButtons;

- (IBAction)changeProgram:(id)sender;
- (IBAction)mic:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)showMeasures:(id)sender;
- (IBAction)split:(id)sender;
- (IBAction)selectSong:(id)sender;
- (IBAction)showNowLine:(id)sender;
- (IBAction)autoPlay:(id)sender;
- (IBAction)switchYah:(id)sender;
- (IBAction)saveArrangement:(id)sender;
- (IBAction)muteBand:(id)sender;
- (IBAction)volume:(id)sender;
- (IBAction)tempo:(id)sender;
- (IBAction)toggleVelocity:(id)sender;
- (IBAction)toggleRecord:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)jumpToMeasure:(id)sender;
- (IBAction)startPause:(id)sender;
- (IBAction)lyrics:(id)sender;
- (IBAction)userVol:(id)sender;
- (IBAction)path:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)showStats:(id)sender;
- (IBAction)keyUp:(id)sender;
- (IBAction)keyDown:(id)sender;
- (IBAction)selectInstrument:(id)sender;
- (IBAction)arrangementShortcut:(id)sender;
- (IBAction)optionsShortcut:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)OK:(id)sender;
- (IBAction)boost:(id)sender;
- (IBAction)boostOff:(id)sender;
- (IBAction)panic:(id)sender;

- (IBAction)store:(id)sender;
- (IBAction)library:(id)sender;
-  (IBAction)songOptions:(id)sender;

@end

@implementation PerformanceViewController {
    NSInteger program;
    IBOutlet UILabel *theProgramLabel;
    //   IBOutlet NotationDisplay *theNotationDisplay;
    IBOutlet NZNotationDisplay *nzDisplay;
    IBOutlet KeyboardView *theKeyboard;
    UIPopoverController *thePopover;
    SongSelectionController *theSongSelectionController;
    IBOutlet RotatingNamePlate *theNamePlate;
    IBOutlet UIButton *theLeftButton, *theRightButton;
    //bool autoplaying;
    NZInputHandler *_inputHandler;
    AudioPlayer *player;
    BOOL waiting;
    CFTimeInterval lastTime[256];
    char onKeys[256];
    int nKeysOn;
    BOOL didPause;
}

////
#pragma mark - INIT
//

+ (PerformanceViewController *)sharedController {
    return theViewController;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    return self;
}

////
#pragma mark - VIEW CONTROLLER
//

- (void)boost:(id)sender {
    if (waiting || ![SongOptions CurrentItem]) return;
    [NZInputHandler sharedHandler].autoplaying = YES;
}

- (void)boostOff:(id)sender {
    [NZInputHandler sharedHandler].autoplaying = NO;
}

- (void)optionsShortcut:(id)sender {
    [NZEvents logEvent:@"Options shortcut tapped"];
    [self pathPressed:OPTIONS];
}

- (void)arrangementShortcut:(id)sender {
    [NZEvents logEvent:@"Arrangement shortcut tapped"];
    [self pathPressed:ARRANGEMENT];
}

- (void)share:(id)sender {
    if (!ios5) {
        [self showActionSheet];
    }
}

- (void)OK:(id)sender {
    [self restartSong];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning");
}

- (void) showActionSheet {
    [[StatsMailer instance] showActionSheetFromRect:shareButton.frame inView:shareButton.superview forScreenshot:[NZNotationDisplay sharedDisplay].statsDisplay withFrame:CGRectZero forViewController:self];
    
//    actionSheet = [[UIActionSheet alloc] initWithTitle: nil
//                                              delegate: self
//                                     cancelButtonTitle: nil
//                                destructiveButtonTitle: nil
//                                     otherButtonTitles: @"Email", @"Twitter", @"Facebook", nil];
//    
//    
//    
//    
//    [actionSheet showFromRect: shareButton.frame inView:shareButton.superview animated: YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == -1) return;
    
    [NZEvents logEvent:@"Performance score shared on social network" args:@{@"Type" : buttonIndex == 0 ? @"Email" : (buttonIndex == 1 ? @"Twitter" : @"Facebook")}];
    if (buttonIndex == 0) {
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *title = [SongOptions CurrentItem].Title; //componentsSeparatedByString:@" ("][0];
            
            Statistics *s = [[SongOptions currentStats] count] ? [SongOptions currentStats][0] : nil;
            NSString *message;
            
            if (s) {
                float totalNotes = s.skippedNotes + s.rightNotes;
                float accuracy = 100.0 * (float)(s.rightNotes) / (float)(s.rightNotes +s.wrongNotes);
                float onTime = 100.0 * (float)s.notesPlayedOnTime / totalNotes;
                
               // if ([SongOptions isExmatch]) {
                    message = [NSString stringWithFormat:@"I just scored %d on %@!", s.totalScore, title];
            //    } else {
              //      message = [NSString stringWithFormat:@"I just played %@!<br />Tempo Accuracy: %d%%", title, (int)(onTime+0.5)];
              //  }
            } else {
                title = message = [NSString stringWithFormat:@"I just played %@!", title];
            }
            
            LibraryItem *item = [SongOptions CurrentItem];
            item.Arrangement.fileData = [NSData dataWithContentsOfFile:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile]];
            
           
            NSMutableDictionary *dict = [item toDictionary].mutableCopy;
            dict[@"Jukebox"] = @(NO);
            dict[@"Favorite"] = @(NO);
            if (item.Type != LibraryItemTypeArrangement) {
                dict[@"Title"] = [item.Title stringByAppendingFormat:@" (%@)", instrumentLabel.text];
                dict[@"Type"] = @(LibraryItemTypeArrangement);
            }
            
            NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * fileName = [item.Title stringByAppendingString:@".aqw"];

            
            
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            [mailer addAttachmentData:data mimeType:@"application/octet-stream" fileName:fileName];
            [mailer setSubject:[NSString stringWithFormat:@"Check out my performance stats for %@", [SongOptions CurrentItem].Title]];
            
            
            NSString *emailBody = [message stringByAppendingString:@"<br /><br /><a href=\"http://itunes.apple.com/app/id584106288\">Aqwertyan for iPad</a>"];
            
            StatsDisplay *sd = [NZNotationDisplay sharedDisplay].statsDisplay;

            NSData *imageData = UIImagePNGRepresentation([self snapshotFromView:sd]);

            
            [mailer  addAttachmentData:imageData mimeType:@"image/png" fileName:@"CameraImage"];
            [mailer setMessageBody:emailBody isHTML:YES];
            [self presentViewController:mailer animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:@"Your device doesn't support sending email from within the app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    } else {
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:buttonIndex == 1 ? SLServiceTypeTwitter : SLServiceTypeFacebook];
        // Configure Compose View Controller
        NSString *title = [SongOptions CurrentItem].Title; //componentsSeparatedByString:@" ("][0];
        
        Statistics *s = [[SongOptions currentStats] count] ? [SongOptions currentStats][0] : nil;
        NSString *message;
        
        if (s) {
            float totalNotes = s.skippedNotes + s.rightNotes;
            float accuracy = 100.0 * (float)(s.rightNotes) / (float)(s.rightNotes +s.wrongNotes);
            float onTime = 100.0 * (float)s.notesPlayedOnTime / totalNotes;
            
           // if ([SongOptions isExmatch]) {
                message = [NSString stringWithFormat:@"I just scored %d on played %@!\nAqwertyan for iPad!", s.totalScore, title];
//            } else {
//                message = [NSString stringWithFormat:@"I just played %@ with %d%% tempo accuracy on Aqwertyan for iPad!", title, (int)(onTime+0.5)];
//            }
        } else {
            title = message = [NSString stringWithFormat:@"I just played %@ on Aqwertyan for iPad!", title];
        }
        
        [vc setInitialText:message];
        
        // [vc setInitialText:[NSString stringWithFormat:@"I'm playing %@ on Aqwertyan for iPad!", title]];
        [vc addURL:[NSURL URLWithString:@"http://www.aqwertyan.com"]];
        
        // Present Compose View Controller
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}

- (UIImage *)snapshotFromView:(UIView *)view
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect texRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));
    
    UIGraphicsBeginImageContextWithOptions(texRect.size, YES, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)willResignActive {
    [_inputHandler pause];
    playButton.selected = NO;
}

- (void)path:(id)sender {
    
    //    UIButton *button = pathButton;
    ////    if(button.selected)
    ////    {
    ////        [button setImage:[UIImage imageNamed:@"path.png"] forState:UIControlStateHighlighted];
    ////        [button setImage:[UIImage imageNamed:@"path.png"] forState:UIControlStateSelected];
    ////        [button setImage:[UIImage imageNamed:@"path.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    ////    }
    ////    else
    ////    {
    ////        [button setImage:[UIImage imageNamed:@"path-pressed.png"] forState:UIControlStateHighlighted];
    ////        [button setImage:[UIImage imageNamed:@"path-pressed.png"] forState:UIControlStateSelected];
    ////        [button setImage:[UIImage imageNamed:@"path-pressed.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    ////    }
    ////    [UIView transitionWithView:button
    ////                      duration:0.15
    ////                       options:UIViewAnimationOptionTransitionCrossDissolve
    ////                    animations:^{ }
    ////                    completion:nil];
    //    button.selected = !button.selected;
    //
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:0.2];
    //    if (button.selected) {
    //        pathView.alpha=1;
    //      //  [button setImage:[UIImage imageNamed:@"path-pressed.png"] forState:UIControlStateNormal];
    //    } else {
    //        pathView.alpha=0;
    //      //  [button setImage:[UIImage imageNamed:@"path.png"] forState:UIControlStateNormal];
    //    }
    //    [UIView commitAnimations];
    
}

- (void)keyDown:(id)sender {
   // _inputHandler.key--;
    _inputHandler.rewinding = !_inputHandler.rewinding;
    if (!_inputHandler.rewinding) {
        [[AudioPlayer sharedPlayer] attenuate:0.65];
    }
}

- (void)keyUp:(id)sender {
   // _inputHandler.key++;
    _inputHandler.fastForwarding = !_inputHandler.fastForwarding;
    if (!_inputHandler.fastForwarding) {
        [[AudioPlayer sharedPlayer] attenuate:0.65];
    }
}

- (void)userVol:(id)sender {
    [NZInputHandler sharedHandler].volumeMultiplier = userVolSlider.value;
}

- (void)performanceDidStart {
    playButton.selected=YES;
}

- (void)showStats:(id)sender {
    if (!statsBG) {
        statsBG = [UIView new];
        statsBG.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        statsBG.frame = self.view.frame;
    }
    [self.view addSubview:statsBG];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Stats"];
    [self.view addSubview:vc.view];
    statsView = vc.view;
    __block CGRect frame = vc.view.frame;
    [self.view addSubview:vc.view];
    frame.origin.y = 768;
    // frame.origin.x = 200;//(1024 - vc.view.frame.size.width)/2;
    vc.view.frame = frame;
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^(void){
        frame.origin.y = 0;
        vc.view.frame = frame;
        statsBG.alpha = 1;
    } completion:nil];
    //  [self performSegueWithIdentifier:@"Stats" sender:nil];

}

- (void)dismissStats {
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^(void) {
        statsBG.alpha = 0;
        CGRect frame = statsView.frame;
        frame.origin.y = 768;
        statsView.frame = frame;
        
    } completion:^(BOOL finished) {
        [statsBG removeFromSuperview];
        [statsView removeFromSuperview];
        statsView = nil;
    }];
}

- (void)keyboardWillAppear:(NSNotification *)aNotification {
    keyboardShown = YES;
    [hiddenTextView performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.01];
}

- (void)keyboardWillDisappear:(NSNotification *)aNotification {
    keyboardShown = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    string = [string uppercaseString];
    for (int i = 0; i < string.length; i++) {
        [self handleKeyboardInput:[string characterAtIndex:i]];
    }
    return NO;
}

- (void) handleKeyboardInput:(char)c {
    CFTimeInterval now = CACurrentMediaTime();
    
    CFTimeInterval diff = now - lastTime[c];
    if (ABS(diff - 0.4) < 0.01) {
        lastTime[c] = now;
        return;
        //  NSLog(@"rejected");
    } else if (ABS(diff - 0.1) < 0.01) {
        lastTime[c] = now;
        return;
        //  NSLog(@"rejected");
    }
    
    // NSLog(@"%c %f", c, now - lastTime[c]);
    lastTime[c] = now;
    if ([_inputHandler handleNoteOn:c velocity:-1 autoOff:YES andHandleKey:YES]) {
        //[[KeyboardView sharedView] noteOn:c];
    }
}

- (void) regainKeyboardControl {
    [hiddenTextView becomeFirstResponder];
}

- (void)showHelp:(id)sender {
    [self presentHelp];
    [NZEvents startTimedFlurryEvent:@"Performance help shown"];
    
}

- (void) presentHelp {
    if (!helpView) {
        helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-performance.png"]];
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

- (void) hideHelp {
    [UIView transitionWithView:helpView duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^(void) {
        helpView.alpha = 0;
    } completion:^(BOOL finished ) {
        [helpView removeFromSuperview];
        helpView = nil;
    }];
    [NZEvents stopTimedFlurryEvent:@"Performance help shown"];
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    metronomeView.layer.cornerRadius = metronomeView.frame.size.width/2;
    _showLyrics = YES;
    [SongOptions setVolume:10];
    
    if (!NSClassFromString(@"SLComposeViewController")) {
        shareButton.hidden = shareButtonLabel.hidden = YES;
    }
    
    [progressSlider addTarget:self action:@selector(progressSliderMoves:) forControlEvents:UIControlEventValueChanged];
    [progressSlider addTarget:self action:@selector(progressSliderDone) forControlEvents:(UIControlEventTouchCancel | UIControlEventTouchUpOutside | UIControlEventTouchUpInside)];
    
    
    UIImage *normal = [[UIImage imageNamed:@"ev-button-big"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    UIImage *highlighted = [[UIImage imageNamed:@"ev-button-big-pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    
    [shareButton setImage:normal forState:UIControlStateNormal];
    [OKButton setImage:normal forState:UIControlStateNormal];
    [fullStatsButton setImage:normal forState:UIControlStateNormal];
    [shareButton setImage:highlighted forState:UIControlStateHighlighted];
    [OKButton setImage:highlighted forState:UIControlStateHighlighted];
    [fullStatsButton setImage:highlighted forState:UIControlStateHighlighted];
    
    UIImage *thumb = [UIImage imageNamed:@"slider-handle.png"];
    
    // [pathButton setBackgroundImage:[UIImage imageNamed:@"path-pressed.png"] forState:UIControlStateSelected|UIControlStateHighlighted ];
    
    volumeSlider.transform = tempoSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [tempoSlider setThumbImage:thumb forState:UIControlStateNormal];
    [tempoSlider setMinimumTrackImage:[UIImage imageNamed:@"slider-fill-vertical.png"] forState:UIControlStateNormal];
    [tempoSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    
    [volumeSlider setThumbImage:thumb forState:UIControlStateNormal];
    [volumeSlider setMinimumTrackImage:[UIImage imageNamed:@"slider-fill-vertical.png"] forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    
    thumb = [UIImage imageNamed:@"seek-slider-handle.png"];
    [progressSlider setThumbImage:thumb forState:UIControlStateNormal];
   // [progressSlider setMinimumTrackImage:[UIImage imageNamed:@"slider-fill-vertical.png"] forState:UIControlStateNormal];
   // [progressSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
       currentTime = -1;
    
    lyricsImageView.image = [[UIImage imageNamed:@"lyrics-full.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(45, 45, 45, 45)];
    
    volumeSlider.minimumValue = [AudioPlayer sharedPlayer].minVolume;
    volumeSlider.maximumValue = [AudioPlayer sharedPlayer].maxVolume;
    volumeSlider.value = [AudioPlayer sharedPlayer].volume;
    
    
    
    hiddenTextView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    hiddenTextView.text = @"aa";
    hiddenTextView.delegate = self;
    [self.view addSubview:hiddenTextView];
    
    
    _inputHandler = [NZInputHandler sharedHandler];
    __weak UIView *weakMetronomeView = metronomeView;
    [_inputHandler setMetronomeTickHandler:^(void) {
        weakMetronomeView.hidden = NO;
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakMetronomeView.hidden = YES;
        });
    }];
    metronomeView.hidden = YES;
    [_inputHandler addObserver:self forKeyPath:@"isPaused" options:NSKeyValueChangeNewKey context:nil];
    [_inputHandler addObserver:self forKeyPath:@"fastForwarding" options:NSKeyValueChangeNewKey context:nil];
    [_inputHandler addObserver:self forKeyPath:@"rewinding" options:NSKeyValueChangeNewKey context:nil];
    [_inputHandler addObserver:self forKeyPath:@"autoplaying" options:NSKeyValueChangeNewKey context:nil];
    theViewController = self;
    self.navigationController.navigationBarHidden = YES;
    
    [ExternalMIDIManager sharedManager].Delegate = self;
    [self connectionsChanged:[ExternalMIDIManager sharedManager] type:0 connection:nil];
    midiLight.layer.cornerRadius = outLight.layer.cornerRadius = midiLight.frame.size.width/2;
    midiLight.layer.shadowOffset = outLight.layer.shadowOffset = CGSizeMake(0,2);
    midiLight.layer.shadowOpacity = outLight.layer.shadowOpacity = 1;
    midiLight.layer.shadowPath = outLight.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:midiLight.bounds cornerRadius:midiLight.layer.cornerRadius].CGPath;
    midiLight.backgroundColor = [[ExternalMIDIManager sharedManager] hasSource] ? [UIColor greenColor] : [UIColor darkGrayColor];
    outLight.backgroundColor = [[ExternalMIDIManager sharedManager] hasDestination] ? [UIColor blueColor] : [UIColor darkGrayColor];
    //[theNotationDisplay addShadow];
    [nzDisplay setupLayout];

    [theLeftButton setBackgroundImage:[UIImage imageNamed:@"key-arrow-left.png"] forState:UIControlStateNormal];
    [theLeftButton setBackgroundImage:[UIImage imageNamed:@"key-pressed-arrow-left.png"] forState:UIControlStateHighlighted];
    [theRightButton setBackgroundImage:[UIImage imageNamed:@"key-arrow-right.png"] forState:UIControlStateNormal];
    [theRightButton setBackgroundImage:[UIImage imageNamed:@"key-pressed-arrow-right.png"] forState:UIControlStateHighlighted];
    //   [InputHandler sharedHandler].NotationDisplay = theNotationDisplay;
    program = 0;
    //   [self updateProgram];
    
    // [self toggleRecord:recordSwitch];
    // [self setupMenu];
    
    player = [AudioPlayer sharedPlayer];
    
    //    tempoSlider.minimumValue = -200;
    //    tempoSlider.maximumValue = 200;
    //    tempoSlider.value = 0;
    
    countdownLabel = [UILabel new];
    countdownLabel.font = [UIFont boldSystemFontOfSize:200];
    countdownLabel.textAlignment = UITextAlignmentCenter;
    countdownLabel.backgroundColor = [UIColor clearColor];
    countdownLabel.textColor = [UIColor blueColor];
    [self.view addSubview:countdownLabel];
    [countdownLabel setFrame:CGRectMake(0, 0, 1024, 768)];
    double delayInSeconds = 0.01;
    
    [self updateProgram];
    [self setupTitle:NO];
    
    [SongOptions loadFromDefaults];

    
    [self.view bringSubviewToFront:leftCover];
    [self.view bringSubviewToFront:rightCover];
    [self.view bringSubviewToFront:volumeSlider];
    [self.view bringSubviewToFront:tempoSlider];
    // [self performSelector:@selector(addMagnifier) withObject:nil afterDelay:1];
    // [self performSelector:@selector(autoPlay:) withObject:nil afterDelay:3];
    
    static BOOL first = YES;
    if (first) {
        [SettingsViewController loadSavedSettings];
        //        if (![[NSUserDefaults standardUserDefaults] objectForKey:DONT_SHOW_QUICK_START_KEY]) {
        //
        //            UIViewController *qsvc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"QuickStart"];
        //
        //            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.001 * NSEC_PER_SEC));
        //            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //
        //                [self presentViewController:qsvc animated:NO completion:nil];
        //            });
        //        } else {
        //
        //        }
    }
    
    [SettingsViewController loadArrangementSettings:[SongOptions CurrentItem].Arrangement.settings];
    [self loadCurrentSong];
    volumeSlider.value = [AudioPlayer sharedPlayer].volume;
    first=NO;
    delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //  [self performSegueWithIdentifier:@"Like" sender:nil];
    });
    
    [self onEvent:@"IntroDismissed" do:^(id sender, id args) {
        if ([SongOptions CurrentItem] == nil && self.view.window) {
            [self performSegueWithIdentifier:@"HeadToTheLibrary" sender:nil];
        }
    }];
    
    loaded=YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isPaused"]) {
        playButton.selected = !_inputHandler.isPaused;
    } else if ([keyPath isEqualToString:@"fastForwarding"]) {
        keyUpButton.selected = _inputHandler.fastForwarding;
    } else if ([keyPath isEqualToString:@"rewinding"]) {
        keyDownButton.selected = _inputHandler.rewinding;
    } else if ([keyPath isEqualToString:@"autoplaying"]) {
        autoplayButton.selected = _inputHandler.autoplaying;
    }
}
- (void) progressSliderDone {
    [player attenuate:0.65];
}

- (BOOL)prefersStatusBarHidden  {
    return YES;
}

- (void) addMagnifier {
    //    ACMagnifyingGlass *glass = [[ACMagnifyingGlass alloc] initWithFrame:CGRectMake(0, 0, 150, nzDisplay.frame.size.height + 100)];
    // //   ((ACMagnifyingView *)self.view).magnifyingGlass = glass;
    //    glass.viewToMagnify = self.view;
    //    ACMagnifyingView *view = [[ACMagnifyingView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    //    [self.view addSubview:view];
    //   // glass.scaleAtTouchPoint=NO;
    //    view.magnifyingGlass = glass;
    ////    [self.view addSubview:glass];
    ////    glass.touchPointOffset = CGPointMake(0,0);
    ////    glass.userInteractionEnabled = NO;
    ////    glass.touchPoint = CGPointMake(self.view.frame.size.width/2 + glass.frame.size.width/2 + 140, nzDisplay.frame.origin.y + nzDisplay.frame.size.height/2);
    //    [glass setNeedsDisplay];
}

- (void) setupMenu {
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem5 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem6 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem7 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem8 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem9 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, starMenuItem5, starMenuItem6, starMenuItem7,starMenuItem8,starMenuItem9, nil];
    
    
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:menus];
    
	// customize menu
	/*
     menu.rotateAngle = M_PI/3;
     menu.menuWholeAngle = M_PI;
     menu.timeOffset = 0.2f;
     menu.farRadius = 180.0f;
     menu.endRadius = 100.0f;
     menu.nearRadius = 50.0f;
     */
	
    menu.delegate = self;
    menu.center = CGPointMake(735, 730);
    // [self.view addSubview:menu];
    
    
}

- (void)jumpToMeasure:(id)sender {
    //    Rb_node tmp;
    //    Piece *p = [InputHandler sharedHandler].PS->p;
    //    Measure *m;
    //    int i = 0;
    //    Play_state *m_PS = [InputHandler sharedHandler].PS;
    //
    //    m_PS->nnotes[0] = m_PS->nnotes[1] = 0;
    //    [[InputHandler sharedHandler] PlayMeasureStart];
    
    //    m_PS->m_ptr = rb_next(m_PS->m_ptr);
    //    if (m_PS->m_ptr == m_PS->p->measures) {
    //        m_PS->m = NULL;
    //    } else {
    //        m = (Measure *) m_PS->m_ptr->v.val;
    //        [[InputHandler sharedHandler] StartNewMeasure:m];  /* This sets m_PS->m */
    //    }
    
    //    rb_traverse(tmp, p->measures) {
    //        m = (Measure *) tmp->v.val;
    //        if (i ==1) {
    //            [[InputHandler sharedHandler] StartNewMeasure:m];
    //            return;
    //        }
    //        i++;
    //    }
}

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (storeShown) {
        [storeVC viewDidDisappear:animated];
    } else if (arrangementShown) {
        [songOptionsVC viewDidDisappear:animated];
    } else {
        [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(logShown) object:nil];
        if (didLogAppearance) {
            [NZEvents stopTimedFlurryEvent:@"Performance screen opened"];
        }
    }
}

- (void) logShown {
    didLogAppearance = YES;
    [NZEvents startTimedFlurryEvent:@"Performance screen opened"];
}

- (BOOL) shouldShowIntro {
    return [IntroViewController shouldShowIntro];
}

- (void) showIntro {
    [self performSegueWithIdentifier:@"Intro" sender:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    didLogAppearance = NO;
    [super viewDidAppear:animated];
    
    if ([self shouldShowIntro] && !introShown) {
        introShown = YES;
        [self showIntro];
    } else if ([IntroViewController shouldShowWhatsNew]) {
        [self showIntro];
    } else if (storeShown) {
       // [storeVC viewDidAppear:animated];
    } else if (arrangementShown) {
      //  [songOptionsVC viewDidAppear:animated];
    } else {
        [hiddenTextView becomeFirstResponder];
    if (keyboardShown) {
        [hiddenTextView resignFirstResponder];
        
    }
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(logShown) object:nil];
    [self performSelector:@selector(logShown) withObject:nil afterDelay:2];
    }
   
//
//    [[[UIAlertView alloc] initWithTitle:@"Contratulations!" message:@"You've successfully played your first song. That was an easy one. There are plenty more available in the Library, so head over and check them out! Later, you can use the Store to find your favorite songs online." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] performSelector:@selector(show) withObject:nil afterDelay:1];
//    
    
       double delayInSeconds = 2.0;
    //    if ([SongOptions CurrentItem] && _inputHandler.performanceMode == PERFORMANCE_USER_DRIVEN && _inputHandler.song) {
    //        [_inputHandler start];
    //        playButton.selected = YES;
    //    }
    
    // [theNotationDisplay showMeasures:YES];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)pathOpened {
    [_inputHandler pause];
    [self.view bringSubviewToFront:metronomeView];
}

////
# pragma mark - ARRANGEMENT SAVING
//

- (void)saveArrangement:(id)sender {
    [NZEvents logEvent:@"Save arrangement button tapped"];
    if ([SongOptions CurrentItem] == nil) {
        return;
    }
    [_inputHandler pause];
    playButton.selected=NO;
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Save Arrangement" message:@"Enter a name for this arrangement:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    theAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    NSString  *base;
    if ([SongOptions CurrentItem].Type != LibraryItemTypeArrangement) {
        base = [SongOptions CurrentItem].Title;
    } else {
        NSString *title= [SongOptions CurrentItem].Title;
        NSRange range = [title rangeOfString:@" ("];
        if (range.location != NSNotFound) {
            base = [title substringToIndex:range.location];
        } else {
            base = title;
        }
    }
    
    NSString *instrument = instrumentLabel.text;
//    for (Channel *channel in [SongOptions Channels]) {
//        if (channel.Active == CH_ACTIVE) {
//            instrument = [ChannelView nameForProgram:[channel.Instruments[0] intValue] channel:channel.Number];
//            
//            break;
//        }
//    }
    
    [theAlert textFieldAtIndex:0].text = [base stringByAppendingFormat:@" (%@)", instrument ];
    
    [[theAlert textFieldAtIndex:0] selectAll:nil];
    [theAlert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 65) {
        alertShown = NO;
        [self notationDisplayReady];
        return;
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save"]) {
        [self saveArrangementWithName:[alertView textFieldAtIndex:0].text];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [nzDisplay.statsDisplay.saveArrangementButton setAlpha:0];
        [nzDisplay.statsDisplay.saveArrangementsLabel setAlpha:0];
        [UIView commitAnimations];
        [self setupTitle:YES];
        [NZEvents logEvent:@"Arrangement saved"];
    }
    [self performSelector:@selector(regainKeyboardControl) withObject:nil afterDelay:1];
}

- (void) saveArrangementWithName:(NSString *)name {
    Arrangement *arr = [Arrangement new];
    arr.Title = name;
    if (!arr.Title || arr.Title.length < 1) {
        arr.Title = [[NSDate date] description];
    }
    arr.MidiFile = [SongOptions MidiFile];
    
    arr.UserInstrument = program;
    arr.UserChannel = [SongOptions activeChannel];
    arr.Chorded = [SongOptions isChorded];
    arr.Exmatch = [SongOptions isExmatch];
    arr.TwoRow = [SongOptions isTwoRow];
    arr.keyboardType = [SongOptions keyboardType];
    arr.Channels = [SongOptions Channels];
    arr.tempo = _inputHandler.tempoFactor;
    arr.settings = [SettingsViewController getSettings];
    
    if ([SongOptions currentStats]) {
        arr.statsHistory = [NSMutableArray arrayWithArray:[SongOptions currentStats]];
    }
    
    LibraryItem *item = [LibraryItem withArrangement:arr];
    if ([LibraryManager addItem:item]) {
        [SongOptions setCurrentItem:item isSameItem:YES];
    }
}

- (void)clear {
    [self loadCurrentSong];
    [[PerformanceViewController sharedController] loadCurrentSong];
}


////
#pragma mark - SONG CONTROL
//


- (void)restart:(id)sender {
    [NZEvents logEvent:@"Performance restart"];
    [self restartSong];
}

- (void) restartSong {
    if (waiting) return;
    _inputHandler.autoplaying = NO;
    player.autoplayChannels = nil;
    autoplayButton.selected=NO;
    playButton.selected=NO;
    [self performSelector:@selector(loadCurrentSong) withObject:nil afterDelay:0.12];
}

- (void) beginCountdown {
    countDownHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    countDownHUD.userInteractionEnabled=NO;
    countDownHUD.labelText = @"3";
    //  countDownHUD.detailsLabelText = [NSString stringWithFormat:@"%d", (int)(0.5 + ticks / _inputHandler.ticksPerSecond)];
    countDownHUD.labelFont = [UIFont boldSystemFontOfSize:40];
    countDownHUD.mode = MBProgressHUDModeText;
    countDownHUD.yOffset = -204;
    //    _inputHandler.autoplaying = NO;
    //    player.autoplayChannels = nil;
    //    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateCountdown) object:nil];
    countdown = 2;
    //    [self updateCountdown];
    [countdownTimer invalidate];
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
    
}

- (void) updateCountdown {
    if (countdown == 0) {
        [_inputHandler start];
        //        if (recordSwitch.isOn) [player startRecording];
        [countdownTimer invalidate];
        countdownTimer = nil;
        return;
    }
    
    if (countdown == 1) {
        [countDownHUD hide:YES afterDelay:0.5];
    }
    
    if (countdown == 1) {
        //  [nzDisplay startOneSecond];
        // [_inputHandler startOneSecond];
        //  _inputHandler.acceptingInput = YES;
    }
    countDownHUD.labelText = [NSString stringWithFormat:@"%d", countdown];
    countdown--;
}

- (void)startPause:(id)sender {
    if (waiting || _inputHandler.isFinished) return;
    //    if (_inputHandler.autoplaying) {
    //        [self autoPlay:nil];
    //        return;
    //    }
    if (countdown) {
        [countdownTimer invalidate];
        [countDownHUD hide:YES];
        [playButton setSelected:NO];
        countdown = 0;
        return;
    }
    
    
    if (_inputHandler.isPaused) {
        if (_inputHandler.currentTicks == 0 && _inputHandler.performanceMode == PERFORMANCE_BAND_DRIVEN) {
            if (waiting || waitingTimer) {
                [_inputHandler start];
            } else {
                [self beginCountdown];
            }
            [playButton setSelected:YES];
        } else {
            [_inputHandler start];
            [playButton setSelected:YES];
        }
    } else {
        //        if (_inputHandler.performanceMode == PERFORMANCE_USER_DRIVEN && !waitingTimer) {
        //            return;
        //        } else {
        [playButton setSelected:NO];
        [_inputHandler pause];
        //       }
    }
}

- (void)autoPlay:(id)sender {
    if (waiting || ![SongOptions CurrentItem]) return;
    //    if (_inputHandler.autoplaying) {
    //        if (_inputHandler.isPaused) {
    //            [_inputHandler start];
    //            [autoplayButton setSelected:YES];
    //            [playButton setSelected:YES];
    //        } else {
    //            [autoplayButton setSelected:NO];
    //            [playButton setSelected:NO];
    //            [_inputHandler pause];
    //        }
    //    } else {
    //        [autoplayButton setSelected:YES];
    //        [playButton setSelected:YES];
    //        if (_inputHandler.currentTime > 0) {
    //            [self loadCurrentSong];
    //        }
    //           _inputHandler.autoplaying = YES;
    //        [_inputHandler performSelector:@selector(start) withObject:nil afterDelay:0.12];
    //    }
    _inputHandler.autoplaying = !_inputHandler.autoplaying;
    autoplayButton.selected = _inputHandler.autoplaying;
    if (_inputHandler.autoplaying) {
        
    }
    //    if (_inputHandler.autoplaying && _inputHandler.isPaused) {
    //        [_inputHandler start];
    //        playButton.selected = YES;
    //    }
}

- (void)showOptions {
    if ([self.presentedViewController isBeingDismissed] || [self.modalViewController isBeingDismissed] || [self.navigationController.presentedViewController isBeingDismissed] || [self.navigationController.modalViewController isBeingDismissed]) {
        [self performSelector:@selector(showOptions) withObject:nil afterDelay:0.1];
        return;
    }
    [self performSegueWithIdentifier:@"Options" sender:nil];
}

- (void)showInstruments {
    if ([self.presentedViewController isBeingDismissed] || [self.modalViewController isBeingDismissed] || [self.navigationController.presentedViewController isBeingDismissed] || [self.navigationController.modalViewController isBeingDismissed]) {
        [self performSelector:@selector(showInstruments) withObject:nil afterDelay:0.1];
        return;
    }
    [self performSegueWithIdentifier:@"Instruments" sender:nil];
}

- (BOOL)pathPressed:(int)screen {
    [_inputHandler pause];
    playButton.selected=NO;
    switch (screen) {
        case PERFORMANCE:
            return NO;
            break;
        case OPTIONS:
            [_inputHandler pause];
            [self showOptions];
            break;
        case ARRANGEMENT:
            [_inputHandler pause];
            [self showSongOptions];
            break;
        case STORE:
            [_inputHandler pause];
            [self showStore];
            break;
        case LIBRARY:
            [_inputHandler pause];
            [self showLibrary];
            break;
        case INSTRUMENTS:
            [_inputHandler pause];
            [self showInstruments];
            break;
        case COLLAB:
            return NO;
            break;
        case USER_GUIDE:
            [self showGuide];
            break;
            
        default:
            return nil;
            break;
    }
    return YES;
}

- (void)panic:(id)sender {
    [[AudioPlayer sharedPlayer] panic];
}

- (void)setupTitle:(BOOL)animated {
    CGPoint center = lyricsLabel.center;
    lyricsLabel.text = [SongOptions CurrentItem].Title;
    [lyricsLabel sizeToFit];
    CGRect frame = lyricsLabel.frame;
    if (frame.size.width > 900) {
        frame.size.width = 900;
        lyricsLabel.frame = frame;
    }
    lyricsLabel.center = center;
    lyricsLabel.alpha = 0;
    nzDisplay.showLyrics=NO;
    // lyricsLabel.hidden = (_showLyrics && _song;
    center = lyricsImageView.center;
    CGSize size;
    
    if (_inputHandler.song.hasLyrics && _showLyrics) {
        size.width = 1024;
    } else {
        size.width = MAX(lyricsLabel.frame.size.width+100, 200);
    }
    NSTimeInterval dur = ABS(size.width - lyricsImageView.frame.size.width) / 1024.0;
    dur *= 1.3;
    if (dur < 0.6) dur = 0.6;
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:dur];
    }
    
    
    size.height = lyricsImageView.frame.size.height;
    
    [lyricsImageView setFrame:CGRectMake(self.view.frame.size.width/2.0 - size.width/2.0, lyricsImageView.frame.origin.y, size.width, size.height)];
    lyricsImageView.center = center;
    if (animated) {
        [UIView commitAnimations];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        
        [UIView setAnimationDelay:dur];
    }
    if (_inputHandler.song.hasLyrics && _showLyrics) {
        nzDisplay.showLyrics=YES;
    } else {
        lyricsLabel .alpha=1;
    }
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)setShowLyrics:(BOOL)showLyrics {
    _showLyrics = showLyrics;
    [self setupTitle:loaded];
    //nzDisplay.showLyrics = _showLyrics;
}

- (void)showGuide  {
    if ([self.presentedViewController isBeingDismissed] || [self.modalViewController isBeingDismissed] || [self.navigationController.presentedViewController isBeingDismissed] || [self.navigationController.modalViewController isBeingDismissed]) {
        [self performSelector:@selector(showGuide) withObject:nil afterDelay:0.1];
        return;
    }
    [self performSegueWithIdentifier:@"Guide" sender:nil];
}

- (void)dismissGuide {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showQuickStart {
    //  [self performSegueWithIdentifier:@"QuickStart" sender:nil];
    UIViewController *qsvc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"QuickStart"];
    [self presentViewController:qsvc animated:YES completion:nil];
}

- (void)dismissQuickStart {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tempoDidChange {
    [tempoSlider setValue:_inputHandler.tempoFactor animated:YES];
}

- (void) loadCurrentSongWithOptions {
    [self loadCurrentSong:NO setOptions:YES isSamePiece:NO];
}

- (void) loadIntroSong {
    [self loadCurrentSong:YES setOptions:NO isSamePiece:NO];
    // remove notes after certain time
}

- (void)loadCurrentSong {
    [self loadCurrentSong:NO setOptions:NO isSamePiece:NO];
}

#define LOAD_COUNT_KEY @"nTimesLoaded1"

- (void)loadCurrentSong:(BOOL)intro setOptions:(BOOL)setOptions isSamePiece:(BOOL)same {
    // [player stopPlaying];
    //[player seek:0];
    [waitingTimer invalidate];
    waitingTimer = nil;
    [waitingHUD hide:NO];
    if ([SongOptions CurrentItem] && [SongOptions needsToLoad]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[PerformanceViewController sharedController].view animated:YES];
        hud.labelText = @"Converting..";
        hud.yOffset = -204;
        _inputHandler.key = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self _loadSong:intro isSamePiece:same];
            //            if (_inputHandler.song.hasLyrics) {
            //
            //            } else {
            //
            //            }
            //            lyricsSwitch.on = _inputHandler.song.hasLyrics;
            //            nzDisplay.showLyrics = lyricsSwitch.on;
//            if ([[SongOptions CurrentItem].Title hasPrefix:@"Final Fantasy - Terra's"]) {
//                [self changeProgram:nextButton];
//                [self changeProgram:nextButton];
//            }
            [hud hide:YES];
            [self setupTitle:YES];
            
            int loadCount = [[[NSUserDefaults standardUserDefaults] objectForKey:LOAD_COUNT_KEY] intValue];
            loadCount++;
            [[NSUserDefaults standardUserDefaults] setObject:@(loadCount) forKey:LOAD_COUNT_KEY];
            if (loadCount == 3) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check this out!" message:@"To adjust the difficulty of a song, you can use the Arrangement screen. There, you can switch between keyboards, choose your part in the song, and select options to combine chords or let any key play the right note!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                alert.tag = 65;
//                [alert performSelector:@selector(show) withObject:nil afterDelay:0.6];
//                alertShown = YES;
            } else if  (loadCount == 4) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try different instruments!" message:@"You can change instruments by tapping the instrument name, or by using the Previous and Next buttons. There are over 100 to choose from!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                alert.tag = 65;
//                [alert performSelector:@selector(show) withObject:nil afterDelay:0.6];
//                alertShown = YES;
            } else if (loadCount == 5) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"One more tip!" message:@"Don't forget that each screen (including this one!) has a help button in the lower right. It will show you what all the buttons and gizmos do!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                alert.tag = 65;
//                [alert performSelector:@selector(show) withObject:nil afterDelay:0.6];
//                alertShown = YES;
            }
            if (setOptions) {
                [self setArrangementOptions];
            }
            if (same) {
                [self resetProgram];
            }
                       volumeSlider.value = [AudioPlayer sharedPlayer].volume;
        });
    } else {
        [self _loadSong:intro isSamePiece:same];
     
            [self resetProgram];
       
        if (setOptions) {
            [self setArrangementOptions];
        }
    }
    if ([SongOptions CurrentItem]) {
        int count = [[[NSUserDefaults standardUserDefaults] objectForKey:SONG_LOAD_COUNT] intValue];
        count++;
//        if (count == 1 && ![[SongOptions CurrentItem].Title hasPrefix:@"Jingle"]) {
//            count++;
//        }
        [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:SONG_LOAD_COUNT];
        if (count > 3) {
            
        }
    }
     volumeSlider.value = [AudioPlayer sharedPlayer].volume;
}

- (void) setArrangementOptions {
    int userChannel = [SongOptions CurrentItem].Arrangement.UserChannel;
    if (userChannel == [SongOptions activeChannel]) {
        [self setProgram:[SongOptions CurrentItem].Arrangement.UserInstrument];
        [[NZInputHandler sharedHandler] userDidChangeProgram];
    }
    
    float tempo = [SongOptions CurrentItem].Arrangement.tempo;
    if (tempo != 0) {
        tempoSlider.value = tempo;
        [self tempo:nil];
    }
}

- (void) animateForDuration:(float)duration withBlock:(void(^)())block {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView commitAnimations];
    block();
    [UIView commitAnimations];
}

- (void) positionControlPanelViewForThumb:(BOOL)animated {
//
//    if (!inThumbMode) {
//        CGRect frame = nzDisplay.frame;
//        frame.origin.y = 360;
//        if (animated) {
//            [self animateForDuration:0.5 withBlock:^(void) {
//                for (UIView *view in _controlButtons) {
//                    view.center = CGPointMake(view.center.x, view.center.y - 100);
//                }
//                nzDisplay.frame = frame;
//            }];
//        } else {
//            for (UIView *view in _controlButtons) {
//                view.center = CGPointMake(view.center.x, view.center.y - 100);
//            }
//            nzDisplay.frame = frame;
//        }
//    }
//    inThumbMode = YES;
//    pitchBendView.hidden = YES;
}

- (void) positionControlPanelViewForNonThumb:(BOOL)animated  {
//    if (inThumbMode) {
//        CGRect frame = nzDisplay.frame;
//        frame.origin.y = 37;
//        if (animated) {
//            [self animateForDuration:0.5 withBlock:^(void) {
//                for (UIView *view in _controlButtons) {
//                    view.center = CGPointMake(view.center.x, view.center.y + 100);
//                }
//                nzDisplay.frame = frame;
//            }];
//        } else {
//            for (UIView *view in _controlButtons) {
//                view.center = CGPointMake(view.center.x, view.center.y + 100);
//            }
//            nzDisplay.frame = frame;
//        }
//    }
//    inThumbMode = NO;
//    pitchBendView.hidden = NO;
}

- (void)_loadSong:(BOOL)intro isSamePiece:(BOOL)same {
    isSongLoading = YES;
    
    currentTime = -1;
    _inputHandler.autoplaying = NO;
    autoplayButton.selected=NO;
  //  [[KeyboardView sharedView] reset];
    if ([SongOptions keyboardType] == KeyboardTypeThumbPiano) {
        [self positionControlPanelViewForThumb:YES];
    } else {
        [self positionControlPanelViewForNonThumb:YES];
    }
    theKeyboard.mode = [SongOptions keyboardType];
    // theKeyboard.pianoKeys = [SongOptions isColumned];
    if ([SongOptions CurrentItem] != nil) {
        
        Song *song = [SongOptions getSong];
        
        if (intro) {
            for (int i = song.soloNotes.count-1; i > -1 && [(RGNote *)song.soloNotes[i] time] > 6040; i--) {
                [(NSMutableArray *)song.soloNotes removeObjectAtIndex:i];
            }
            for (int i = song.bandNotes.count-1; i > -1 && [(RGNote *)song.bandNotes[i] time] > 6040; i--) {
                [(NSMutableArray *)song.bandNotes removeObjectAtIndex:i];
            }
            song.totalTicks = MAX([(RGNote *)[song.bandNotes lastObject] time] + [(RGNote *)song.bandNotes.lastObject duration], [(RGNote *)[song.soloNotes lastObject] time] + [(RGNote *)song.soloNotes.lastObject duration]);
        }
        
        [self setupWithSong:song isSamePiece:same];
        progressSlider.maximumValue = _inputHandler.song.totalTicks;
        [progressTimer invalidate];
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    } else {
        [_inputHandler setSong:nil isSamePiece:NO];
    }
    int totalSeconds = [_inputHandler totalSeconds];
    totalTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", totalSeconds/60, totalSeconds%60];
    if ([SongOptions keyboardType] == KeyboardTypeThumbPiano) {
        _inputHandler.autoPedal = YES;
    }
    isSongLoading = NO;
    if (_wantsPianoKeyboard) {
        _wantsPianoKeyboard = NO;
        [SongOptions setKeyboardType:KeyboardTypeFullPiano];
        if ([SongOptions needsToLoad]) {
            [self _loadSong:NO isSamePiece:YES];
        }
    }
}

- (void) updateProgress {
    progressSlider.value = _inputHandler.currentTicks;
    int currentSeconds = [_inputHandler currentSeconds];
    currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", currentSeconds/60, currentSeconds%60];
}

- (void) progressSliderMoves:(id)sender {
    [_inputHandler setCurrentTicks:progressSlider.value sound:YES];
}

- (void) hideHUD {
    
}

- (void)resetProgram {
    for (NSNumber *ch in [SongOptions activeChannels]) {
        [[AudioPlayer sharedPlayer] setProgram:program forChannel:[ch intValue]];
    }
}

- (void)willReappear {
    if (didPause) {
        //  [AudioPlayer sharedPlayer].muted=NO;
    }
    didPause=NO;
}

- (void) setupWithSong:(Song *)song  isSamePiece:(BOOL)same{
    waiting=YES;
    nzDisplay.division = song.division;
    _inputHandler.exmatch = [SongOptions isExmatch];
    [_inputHandler setSong:song isSamePiece:same];
    
    //   [theNamePlate performSelector:@selector(updateProgram) withObject:nil afterDelay:0.1];
}

- (void)updateProgram:(int)aProgram forChannel:(int)channel {
    if ([[SongOptions activeChannels] containsObject:[NSNumber numberWithInt:channel]]) {
        program = aProgram;
        [self performSelector:@selector(updateProgram) withObject:nil afterDelay:0.1];
    }
}
- (void)setProgram:(int)aProgram {
    if ([SongOptions CurrentItem] && [SongOptions activeChannels].count) {
        program = aProgram;
        int ch = [[[SongOptions activeChannels] lastObject] intValue];
        [[AudioPlayer sharedPlayer] setProgram:program forChannel:ch];
        [self performSelector:@selector(updateProgram) withObject:nil afterDelay:0.1];
    }
}


//- (void) delayedSetupWithNotes:(NSArray *)notes {
//    waiting = YES;
//    if ([SongOptions CurrentItem].Type == LibraryItemTypeRecording) {
//        nzDisplay.division = [SongOptions CurrentItem].Arrangement.Division;
//        _inputHandler.recordingRate = nzDisplay.division;
//    } else {
//        nzDisplay.division = [player ticksPerQuarterNote];
//        _inputHandler.recordingRate = [player ticksPerQuarterNote];
//    }
//    _inputHandler.exmatch = nzDisplay.exmatch = [SongOptions isExmatch];
//    [_inputHandler setupForNotes:notes solo:[SongOptions inactiveChannels].count == 0];
//
//}

////
#pragma mark - SEGUES
//

- (void)dismissLibraryController:(BOOL)needsOptions newFile:(BOOL)newFile {
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:YES];
        if (needsOptions) {
            [self performSelector:@selector(showSongOptions) withObject:nil afterDelay:0.7];
        } else if (newFile) {
            [_inputHandler setSong:nil isSamePiece:NO];
            [SettingsViewController loadArrangementSettings:[SongOptions CurrentItem].Arrangement.settings];

            [self performSelector:@selector(loadCurrentSongWithOptions) withObject:@(YES) afterDelay:0.7];
            
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^(void) {
            if (needsOptions) {
                [self showSongOptions];
            } else {
                [self loadCurrentSong];
            }
            
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AudioPlayer sharedPlayer].sendToInputHandler = YES;
    volumeSlider.value = [AudioPlayer sharedPlayer].volume;
    if (currentTime > -1) {
        _inputHandler.autoplaying = wasAutoplaying;
        [[AudioPlayer sharedPlayer] seek:currentTime];
    }
    [self willReappear];
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:DONT_SHOW_QUICK_START_KEY]) {
//        
//        UIViewController *qsvc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"QuickStart"];
//        
//        
//        [self presentViewController:qsvc animated:NO completion:nil];
//        
//        
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DONT_SHOW_QUICK_START_KEY];
//    } 
    
}

- (void)showLibrary {
    if ([self.presentedViewController isBeingDismissed] || [self.modalViewController isBeingDismissed] || [self.navigationController.presentedViewController isBeingDismissed] || [self.navigationController.modalViewController isBeingDismissed]) {
        [self performSelector:@selector(showLibrary) withObject:nil afterDelay:0.1];
        return;
    }
    [self performSegueWithIdentifier:@"Library" sender:nil];
}

- (void)store:(id)sender {
    [self showStore];
    
}

- (void)library:(id)sender {
    
}

- (void)songOptions:(id)sender {
    [self showOptions];
    
}

//- (void) showOptions {
//   // if (_inputHandler.performanceMode == PERFORMANCE_BAND_DRIVEN || _inputHandler.autoplaying) {
//        [_inputHandler pause];
//   // }
//    [self showSongOptions];
//   // [self performSegueWithIdentifier:@"SongOptions" sender:nil];
//}

- (void) willSegue {
    [_inputHandler pause];
    //  }
    //  autoplayButton.selected=NO;
    playButton.selected=NO;
    // [[AudioPlayer sharedPlayer] attenuate:0.5];
    //    if (pathButton.selected) {
    //        [self path:nil];
    //    }
    didPause=YES;
}

- (void)showStore {
    if ([self.presentedViewController isBeingDismissed] || [self.navigationController.presentedViewController isBeingDismissed] ) {
        [self performSelector:@selector(showStore) withObject:nil afterDelay:0.1];
        return;
    }
    [self willSegue];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Store"];
    storeVC = vc;
 
    [self.view.superview addSubview:vc.view];
    
    CGRect frame = vc.view.frame;
    frame.origin = CGPointMake(-1024, 0);
    frame.size.width = self.view.frame.size.width;
    frame.size.height = self.view.frame.size.height;
    vc.view.frame = frame;
      [vc viewWillAppear:NO];
    [UIView transitionWithView:self.view.superview duration:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        vc.view.frame = CGRectMake(0,0,1024,768);
        self.view.frame = CGRectMake(1024,0,1024,768);
    } completion:^(BOOL finished) {
        [vc viewDidAppear:NO];
        [self viewDidDisappear:YES];
        storeShown = YES;
        //                [sourceViewController.view setBounds:CGRectMake(0, 0, 1024, 768)];
        //                [sourceViewController presentViewController:destinationController animated:NO completion:nil];
    }];
}

- (void)dismissStore:(BOOL)animated {
    if (storeVC) {
        storeShown = NO;
        [storeVC viewWillDisappear:NO];
        [self viewWillAppear:NO];
        [UIView transitionWithView:self.view.superview duration:(animated ? 0.7 : 0) options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            storeVC.view.frame = CGRectMake(-1024,0,1024,768);
            if (animated)
                self.view.frame = CGRectMake(0,0,1024,768);
        } completion:^(BOOL finished) {
            [storeVC.view removeFromSuperview];
            [storeVC viewDidDisappear:YES];
            [self viewDidAppear:NO];
            storeVC = nil;
        }];
    }
}

- (void) dismissStoreAndPerformCurrentSong {
    if (storeVC) {
        storeShown = NO;
        [storeVC viewWillDisappear:NO];
        [self viewWillAppear:NO];
        [UIView transitionWithView:self.view.superview duration:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            storeVC.view.frame = CGRectMake(-1024,0,1024,768);
            self.view.frame = CGRectMake(0,0,1024,768);
        } completion:^(BOOL finished) {
            [storeVC.view removeFromSuperview];
            [storeVC viewDidDisappear:YES];
            [self viewDidAppear:NO];
            storeVC = nil;
            [self showSongOptions];
        }];
    }

}

- (void)showSongOptions {
    if ([self.presentedViewController isBeingDismissed] || [self.modalViewController isBeingDismissed] || [self.navigationController.presentedViewController isBeingDismissed] || [self.navigationController.modalViewController isBeingDismissed]) {
        [self performSelector:@selector(showSongOptions) withObject:nil afterDelay:0.1];
        return;
    }
    [self willSegue];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SongOptions"];
    songOptionsVC = vc;
    //    if (previewPath) {
    //        SongOptionsViewController *svc = (SongOptionsViewController *)vc;
    //        svc.isForStore = YES;
    //        svc.songPath = previewPath;
    //        previewPath = nil;
    //    } else {
    //
    //    }
    [self.view.superview addSubview:vc.view];
    CGRect frame = vc.view.frame;
    frame.origin = CGPointMake(1024, 0);
    frame.size.width = self.view.frame.size.width;
    frame.size.height = self.view.frame.size.height;
    vc.view.frame = frame;
    [vc viewWillAppear:NO];
    [UIView transitionWithView:self.view.superview duration:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        vc.view.frame = CGRectMake(0,0,1024,768);
        self.view.frame = CGRectMake(-1024,0,1024,768);
    } completion:^(BOOL finished) {
        [vc viewDidAppear:NO];
        [self viewDidDisappear:YES];
        //                [sourceViewController.view setBounds:CGRectMake(0, 0, 1024, 768)];
        //                [sourceViewController presentViewController:destinationController animated:NO completion:nil];
    }];
}

- (void)dismissSongOptions {
    if (songOptionsVC) {
        [songOptionsVC viewWillDisappear:NO];
        [self viewWillAppear:NO];
        [UIView transitionWithView:self.view.superview duration:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            songOptionsVC.view.frame = CGRectMake(1024,0,1024,768);
            self.view.frame = CGRectMake(0,0,1024,768);
        } completion:^(BOOL finished) {
            [songOptionsVC.view removeFromSuperview];
            [self viewDidAppear:NO];
            [songOptionsVC viewDidDisappear:YES];
            songOptionsVC = nil;
        }];
    }
}

- (void)selectInstrument:(id)sender {
    [self performSegueWithIdentifier:@"Instruments" sender:nil];
}

- (void)showPreviewForStore:(NSString *)path {
    // previewPath = path;
    [self performSegueWithIdentifier:@"SongOptions" sender:path];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  if (_inputHandler.performanceMode == PERFORMANCE_BAND_DRIVEN || _inputHandler.autoplaying) {
    [self willSegue];
    if ([segue.identifier isEqualToString:@"SongOptions"]) {
        // autoplaying = NO;
        //        currentTime = _inputHandler.currentTime;
        //        wasAutoplaying = _inputHandler.autoplaying;
        //        _inputHandler.autoplaying = NO;
        if (sender) {
            SongOptionsViewController *svc = [segue destinationViewController];
            svc.isForStore = YES;
            svc.songPath = sender;
        }
        
    }
    if ([[segue identifier] isEqualToString:@"ArrangementOptions"]) {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        arrangementOptionsPopover = popoverSegue.popoverController;
        arrangementOptionsPopover.delegate  = self;
        arrangementOptionsPopover.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
    }
    if ([segue.identifier isEqualToString:@"HeadToTheLibrary"]) {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        UIPopoverController *pc = popoverSegue.popoverController;
        pc.delegate  = self;
        pc.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
    }
    
    //[nzDisplay reset];
    //[_inputHandler restart];
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == arrangementOptionsPopover) {
    if ([SongOptions needsToLoad]) {
        
        [self loadCurrentSong:NO setOptions:NO isSamePiece:YES];
        [NZEvents logEvent:@"Arrangement Options Changed" args:@{@"Exmatch" : @([SongOptions isExmatch]), @"Chorded" : @([SongOptions isChorded]), @"Keyboard" : @([SongOptions keyboardType]), @"TwoRow" : @([SongOptions isTwoRow])}];
      //  [self setProgram:program];
      //  [[NZInputHandler sharedHandler] userDidChangeProgram];
    }
    }
}


- (void)performanceFinished {
    int count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PerformanceCount"] intValue];
    count++;
    
    [NZEvents logEvent:@"Performance finished" args:@{@"Song" : [SongOptions CurrentItem].Title}];
    
    LibraryItem *nextSong = [LibraryManager setlistItemAfterItem:[SongOptions CurrentItem]];
    if (nextSong && [SongOptions isCurrentItemJukebox]) {
        [_inputHandler setSong:nil isSamePiece:NO];
        [SettingsViewController loadArrangementSettings:nextSong.Arrangement.settings];
        [SongOptions setCurrentItem:nextSong isSameItem:NO];
        [self loadCurrentSongWithOptions];
    } else {
        if (YES || !_inputHandler.autoplaying || count == 1) {
            [self saveStats];
            nzDisplay.statsDisplay.stats = [SongOptions currentStats];
            
            [nzDisplay showStats:YES];
            // [self performSegueWithIdentifier:@"Stats" sender:nil];
            
            if (count == 1) {
                if ([[SongOptions CurrentItem].Title hasPrefix:@"Jingle"]) {
                    [[[UIAlertView alloc] initWithTitle:@"Contratulations!" message:@"You've successfully played your first song. There are plenty more available in the Library, so head over and check them out!\nLater, you can use the Store to find your favorite songs online - there are hundreds of thousands available!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] performSelector:@selector(show) withObject:nil afterDelay:1];
                } else {
                    
                    
                }
            }
        } else  {
            double delayInSeconds = 1.0;
            self.view.userInteractionEnabled = NO;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.view.userInteractionEnabled = YES;
                [self restartSong];
            });
        }
    }
    autoplayButton.selected = NO;
    playButton.selected = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:@"PerformanceCount"];
}

- (void) saveStats {
    Statistics *s = [StatsViewController getStats];
    //   // NSArray *events = [NZInputHandler sharedHandler].song.specialEvents;
    //
    //    int wrongNotes = 0, skippedNotes = 0, rightNotes = 0, notesPlayedOnTime = 0;
    //    float tempoAccuracy = 0; // average time off from actual time (in seconds)
    //
    //    for (RGNote *n in [NZInputHandler sharedHandler].notes) {
    //        if (n.time >= [NZInputHandler sharedHandler].currentTime) {
    //            break;
    //        }
    //        if (n.note == 0) continue;
    //        if (n.timePlayed > -1) {
    //            rightNotes++;
    //            int margin = 0.15 / 60 * n.rate;
    //            int diff = ABS(n.timePlayed - n.time);
    //            if (diff < margin) {
    //                notesPlayedOnTime++;
    //            }
    //            tempoAccuracy += diff;
    //        } else {
    //            skippedNotes++;
    //        }
    //
    //        // 0.15 seconds
    //        // 0.15 (s) * rate (ticks/min) * 1/60 (min/sec)
    //
    //    }
    //    wrongNotes = [NZInputHandler sharedHandler].wrongNotes;
    //
    //    tempoAccuracy /= rightNotes;
    //
    //    s.wrongNotes = wrongNotes;
    //    s.rightNotes = rightNotes;
    //    s.skippedNotes = skippedNotes;
    //    s.notesPlayedOnTime = notesPlayedOnTime;
    //    s.tempoAccuracy = tempoAccuracy;
    s.date = [NSDate date];
    
    [SongOptions addStats:s];
}


////
#pragma mark - PROGRAM CONTROL
- (void)updateProgramOnPlayerAndNotify {
    [_inputHandler userDidChangeProgram];
    
    
    for (NSNumber *ch in [SongOptions activeChannels]) {
        [[AudioPlayer sharedPlayer] setProgram:program forChannel:[ch intValue]];
    }
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgram) object:nil];
    
    [self performSelector:@selector(updateProgram) withObject:nil afterDelay:0.1f];
}

//

- (void)changeProgram:(id)sender {
    if (sender != nil) {
        UIButton *button = (UIButton *) sender;
        
        switch (button.tag) {
            case 0:
                if (0 < program) {
                    program--;
                }
                else return;
                break;
            case 1:
                if (program < 127) {
                    program++;
                }
                else return;
                break;
        }
    }
    [self updateProgramOnPlayerAndNotify];
}

- (void) updateProgram {
    if ([[SongOptions activeChannels] count]) {
        [instrumentLabel setText:[NSString stringWithFormat:@"%@",[[AudioPlayer sharedPlayer] getCurrentProgram:[[SongOptions activeChannels][0] intValue]]]];
        // program = [[AudioPlayer sharedPlayer] program:[[SongOptions activeChannels][0] intValue]]
    } else {
        [instrumentLabel setText:@"Acoustic Grand Piano"];
    }
}


- (void)pause:(id)sender {
    //    if ([Synchronizer sharedSynchronizer].paused) {
    //        [[Synchronizer sharedSynchronizer] resume];
    //    } else {
    //    [[Synchronizer sharedSynchronizer] stop];
    //    }
    
}

////
# pragma mark - BAND MUTING
//

- (void)muteBand:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    // [InputHandler bandHandler].MuteBand = !theSwitch.on;
}


////
# pragma mark - MICROPHONE
//

- (void)mic:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on) {
        [MicrophoneManager startPassthrough];
    } else {
        [MicrophoneManager stop];
    }
}

- (void)volume:(id)sender {
    // theKeyboard.volume = [(UISlider *)sender value];
    // [MicrophoneManager setVolume:[(UISlider *)sender value]];
    [AudioPlayer sharedPlayer].volume = volumeSlider.value;
}

- (void)setMic:(BOOL)mic {
    if (mic) {
        micImage.image = [UIImage imageNamed:@"microphone-lit.png"];
    } else {
        micImage.image = [UIImage imageNamed:@"microphone.png"];
    }
}

- (void) setMidiIn:(BOOL)midiIn {
    if (midiIn) {
        
        midiInImage.image = [UIImage imageNamed:@"midi-in-lit.png"];
        [self setWantsKeyboardDisplay:YES];
    } else {
        midiInImage.image = [UIImage imageNamed:@"midi-in.png"];
        [self setWantsKeyboardDisplay:NO];
    }
}

- (void) setMidiOut:(BOOL)midiOut {
    if (midiOut) {
        midiOutImage.image = [UIImage imageNamed:@"midi-out-lit.png"];
    } else {
        midiOutImage.image = [UIImage imageNamed:@"midi-out.png"];
    }
}

////
# pragma mark - LYRICS
//

- (void)lyrics:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    if (s.on) {
        nzDisplay.showLyrics = YES;
    } else {
        nzDisplay.showLyrics = NO;
    }
}

////
# pragma mark - TEMPO
//

- (void)tempo:(id)sender {
    // [player setSpeed:tempoSlider.value];
    float value = MAX(0.25, tempoSlider.value);
    [_inputHandler setTempoFactor:value];
}

////
# pragma - NOTATION DISPLAY
//

- (void)switchYah:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
}

- (void) alertWaiting:(int)ticks {
    [waitingTimer invalidate];
    [waitingHUD hide:NO];
    waitingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    waitingHUD.userInteractionEnabled=NO;
    waitingHUD.labelText = @"Your part is coming up in";
    int time = (int)(0.5 + (ticks - _inputHandler.currentTicks) / _inputHandler.ticksPerSecond);
    time = MAX(0, time);
    waitingHUD.detailsLabelText = [NSString stringWithFormat:@"%d", time];
    waitingHUD.detailsLabelFont = [UIFont boldSystemFontOfSize:40];
    waitingHUD.mode = MBProgressHUDModeText;
    waitingHUD.yOffset = -204;
    waitingTicks = ticks;
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateWaiting) userInfo:nil repeats:YES];
    originalWaitTicks= waitingTicks - _inputHandler.currentTicks;
}

- (void) updateWaiting {
    float time = (int)(0.5 + (waitingTicks - _inputHandler.currentTicks) / _inputHandler.ticksPerSecond);
    if (time < 3 || (waitingTicks - _inputHandler.currentTicks) > originalWaitTicks) {
        [waitingHUD hide:YES];
       // NSLog(@"%d - %d", originalWaitTime, _inputHandler.currentTicks);
        [waitingTimer invalidate];
        waitingTimer = nil;
        return;
    } else if (!isnan(time) && !isinf(time)) {
        waitingHUD.detailsLabelText = [NSString stringWithFormat:@"%d", (int)(0.5 + time)];
    }
}

- (void)notationDisplayReady {
    if (alertShown) return;
    waiting = NO;
//    if (_inputHandler.performanceMode == PERFORMANCE_USER_DRIVEN && !_inputHandler.autoplaying) {
//        playButton.selected = YES;
//        [_inputHandler start];
//        
//    }
    
    //    [player setMidiFile:[SongOptions CurrentItem].Arrangement.MidiFile];
    //    if (_inputHandler.autoplaying) {
    //        for (NSNumber *n in [SongOptions activeChannels]) {
    //            [player setMute:NO forChannel:n.intValue];
    //        }
    //        player.autoplayChannels = [SongOptions activeChannels];
    //        [player startPlaying];
    //    } else {
    //        for (NSNumber *n in [SongOptions activeChannels]) {
    //            [player setMute:YES forChannel:n.intValue];
    //        }
    //    }
}

////
# pragma mark - VELOCITY
//

- (void)toggleVelocity:(id)sender {
    [theKeyboard setUsePressure:[(UISwitch *)sender isOn]];
}

////
# pragma mark - RECORDING
//

//- (void)toggleRecord:(id)sender {
//    if (recordSwitch.on) {
//        [[AudioPlayer sharedPlayer] performSelector:@selector(startRecording) withObject:nil afterDelay:0.15];
//    } else {
//        NSString *newMidiPath = [[Util uploadedSongsDirectory] stringByAppendingFormat:@"/%@-rec.mid",[SongOptions CurrentItem].Title];
//        [[AudioPlayer sharedPlayer] finishRecording:newMidiPath];
//        Arrangement *arr = [Arrangement new];
//        arr.Title = [NSString stringWithFormat:@"%@ (REC) %@", [SongOptions CurrentItem].Title, [[[NSDate date] description] substringToIndex:20]];
//        if (!arr.Title || arr.Title.length < 1) {
//            arr.Title = [[NSDate date] description];
//        }
//        arr.MidiFile = newMidiPath;
//
//        arr.UserInstrument = program;
//        arr.Chorded = [SongOptions isChorded];
//        arr.Exmatch = [SongOptions isExmatch];
//        arr.Columned = [SongOptions isColumned];
//       // arr.Notes = [SongOptions getNotes];
//        arr.Channels = [SongOptions Channels];
//        arr.Division = [[AudioPlayer sharedPlayer] ticksPerQuarterNote];
//
//        LibraryItem *item = [LibraryItem withArrangement:arr];
//        item.Type = LibraryItemTypeRecording;
//        [LibraryManager addItem:item];
//    }
//}

////
# pragma mark - EXTERNAL MIDI
//

- (void)connectionsChanged:(ExternalMIDIManager *)manager type:(MIDIConnectionChangeType)changeType connection:(PGMidiConnection *)connection {
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setMidiIn:[manager hasSource]];
        if ([manager hasSource]) {
            [NZEvents logEvent:@"Midi in connected"];
        }
        [self setMidiOut:[manager hasDestination]];
        [NZInputHandler sharedHandler].echoExternalMIDI = [manager hasDestination];
    });
    
    // [[AudioPlayer sharedPlayer] setEchoToExternalMIDI:[manager hasDestination]];
    //    midiLight.backgroundColor = [manager hasSource] ? [UIColor greenColor] : [UIColor darkGrayColor];
    //    outLight.backgroundColor = [manager hasDestination] ? [UIColor blueColor] : [UIColor darkGrayColor];
}

- (void) setWantsKeyboardDisplay:(BOOL)wantsKeyboardDisplay {
    if (wantsKeyboardDisplay) {
        if (isSongLoading) {
            _wantsPianoKeyboard = YES;
        } else if ([SongOptions CurrentItem]) {
             _wantsPianoKeyboard = NO;
            [SongOptions setKeyboardType:KeyboardTypeFullPiano];
            if ([SongOptions needsToLoad]) {
                [self loadCurrentSong:NO setOptions:NO isSamePiece:YES];
            }
           
        }
    } else {
        _wantsPianoKeyboard = NO;
    }
}

char pianoMapping[] = {'A','X','S','X','D','F','X','X','X','X','X','X','X','X','J','X','K','L','X',';'};
char thumbMapping[] = {'1','X','2','X','3','4','X','X','X','X','X','X','X','X','5','X','6','7','X','8'};

- (void)eventReceived:(NSString *)event {
    if (![SongOptions CurrentItem]) return;
    NSScanner *scanner = [NSScanner scannerWithString:event];
    //MidiEvent Evt;
    
    // NSLog(@"have event");
    unsigned int status, data1, data2;
    [scanner scanHexInt:&status];
    [scanner scanHexInt:&data1];
    [scanner scanHexInt:&data2];
    
    NSLog(@"MIDI note on: %d", data1);
    
    if (status >= 144 && status <= 169) {
        if (data1 == 54 || data1 == 61) {
            if (data2 == 0) {
                [self boostOff:self];
            } else {
                [self boost:self];
            }
            return;
        }
    } else if (status <= 143 && status >= 128) {
        if (data1 == 54 || data1 == 61) {
            [self boostOff:self];
            return;
        }
    }
    
    // NSString *text;
    
    BOOL exmatch = _inputHandler.exmatch;
    KeyboardType type = [SongOptions keyboardType];
    
    if (type != KeyboardTypeFullPiano && type != KeyboardTypeThumbPiano) {
        _inputHandler.exmatch = NO;
    } else if (exmatch) {
        char *mapping = type == KeyboardTypeFullPiano ? pianoMapping : thumbMapping;
        if (status >= 128 && status <= 169) {
            if (data1 >= 48 && data1 <= 67 && data1 != 54 && data1 != 61) {
                data1 = (unsigned int)mapping[data1 - 48];
            } else {
                return;
            }
            if ((char)data2 == 'X') return;
        }
        
    } 
    if (status >= 144 && status <= 169) {
        if (data2 == 0) {
            [_inputHandler handleNoteOff:(char)data1 andHandleKey:YES];
        } else {
            [_inputHandler handleNoteOn:(char)data1 velocity:data2 autoOff:NO andHandleKey:YES];
        }
        
    } else if (status <= 143 && status >= 128) {
        [_inputHandler handleNoteOff:(char)data1 andHandleKey:YES];
        //  text = [NSString stringWithFormat:@"Note Off: %d %d %d\n", status, data1, data2];
    } else if (status >= 0xB0 && status <= 0xB0 + 16) {
        if (!_inputHandler.autoPedal) {
            int channel = [[[SongOptions activeChannels] lastObject] intValue];
            [[AudioPlayer sharedPlayer] pedal:channel note:(char)data1 velocity:data2];
            if (data2 > 0) {
                [[KeyboardView sharedView] noteOn:' '];
                [[KeyboardView sharedView] noteOn:'_'];
            } else {
                [[KeyboardView sharedView] noteOff:' '];
                [[KeyboardView sharedView] noteOff:'_'];
                
            }
        }
    }
    
    _inputHandler.exmatch = exmatch;
    
    // textView.text = [textView.text stringByAppendingString:text];
    
    //    Evt.status = status;
    //    Evt.data1 = data1;
    //    Evt.data2 = data2;
    //    
    //   [[InputHandler sharedHandler] ProcessMidiData:&Evt];
}



@end
