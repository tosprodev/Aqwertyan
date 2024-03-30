//
//  MIDIPlayerViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/18/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "HUDViewController.h"

@interface MIDIPlayerViewController : HUDViewController

@property (nonatomic) IBOutlet UISlider *seekSlider, *volumeSlider;
@property (nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic) IBOutlet UILabel *currentTimeLabel, *totalTimeLabel;


- (IBAction)playTapped:(id)sender;
- (IBAction)seek:(id)sender;
- (IBAction)volume:(id)sender;

- (void) finish;

- (NSString *)songToPlay; // override this

@end
