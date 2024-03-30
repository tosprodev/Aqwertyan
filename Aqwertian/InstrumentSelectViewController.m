//
//  InstrumentSelectViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/19/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "InstrumentSelectViewController.h"
#import "InstrumentCell.h"
#import "AudioPlayer.h"
#import "ScrollPaperTableView.h"
#import "PerformanceViewController.h"
#import "NZInputHandler.h"
#import "NZEvents.h"

@interface InstrumentSelectViewController ()

@property (nonatomic) IBOutlet ScrollPaperTableView *leftTableView, *rightTableView;
@property (nonatomic) IBOutlet UIButton *listenButton;
@property (nonatomic) IBOutlet UISlider *volumeSlider;

- (IBAction)listenTapped:(id)sender;
- (IBAction)performTapped:(id)sender;
- (IBAction)volume:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)showHelp:(id)sender;

@end

@implementation InstrumentSelectViewController {
    NSArray *categories;
    NSArray *instruments;
    int currentCategory;
    NSMutableArray *programs, *percussion;
    UIImageView *helpView;
    int currentNote, previousNote;
    BOOL up;
    NSTimer *timer;
    int originalPrograms[16];
}

# pragma mark - path
- (BOOL)pathPressed:(int)screen {
    [self stop];
    [[AudioPlayer sharedPlayer] unplayNote:previousNote onChannel:0];
    for (int i = 0; i < 16; i++) {
        [[AudioPlayer sharedPlayer] setProgram:originalPrograms[i] forChannel:i];
    }
    
    switch (screen) {
        case PERFORMANCE:
            [self dismiss:nil];
            break;
        case OPTIONS:
            [self dismiss:nil];
            [[PerformanceViewController sharedController] performSelector:@selector(showOptions) withObject:nil afterDelay:0.75];
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
            return NO;
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NZEvents stopTimedFlurryEvent:@"Instruments screen opened"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     [NZEvents startTimedFlurryEvent:@"Instruments screen opened"];
}

- (void)volume:(id)sender {
    [[AudioPlayer sharedPlayer] setVolume:_volumeSlider.value];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)performTapped:(id)sender {
    NSString *programName = [[AudioPlayer sharedPlayer] getCurrentProgram:0];
    if (currentCategory > -1 && _rightTableView.indexPathForSelectedRow) {
        [self stop];
        [[AudioPlayer sharedPlayer] unplayNote:previousNote onChannel:0];
        for (int i = 0; i < 16; i++) {
            [[AudioPlayer sharedPlayer] setProgram:originalPrograms[i] forChannel:i];
        }
        [[PerformanceViewController sharedController] setProgram:currentCategory*8 + _rightTableView.indexPathForSelectedRow.row];
        [[NZInputHandler sharedHandler] userDidChangeProgram];
        [self dismiss:nil];
    }
    [NZEvents logEvent:@"Instrument selected" args:@{@"Instrument" : programName}];
}

- (void)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)listenTapped:(id)sender {
    if (!_rightTableView.indexPathForSelectedRow) return;
    _listenButton.selected = !_listenButton.selected;
    if (!_listenButton.selected) {
        [self stop];
    } else {
        [self play];
    }
}

- (void) stop {
    [timer invalidate];
     [[AudioPlayer sharedPlayer] unplayNote:previousNote onChannel:0];
    timer = nil;
}

- (void) play {
    if (!_rightTableView.indexPathForSelectedRow) return;
    [NZEvents logEvent:@"Instrument preview playing" args:@{@"Instrument" : @(currentCategory*8 + _rightTableView.indexPathForSelectedRow.row)}];
    [[AudioPlayer sharedPlayer] setProgram:currentCategory*8 + _rightTableView.indexPathForSelectedRow.row forChannel:0];
    
    currentNote = previousNote = 60;
    up = YES;
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void) timerTick:(id)timer {
    [[AudioPlayer sharedPlayer] unplayNote:previousNote onChannel:0];
    [[AudioPlayer sharedPlayer] playNote:currentNote onChannel:0 withVelocity:127/2];
    [self incrementNote];
    
}

