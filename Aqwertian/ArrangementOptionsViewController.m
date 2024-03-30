//
//  ArrangementOptionsViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 6/22/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "ArrangementOptionsViewController.h"
#import "SongOptions.h"
#import "AQSwitch.h"

@interface ArrangementOptionsViewController ()

@property (nonatomic) IBOutlet UISegmentedControl *keyboardTypeSegControl, *noteModeSegControl;
@property (nonatomic) IBOutlet AQSwitch *twoLineSwitch, *chordingSwitch;
@property (nonatomic) IBOutlet UIImageView *keyboardSeg1, *keyboardSeg2, *keyboardSeg3;
@property (nonatomic) IBOutlet UIImageView *twoLineSeg1, *twoLineSeg2;

- (IBAction)switchKeyboard:(id)sender;
- (IBAction)switchTwoLine:(id)sender;

@end

@implementation ArrangementOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)switchKeyboard:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    int index = seg.selectedSegmentIndex;
    
    _keyboardSeg1.image = index == 0 ? [UIImage imageNamed:@"option-segment-3-left-sel.png"] : [UIImage imageNamed:@"option-segment-3-left.png"];
    _keyboardSeg2.image = index == 1 ? [UIImage imageNamed:@"option-segment-3-middle-sel.png"] : [UIImage imageNamed:@"option-segment-3-middle.png"];
    _keyboardSeg3.image = index == 2 ? [UIImage imageNamed:@"option-segment-3-right-sel.png"] : [UIImage imageNamed:@"option-segment-3-right.png"];
}

- (void)switchTwoLine:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    int index = seg.selectedSegmentIndex;
    
    _twoLineSeg1.image = index == 0 ? [UIImage imageNamed:@"op-choice-1-pressed.png"] : [UIImage imageNamed:@"op-choice-1.png"];
    _twoLineSeg2.image = index == 1 ? [UIImage imageNamed:@"op-choice-2-pressed.png"] : [UIImage imageNamed:@"op-choice-2.png"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFromSongOptions];
}

- (void) loadFromSongOptions {
    _keyboardTypeSegControl.selectedSegmentIndex = [SongOptions keyboardType];
    _chordingSwitch.on = [SongOptions isChorded];
    _twoLineSwitch.on = [SongOptions isTwoRow];
    _noteModeSegControl.selectedSegmentIndex = [SongOptions isExmatch] ? 0 : 1;
}

- (void) saveToSongOptions {
    [SongOptions setKeyboardType:_keyboardTypeSegControl.selectedSegmentIndex];
    [SongOptions setChorded:_chordingSwitch.on];
    [SongOptions setTwoRow:_twoLineSwitch.on];
    [SongOptions setExmatch:_noteModeSegControl.selectedSegmentIndex == 0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveToSongOptions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
