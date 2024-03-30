//
//  SongOptionsViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIDIPlayerViewController.h"
#import "PathButton.h"
#import "SongOptions.h"
@interface SongOptionsViewController : MIDIPlayerViewController <UIAlertViewDelegate, PathButtonDelegate>

@property (strong) NSString *MidiFile;
@property BOOL isForStore;
@property NSString *songPath;
@property (nonatomic) BOOL exmatch, chorded, twoRow;
@property (nonatomic) KeyboardType keyboardType;

+ (SongOptionsViewController *) sharedController;

- (void) displayMidiFile:(NSString *)aPath;



@end
