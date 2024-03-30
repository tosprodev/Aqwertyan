//
//  MIDIPlayerViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/18/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "MIDIPlayerViewController.h"
#import "AudioPlayer.h"
#import "SongOptions.h"


@interface MIDIPlayerViewController () {
   
}
 @property IBOutlet UIBarButtonItem *stopButton;

@end



@implementation MIDIPlayerViewController {
    unsigned long totalTicks;
    unsigned short division;
    NSTimer *theTimer;
    int updateLabel;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)playTapped:(id)sender {
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSong:) object:nil];
    if (_playButton.selected) {
        [theTimer invalidate];
        _playButton.selected = NO;
        [[AudioPlayer sharedPlayer] stopPlaying];
    } else {
        if ([AudioPlayer sharedPlayer].isPlaying) {
            _playButton.selected=YES;
            [self performSelector:@selector(playSong:) withObject:[self songToPlay] afterDelay:1];
        } else {
            [self playSong:[self songToPlay]];
        }
    }
}

- (void) startPlaying {
    
}


- (void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    _volumeSlider.minimumValue = [AudioPlayer sharedPlayer].minVolume;
    _volumeSlider.maximumValue = [AudioPlayer sharedPlayer].maxVolume;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[AudioPlayer sharedPlayer] setPlayerVolume:_volumeSlider.value];
    });
    _volumeSlider.value = [SongOptions volume];
    [[AudioPlayer sharedPlayer] stopPlaying];
    [[AudioPlayer sharedPlayer] setMidiFile:nil];
    _seekSlider.minimumValue = 0;
    _seekSlider.maximumValue = 1;
    _seekSlider.value = 0;
    _currentTimeLabel.text = _totalTimeLabel.text = @"0:00";
    _playButton.selected = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AudioPlayer sharedPlayer] stopPlaying];
    [[AudioPlayer sharedPlayer] setMidiFile:nil];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         [[AudioPlayer sharedPlayer] setPlayerVolume:[AudioPlayer sharedPlayer].maxVolume];
    });
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_playButton addTarget:self action:@selector(playTapped:) forControlEvents:UIControlEventTouchDown];
    [_seekSlider addTarget:self action:@selector(seek:) forControlEvents:UIControlEventValueChanged];
    [_volumeSlider addTarget:self action:@selector(volume:) forControlEvents:UIControlEventValueChanged];
    _seekSlider.continuous = NO;
    
    UIImage *thumb = [UIImage imageNamed:@"st-slider-handle-centered.png"];
    [_volumeSlider setThumbImage:thumb forState:UIControlStateNormal];
    [_volumeSlider setMinimumTrackImage:[UIImage imageNamed:@"st-slider-fill-horizontal.png"] forState:UIControlStateNormal];
    [_volumeSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    
    [_seekSlider setThumbImage:thumb forState:UIControlStateNormal];
    [_seekSlider setMinimumTrackImage:[UIImage imageNamed:@"st-slider-fill-horizontal.png"] forState:UIControlStateNormal];
    [_seekSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    _volumeSlider.minimumValue = [AudioPlayer sharedPlayer].minVolume;
    _volumeSlider.maximumValue = [AudioPlayer sharedPlayer].maxVolume;

}



- (void)volume:(id)sender {
    [AudioPlayer sharedPlayer].playerVolume = _volumeSlider.value;
    [SongOptions setVolume:_volumeSlider.value];
}

- (void) playSong:(NSString *)songPath {
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPlayingSong:) object:nil];
    if (songPath == nil) {
        _playButton.selected = NO;
        return;
    }

    if ([[AudioPlayer sharedPlayer].midiFile isEqualToString:songPath]) {
        
    } else {
        
        [[AudioPlayer sharedPlayer] setMidiFile:songPath];
        [_seekSlider setValue:0];
    }
    [[AudioPlayer sharedPlayer] getInfo:&totalTicks dvision:&division];
    NSString *time = [NSString stringWithFormat:@"%ld:%02ld", [AudioPlayer sharedPlayer].totalTime/60,[AudioPlayer sharedPlayer].totalTime%60];
    _totalTimeLabel.text = time;
    if (totalTicks == 0 || division == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"This midi file is invalid" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        _playButton.selected = NO;
        
    } else {
        [_seekSlider setMaximumValue:(double)totalTicks * 24.0 / (double)division];
        
        _seekSlider.userInteractionEnabled = YES;
        
        [self startTimer];
        [[AudioPlayer sharedPlayer] startPlaying];
        
        _playButton.selected = YES;
    }
    

}



- (void) startTimer {
    if (theTimer) {
        [theTimer invalidate];
    }
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        theTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        updateLabel = 0;
    });
    
    
}

- (void) updateSlider {
    if (++updateLabel%5 == 0) {
        NSString *time = [NSString stringWithFormat:@"%d:%02d", (int)[AudioPlayer sharedPlayer].currentTime/60,(int)[AudioPlayer sharedPlayer].currentTime%60];
        _currentTimeLabel.text = time;
    }
    if (_seekSlider.touchInside) {
        return;
    }
    [_seekSlider setValue:[AudioPlayer sharedPlayer].clocks];
    if (_seekSlider.value >= _seekSlider.maximumValue) {
        [theTimer invalidate];
        [self performSelector:@selector(finish) withObject:nil afterDelay:0.2];
    }
    
}

- (void) finish {
    NSLog(@"done");
    _playButton.selected = NO;
    [[AudioPlayer sharedPlayer] stopPlaying];
    [[AudioPlayer sharedPlayer] seek:0];
    [_seekSlider setValue:0];
    [theTimer invalidate];
    _currentTimeLabel.text = @"0:00";
}

- (void)seek:(id)sender {
	unsigned long tick = _seekSlider.value * division / 24;
	NSLog (@"seek %lu tick = %.0f MIDI clocks", tick, _seekSlider.value);
    [[AudioPlayer sharedPlayer] seek:tick];
    if (theTimer) {
        [self startTimer];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
