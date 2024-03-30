//
//  SettingsViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 1/20/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "SettingsViewController.h"
#import "NZNotationDisplay.h"
#import "KeyboardView.h"
#import "PerformanceViewController.h"
#import "NZInputHandler.h"
#import "AudioPlayer.h"
#import "MicrophoneManager.h"
#import "AQSwitch.h"
#import "PitchBendWheel.h"
#define SETTINGS_KEY @"saved_settings_1"
#import "NZEvents.h"

NSDictionary *defaultSettings;

@interface SettingsViewController () {
    IBOutlet UISegmentedControl *nowLineSegControl, *upcomingNotesSetControl, *performanceModeSegControl;
    IBOutlet UISlider *upcomingNoteRangeSlider, *micVolumeSlider, *velocitySensitivitySlider, *noteWidthSlider, *bandVolumeSlider, *vibratoSlider, *metronomeSlider;
    IBOutlet AQSwitch *velocitySwitch, *micSwitch, *autoPedalSwitch, *highlightSwitch, *chorusSwitch, *reverbSwitch, *vibratoSwitch, *lyricsSwitch, *metronmeSwitch, *performanceHighlightSwitch;
    IBOutlet UILabel *upcomingNoteLabel, *noteWidthLabel;
    IBOutlet UISegmentedControl *tabSegControl;
    IBOutlet UIImageView *tab1, *tab2;
    IBOutlet UIView *page1, *page2;
    UIImageView *helpView;
    IBOutlet UISwitch *autoTempoSwitch;
}

- (IBAction)toggleNowLine:(id)sender;
- (IBAction)toggleVelocity:(id)sender;
- (IBAction)velocitySensitivityChanged:(id)sender;
- (IBAction)upcomingNoteMode:(id)sender;
- (IBAction)upcomingNoteRangeChanged:(id)sender;
- (IBAction)togglePerformanceMode:(id)sender;
- (IBAction)toggleMic:(id)sender;
- (IBAction)micVolumeChanged:(id)sender;
- (IBAction)noteWidth:(id)sender;
- (IBAction)chorus:(id)sender;
- (IBAction)reverb:(id)sender;
- (IBAction)autoPedal:(id)sender;
- (IBAction)switchTab:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)toggleHighlight:(id)sender;
- (IBAction)bandVolume:(id)sender;
- (IBAction)vibratoSensitivity:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)autoTempo:(id)sender;
- (IBAction)metronomeVolume:(id)sender;

@end

@implementation SettingsViewController

+ (void)initialize {
    defaultSettings = [self getSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    vibratoSlider.value = [PitchBendWheel sharedWheel].sensitivity;
    nowLineSegControl.selectedSegmentIndex = [NZNotationDisplay sharedDisplay].mode == NOTATION_MOVING_NOW ? 0 : 1;
    velocitySwitch.on = [KeyboardView sharedView].UsePressure;
    highlightSwitch.on = [NZInputHandler sharedHandler].magnifyUpcomingNotes;
    upcomingNoteRangeSlider.value = [NZInputHandler sharedHandler].windowTime;
    upcomingNoteLabel.text = [NSString stringWithFormat:@"%.2f s", upcomingNoteRangeSlider.value];
    micSwitch.on = [MicrophoneManager isOn];
    vibratoSwitch.on = [PitchBendWheel sharedWheel].enabled;
    micVolumeSlider.value = [MicrophoneManager volume];
    performanceModeSegControl.selectedSegmentIndex = [NZInputHandler sharedHandler].performanceMode;
    reverbSwitch.on = [AudioPlayer sharedPlayer].reverb;
    chorusSwitch.on = [AudioPlayer sharedPlayer].chorus;
    lyricsSwitch.on = [PerformanceViewController sharedController].showLyrics;
    noteWidthSlider.value = [NZNotationDisplay sharedDisplay].widthBase / 100.0;
    noteWidthLabel.text = [NSString stringWithFormat:@"%.1f", noteWidthSlider.value];
    autoPedalSwitch.on = [NZInputHandler sharedHandler].autoPedal;
    tabSegControl.selectedSegmentIndex = 0;
    velocitySensitivitySlider.value = [KeyboardView sharedView].velocitySensitivity;
    bandVolumeSlider.value = [NZInputHandler sharedHandler].bandVolume;
    autoTempoSwitch.on = [NZInputHandler sharedHandler].autoTempo;
    metronmeSwitch.on = [NZInputHandler sharedHandler].metronomeEnabled;
    metronomeSlider.value = [NZInputHandler sharedHandler].metronomeVolume;
    performanceHighlightSwitch.on = [NZNotationDisplay sharedDisplay].performanceHighlightingEnabled;
    [self switchTab:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}


- (void)autoTempo:(id)sender {
    [NZInputHandler sharedHandler].autoTempo = autoTempoSwitch.on;
}

- (void)toggleHighlight {
    [NZInputHandler sharedHandler].magnifyUpcomingNotes = highlightSwitch.on;
}

- (void)vibratoSensitivity:(id)sender {
    [PitchBendWheel sharedWheel].sensitivity = vibratoSlider.value;
}

- (void)toggleVibrato {
    [PitchBendWheel sharedWheel].enabled = vibratoSwitch.on;
}

- (void)dismiss:(id)sender {
    if ([NZInputHandler sharedHandler].performanceMode != performanceModeSegControl.selectedSegmentIndex) {
        [NZInputHandler sharedHandler].performanceMode = performanceModeSegControl.selectedSegmentIndex;
        double delayInSeconds = 0.4;
        self.view.userInteractionEnabled = NO;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.parentViewController dismissModalViewControllerAnimated:YES];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
   
}

- (void)metronomeVolume:(id)sender {
    [NZInputHandler sharedHandler].metronomeVolume = metronomeSlider.value;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    double delayInSeconds = 0.1;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [[NZNotationDisplay sharedDisplay] setWidthBase:noteWidthSlider.value*100];
//    });
//    

    
    [[PerformanceViewController sharedController] willReappear];
    [SettingsViewController saveSettings];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        float value = [NZNotationDisplay sharedDisplay].widthBase;
        float newValue = noteWidthSlider.value * 100.0;
        if (ABS(newValue - value) > 0.1) {
            [NZNotationDisplay sharedDisplay].widthBase = noteWidthSlider.value * 100.0;
            if ([SongOptions CurrentItem]) {
                [SongOptions invalidate];
                [[PerformanceViewController sharedController] loadCurrentSong];
            }
        }
    });
}