- (void) incrementNote {
    previousNote = currentNote;
    if (currentNote == 72) {
        up = NO;
    } else if (currentNote == 60) {
        up = YES;
    }
    if (up) {
        if (currentNote == 64 || currentNote == 71) {
            currentNote++;
        } else {
            currentNote += 2;
        }
    } else {
        if (currentNote == 65 || currentNote == 72) {
            currentNote--;
        } else {
            currentNote -= 2;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _leftTableView.prefix = _rightTableView.prefix = @"il";
    if (!programs) {
        [self loadProgramNames];
    }
    for (int i = 0; i < 16; i++) {
        originalPrograms[i] = [[AudioPlayer sharedPlayer] getProgramNumber:i];
    }
    _volumeSlider.value = [AudioPlayer sharedPlayer].volume;
    [[AudioPlayer sharedPlayer] reset];
}

- (void) loadProgramNames {
    programs = [NSMutableArray new];
    percussion = [NSMutableArray new];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"program_names" ofType:@"txt"];
    NSString* contents =
    [NSString stringWithContentsOfFile:path
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* lines = [contents componentsSeparatedByCharactersInSet:
                      [NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        int i;
        for (i = 0; i < line.length; i++) {
            if ([line characterAtIndex:i] == ' ')
                break;
        }
        NSString *theName = [line substringFromIndex:i+1];
        //   NSLog(theName);
        [programs addObject:theName];
    }
    
    for (int i =0; i < 33; i++) {
        [percussion addObject:@"Percussion"];
    }
    path = [[NSBundle mainBundle] pathForResource:@"percussion_names" ofType:@"txt"];
    contents =
    [NSString stringWithContentsOfFile:path
                              encoding:NSUTF8StringEncoding error:nil];
    lines = [contents componentsSeparatedByCharactersInSet:
             [NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        int i;
        for (i = 0; i < line.length; i++) {
            if ([line characterAtIndex:i] == ' ')
                break;
        }
        NSString *theName = [line substringFromIndex:i+1];
        //  NSLog(theName);
        [percussion addObject:theName];
    }
}
/*
 -8	 Piano 	 65-72 	 Reed
 9-16	 Chromatic Percussion	 73-80	 Pipe
 17-24	 Organ	 81-88	 Synth Lead
 25-32	 Guitar	 89-96	 Synth Pad
 33-40	 Bass	 97-104	 Synth Effects
 41-48	 Strings	 105-112	 Ethnic
 49-56	 Ensemble	 113-120	 Percussive
 57-64 	 Brass 	 121-128 	 Sound Effects
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    _leftTableView.delegate = _rightTableView.delegate = self;
    _leftTableView.dataSource = _rightTableView.dataSource = self;
    categories = @[@"Piano", @"Chromatic Percussion", @"Organ", @"Guitar", @"Bass", @"Strings", @"Ensemble", @"Brass", @"Reed", @"Pipe", @"Synth Lead", @"Synth Pad", @"Synth Effects", @"Ethnic", @"Percussive", @"Sound Effects"];
    instruments = @[@[@"Sample1", @"Sample2", @"Sample3"],@[@"Sample1", @"Sample2", @"Sample3"],@[@"Sample1", @"Sample2", @"Sample3"]];
    currentCategory = -1;
    [_leftTableView reloadData];
    
    categories = [categories mutableCopy];
    for (int i = 0; i < categories.count; i++) {
        [(NSMutableArray *)categories replaceObjectAtIndex:i withObject:[categories[i] uppercaseString]];
    }
    
    _leftTableView.backgroundColor = _rightTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"il-paper.png"]];
    
    _volumeSlider.minimumValue = [AudioPlayer sharedPlayer].minVolume;
    _volumeSlider.maximumValue = [AudioPlayer sharedPlayer].maxVolume;
    
    UIImage *thumb = [UIImage imageNamed:@"st-slider-handle-centered.png"];
    [_volumeSlider setThumbImage:thumb forState:UIControlStateNormal];
    [_volumeSlider setThumbImage:thumb forState:UIControlStateHighlighted];
    [_volumeSlider setMinimumTrackImage:[UIImage imageNamed:@"st-slider-fill-horizontal.png"] forState:UIControlStateNormal];
    [_volumeSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _leftTableView) {
        return [categories count];
    } else {
        if ([_leftTableView indexPathForSelectedRow]) {
            return 8;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _leftTableView) {
        currentCategory = indexPath.row;
        [_rightTableView reloadData];
    } else {
        if (timer && _listenButton.selected) {
            [self play];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InstrumentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Instrument"];
    
    if (tableView == _leftTableView) {
        cell.textLabel.text = categories[indexPath.row];
    } else {
        int start = currentCategory * 8;
        cell.textLabel.text = programs[start + indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _leftTableView) {
        [_leftTableView didScroll];
    } else {
        [_rightTableView didScroll];
    }
}

- (void)showHelp:(id)sender {
    [NZEvents startTimedFlurryEvent:@"Instruments help shown"];
    [self presentHelp];
}

- (void) presentHelp {
    if (!helpView) {
        
        helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-instruments.png"]];
        
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void) hideHelp {
    [NZEvents stopTimedFlurryEvent:@"Instruments help shown"];
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
