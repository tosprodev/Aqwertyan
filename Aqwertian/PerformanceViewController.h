//
//  ViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/2/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExternalMIDIManager.h"
#import "AwesomeMenu/AwesomeMenu.h"
#import "PathButton.h"
#import "Arrangement.h"
#import <MessageUI/MessageUI.h>

#define DONT_SHOW_QUICK_START_KEY @"dontShowQuickStart12"

@interface PerformanceViewController : UIViewController <UIAlertViewDelegate, MIDIManagerDelegate, AwesomeMenuDelegate, UITextFieldDelegate, PathButtonDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) BOOL showLyrics;

+ (PerformanceViewController *)sharedController;
- (void) loadCurrentSong;
- (void) dismissLibraryController:(BOOL)needsOptions newFile:(BOOL)newFile;
- (void) showLibrary;
- (void) showStore;
- (void) showGuide;
- (void) dismissGuide;
- (void) dismissStore:(BOOL)animated;
- (void) showSongOptions;
- (void) dismissSongOptions;
- (void) showInstruments;
- (void) showOptions;
- (void) showQuickStart;
- (void) dismissQuickStart;
- (void) clear;
- (void) saveArrangementWithName:(NSString *)name;
- (void) showPreviewForStore:(NSString *)path;
- (void) willResignActive;
- (void) showIntro;
- (void) dismissStoreAndPerformCurrentSong;

- (void) notationDisplayReady;
- (void) performanceDidStart;

- (void) performanceFinished;
- (Statistics *)currentStats;
- (void) regainKeyboardControl;
- (void) updateProgram:(int)program forChannel:(int)channel;
- (void) setProgram:(int)program;
- (void) setMic:(BOOL)mic;
- (void) setMidiIn:(BOOL)midiIn;
- (void) resetProgram;

- (void) setMidiOut:(BOOL)midiOut;

- (void)willReappear;
- (void) alertWaiting:(int)ticks;

- (void) dismissStats;

- (void) tempoDidChange;


@end