- (void)switchTab:(id)sender {
    if (tabSegControl.selectedSegmentIndex == 0) {
        tab1.image = [UIImage imageNamed:@"op-tab-1-pressed.png"];
        tab2.image = [UIImage imageNamed:@"op-tab-2.png"];
    } else {
        tab1.image = [UIImage imageNamed:@"op-tab-1.png"];
        tab2.image = [UIImage imageNamed:@"op-tab-2-pressed.png"];
    }
    page1.hidden = tabSegControl.selectedSegmentIndex != 0;
    page2.hidden = tabSegControl.selectedSegmentIndex != 1;
}

- (void)toggleLyrics {
    [PerformanceViewController sharedController].showLyrics = lyricsSwitch.on;
}

+ (NSDictionary *) getSettings {
    NSMutableDictionary *settings = [NSMutableDictionary new];
    settings[@"AutoPedal"] = [NSNumber numberWithBool:[NZInputHandler sharedHandler].autoPedal];
    settings[@"Velocity"] = [NSNumber numberWithBool:[KeyboardView sharedView].UsePressure];
    settings[@"MagnifyUpcomingNotes"] = [NSNumber numberWithBool:[NZInputHandler sharedHandler].magnifyUpcomingNotes];
    //  settings[@"LimitOneChordAtATime"] = [NSNumber numberWithBool:[NZInputHandler sharedHandler].limitOneChordHighlightedAtATime];
    settings[@"WindowTime"] = [NSNumber numberWithFloat:[NZInputHandler sharedHandler].windowTime];
    settings[@"PerformanceMode"] = [NSNumber numberWithInt:[NZInputHandler sharedHandler].performanceMode];
    settings[@"WidthBase"] = [NSNumber numberWithFloat:[NZNotationDisplay sharedDisplay].widthBase];
    settings[@"Reverb"] = @([AudioPlayer sharedPlayer].reverb);
    settings[@"Chorus"] = @([AudioPlayer sharedPlayer].chorus);
    settings[@"ShowLyrics"] = @([PerformanceViewController sharedController].showLyrics);
    settings[@"NowLine"] = @([NZNotationDisplay sharedDisplay].mode);
    settings[@"VibratoEnabled"] = @([PitchBendWheel sharedWheel].enabled);
    settings[@"VelocitySensitivity"] = @([KeyboardView sharedView].velocitySensitivity);
    settings[@"BandVolume"] = @([NZInputHandler sharedHandler].bandVolume);
    settings[@"MicVolume"] = @([MicrophoneManager volume]);
    settings[@"AutoTempo"] = @([NZInputHandler sharedHandler].autoTempo);
    settings[@"MainVolume"] = @([AudioPlayer sharedPlayer].volume);
    settings[@"Metronome"] = @([NZInputHandler sharedHandler].metronomeEnabled);
    settings[@"MetronomeVolume"] = @([NZInputHandler sharedHandler].metronomeVolume);
    settings[@"PerformanceHighlights"] = @([NZNotationDisplay sharedDisplay].performanceHighlightingEnabled);
    return  settings;
}

+ (void) saveSettings {
    NSDictionary *settings = [self getSettings];
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:SETTINGS_KEY];
}

+ (void)loadSavedSettings {
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY];
    [self loadSettings:settings];
}


+ (void) loadSettings:(NSDictionary *)settings {
    if (settings) {
        [NZInputHandler sharedHandler].autoPedal = [settings[@"AutoPedal"] boolValue];
        [KeyboardView sharedView].UsePressure = [settings[@"Velocity"] boolValue];
        [NZInputHandler sharedHandler].magnifyUpcomingNotes = [settings[@"MagnifyUpcomingNotes"] boolValue];
        // [NZInputHandler sharedHandler].limitOneChordHighlightedAtATime = [settings[@"LimitOneChordAtATime"] boolValue];
        [NZInputHandler sharedHandler].windowTime = [settings[@"WindowTime"] floatValue];
        [NZInputHandler sharedHandler].performanceMode = [settings[@"PerformanceMode"] floatValue];
        [NZNotationDisplay sharedDisplay].widthBase = [settings[@"WidthBase"] floatValue];
        [AudioPlayer sharedPlayer].reverb = [settings[@"Reverb"] boolValue];
        [AudioPlayer sharedPlayer].chorus = [settings[@"Chorus"] boolValue];
        [PerformanceViewController sharedController].showLyrics = [settings[@"ShowLyrics"] boolValue];
        [[NZNotationDisplay sharedDisplay] setMode:[settings[@"NowLine"] intValue]];
        [KeyboardView sharedView].velocitySensitivity = [settings[@"VelocitySensitivity"] floatValue];
        [PitchBendWheel sharedWheel].enabled = settings[@"VibratoEnabled"] ? [settings[@"VibratoEnabled"] boolValue] : YES;
        [NZInputHandler sharedHandler].bandVolume = [settings[@"BandVolume"] floatValue];
        [MicrophoneManager setVolume:[settings[@"MicVolume"] floatValue]];
        [PerformanceViewController sharedController].showLyrics = [settings[@"ShowLyrics"] boolValue];
        [NZInputHandler sharedHandler].autoTempo = [settings[@"AutoTempo"] boolValue];
        [NZInputHandler sharedHandler].metronomeEnabled = [settings[@"Metronome"] boolValue];
        if (settings[@"MetronomeVolume"] != nil) {
            [NZInputHandler sharedHandler].metronomeVolume = [settings[@"MetronomeVolume"] floatValue];
        } else {
            [NZInputHandler sharedHandler].metronomeVolume = 0.5;
        }
        if (settings[@"PerformanceHighlights"] != nil) {
            [NZNotationDisplay sharedDisplay].performanceHighlightingEnabled = [settings[@"PerformanceHighlights"] boolValue];
        } else {
            [NZNotationDisplay sharedDisplay].performanceHighlightingEnabled = YES;
        }
    }
}

+ (void)loadArrangementSettings:(NSDictionary *)settings {
    if (!settings) settings = defaultSettings;
    if (settings) {
        [NZNotationDisplay sharedDisplay].widthBase = [settings[@"WidthBase"] floatValue];
        [NZInputHandler sharedHandler].bandVolume = [settings[@"BandVolume"] floatValue];
        float volume = [settings[@"MainVolume"] floatValue];
        if (volume > 0.1) {
            [AudioPlayer sharedPlayer].volume = volume;
        }
        [NZInputHandler sharedHandler].performanceMode = [settings[@"PerformanceMode"] intValue];
    } 
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NZEvents stopTimedFlurryEvent:@"Options screen opened"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NZEvents startTimedFlurryEvent:@"Options screen opened"];
}

# pragma mark - path
- (BOOL)pathPressed:(int)screen {
    switch (screen) {
        case PERFORMANCE:
            [self dismiss:nil];
            break;
        case OPTIONS:
            [self dismiss:nil];
            
            break;
        case ARRANGEMENT:
            [self dismiss:nil];
            [[PerformanceViewController sharedController] performSelector:@selector(showSongOptions) withObject:nil afterDelay:0.75];
            break;
        case STORE:
            [self dismiss:nil];
            [[PerformanceViewController sharedController] performSelector:@selector(showStore) withObject:nil afterDelay:0.75];
            break;
        case LIBRARY:
           [self dismiss:nil];
            [[PerformanceViewController sharedController] performSelector:@selector(showLibrary) withObject:nil afterDelay:0.75];
            break;
        case INSTRUMENTS:
            [self dismiss:nil];
            [[PerformanceViewController sharedController] performSelector:@selector(showInstruments) withObject:nil afterDelay:0.75];
            break;
        case COLLAB:
            return NO;
            break;
        case USER_GUIDE:
            [self dismiss:nil];
            [[PerformanceViewController sharedController] performSelector:@selector(showGuide) withObject:nil afterDelay:0.75];
            break;
            
        default:
            return nil;
            break;
    }
    return YES;
}

- (void)bandVolume:(id)sender {
    [NZInputHandler sharedHandler].bandVolume = bandVolumeSlider.value;
}

- (IBAction)toggleNowLine:(id)sender {
    int mode = nowLineSegControl.selectedSegmentIndex == 0 ? NOTATION_MOVING_NOW : NOTATION_STATIONARY_NOW;
    [[NZNotationDisplay sharedDisplay] setMode:mode];
}

- (void)autoPedal {
    [NZInputHandler sharedHandler].autoPedal = autoPedalSwitch.on;
}
- (IBAction)toggleVelocity {
    [KeyboardView sharedView].UsePressure = velocitySwitch.on;
}
- (IBAction)velocitySensitivityChanged:(id)sender {
    [KeyboardView sharedView].velocitySensitivity = velocitySensitivitySlider.value;
}
- (IBAction)upcomingNoteMode:(id)sender {
    [NZInputHandler sharedHandler].magnifyUpcomingNotes = upcomingNotesSetControl.selectedSegmentIndex != 2;
    [NZInputHandler sharedHandler].limitOneChordHighlightedAtATime = upcomingNotesSetControl.selectedSegmentIndex == 1;
}
- (IBAction)upcomingNoteRangeChanged:(id)sender {
    [NZInputHandler sharedHandler].windowTime = upcomingNoteRangeSlider.value;
    upcomingNoteLabel.text = [NSString stringWithFormat:@"%.2f s", upcomingNoteRangeSlider.value];
}
- (IBAction)togglePerformanceMode:(id)sender {
   // [NZInputHandler sharedHandler].performanceMode = performanceModeSegControl.selectedSegmentIndex;
}
- (void)metronome {
    [NZInputHandler sharedHandler].metronomeEnabled = metronmeSwitch.on;
}
- (IBAction)toggleMic {
    if (micSwitch.on) {
        if (![MicrophoneManager startPassthrough]) {
            [micSwitch setOn:NO];
            
        } else {
            
        }
    } else {
        [MicrophoneManager stop];
    }
    [[PerformanceViewController sharedController] setMic:[MicrophoneManager isOn]];
}
- (IBAction)micVolumeChanged:(id)sender {
    [MicrophoneManager setVolume:micVolumeSlider.value];
}
- (void)reverb {
        [AudioPlayer sharedPlayer].reverb = reverbSwitch.on;
}

- (void)chorus {
    [AudioPlayer sharedPlayer].chorus = chorusSwitch.on;
}

- (void)noteWidth:(id)sender {
  //  [NZNotationDisplay sharedDisplay].widthBase = noteWidthSlider.value * 100;
    noteWidthLabel.text = [NSString stringWithFormat:@"%.1f", noteWidthSlider.value];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    page1.backgroundColor = page2.backgroundColor = [UIColor clearColor];
    page2.hidden = YES;
	
    autoPedalSwitch.target = self;
    autoPedalSwitch.selector = @selector(autoPedal);
    micSwitch.target = self;
    micSwitch.selector = @selector(toggleMic);
    velocitySwitch.target = self;
    velocitySwitch.selector = @selector(toggleVelocity);
    highlightSwitch.target = self;
    highlightSwitch.selector = @selector(toggleHighlight);
    lyricsSwitch.target = self;
    lyricsSwitch.selector = @selector(toggleLyrics);
    vibratoSwitch.target = self;
    vibratoSwitch.selector = @selector(toggleVibrato);
    
    chorusSwitch.target = reverbSwitch.target = self;
    chorusSwitch.selector = @selector(chorus);
    reverbSwitch.selector = @selector(reverb);
    metronmeSwitch.target = self;
    metronmeSwitch.selector = @selector(metronome);
    
    performanceHighlightSwitch.target = self;
    performanceHighlightSwitch.selector = @selector(performanceHighlight);
}

- (void) performanceHighlight {
    [NZNotationDisplay sharedDisplay].performanceHighlightingEnabled = performanceHighlightSwitch.on;
}

- (void)showHelp:(id)sender {
    [NZEvents startTimedFlurryEvent:@"Options help shown"];
    [self presentHelp];
}

- (void)presentHelp {
    if (!helpView) {
        if (tabSegControl.selectedSegmentIndex == 0) {
            helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-options-1.png"]];
        } else {
            helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-options-2.png"]];
        }
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
     [NZEvents stopTimedFlurryEvent:@"Options help shown"];
    [UIView transitionWithView:helpView duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^(void) {
        helpView.alpha = 0;
    }completion:^(BOOL finished ) {
        [helpView removeFromSuperview];
        helpView = nil;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
