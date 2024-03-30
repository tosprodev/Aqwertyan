//
//  NZInputHandler.m
//  Aqwertyan
//
//  Created by Nathan Ziebart on 1/9/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "NZInputHandler.h"
#import "MusicFile.h"
#import "AudioPlayer.h"
#import "NZNotationDisplay.h"
#import "NoteView.h"
#import "LyricView.h"
#import <QuartzCore/QuartzCore.h>
#import "KeyboardView.h"
#import "PerformanceViewController.h"
#import "NZEvents.h"
#import <AVFoundation/AVFoundation.h>

#define HIGHLIGHT_TIME_BASE 0.25

static SystemSoundID metronomeSoundID;
static AVAudioPlayer *_inputHandlerPlayer;

@implementation NZInputHandler {
    NSArray *_userNotes, *_bandNotes, *_specialEvents;
    int _ticks, _realTicks;
    NSTimer *timer;
    AudioPlayer *_player;
    BOOL userIsStuck;
    NSTimeInterval stuckTime;
    NSTimeInterval tickTime;
    NSTimer *seekTimer;
    BOOL _doProgramChanges;
    BOOL settingTicks;
    
    double _steadyRate;
    
    int _iCurrentChord, _iCurrentEvent, _iBandNote, _iAutoPlay;
    
    RGNote *_currentChord[20], *_lastPlayedNote;
    int _notesInCurrentChord;
    
    NSMutableArray *_highlightedNotes;
    NSMutableSet *_userPlayingNotes, *_bandPlayingNotes, *_autoOffNotes;
    
    NZNotationDisplay *notationDisplay;
    
    BOOL handleTime;
    
    int _autoplayHint;
    int _rate;
    float _tempoMultiplier;
    
    int _windowStart, _windowStop;

    float _windowSize;
    
    float tempo;
    float tempoMultiplier;
    float secondsPerBeat;
    
    float originalTempo;
    
    KeyboardView *_keyboard;
    float interval;
    
    float avg;
    int avgCount;
    
    NSMutableIndexSet *userChannels;
    NSMutableArray *_expectedNotes;
    
    int _timerCount;
    
    void (^metronomeTick)();
}

# pragma mark - initialization

+ (NZInputHandler *)sharedHandler {
    static NZInputHandler *handler = nil;
    if (!handler) handler = [NZInputHandler new];
    return handler;
}

+ (void)initialize {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"HiHat3"
//                                                     ofType:@"aiff"];
//    
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path]
//                                     , &metronomeSoundID);
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"HiHat3" ofType:@"aiff"];
    NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
    _inputHandlerPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
}

- (void)setMetronomeVolume:(float)metronomeVolume {
    _inputHandlerPlayer.volume = metronomeVolume;
}

- (float)metronomeVolume {
    return _inputHandlerPlayer.volume;
}

- (id)init {
    self = [super init];
    if (self) {
        _highlightedNotes = [NSMutableArray new];
        _userPlayingNotes = [NSMutableSet new];
        _bandPlayingNotes = [NSMutableSet new];
        userChannels = [NSMutableIndexSet new];
        _autoOffNotes = [NSMutableSet new];
        _windowTime = 0.75;
        _limitOneChordHighlightedAtATime = YES;
        _exmatch = YES;
        _key = 0;
        _userDrivenWindowTime = 0.3;
        _magnifyUpcomingNotes = YES;
        _performanceMode = PERFORMANCE_USER_DRIVEN;
        _tempoFactor = 1;
        _volumeMultiplier = 1;
        _autoPedal=NO;
        _bandVolume = 0.86;
        _autoTempo = NO;
        _seekIncrement = 20;
        _expectedNotes = @[].mutableCopy;
        _metronomeEnabled = NO;
    }
    return self;
}

# pragma mark - configuration properties

- (void)setWindowTime:(float)windowTime {
    _windowTime = windowTime;
    tempo = -1;
}

- (void)setPerformanceMode:(int)performanceMode {
    _performanceMode = performanceMode;
    [self restart];
}

- (void)setKey:(int)key {
    if (key > 5) key = 5;
    if (key < -5) key = -5;
    _key = key;
}

- (void)setAutoplaying:(BOOL)autoplaying {
    BOOL changed = autoplaying != _autoplaying;
    [self willChangeValueForKey:@"autoplaying"];
    _autoplaying = autoplaying;
    [self didChangeValueForKey:@"autoplaying"];
    if (autoplaying) {
        _iAutoPlay = _iCurrentChord;
        if (changed) {
            [NZEvents startTimedFlurryEvent:@"Autoplaying"];
        }
        //self.tempoFactor = 1;
        //[[PerformanceViewController sharedController] tempoDidChange];
    } else {
        if (changed) {
            [NZEvents stopTimedFlurryEvent:@"Autoplaying"];
        }
        for (RGNote *n in _userPlayingNotes) {
            [[KeyboardView sharedView] noteOff:n.qwerty];
            [_autoOffNotes addObject:n];
        }
    }
}

# pragma mark - timing properties

- (int)totalSeconds {
    return (int)(0.5 + (_song.totalTicks / _steadyRate));
}

- (int)currentSeconds {
    return (int)(0.5 + _ticks / _steadyRate);

}

- (void) setMetronomeTickHandler:(void(^)())handler {
    metronomeTick = [handler copy];
}

- (int)currentTicks {
    return _ticks;
}

- (double)ticksPerSecond {
    return (double)_rate;
}

- (int)stopTicks {
    if (!_autoplaying && _notesInCurrentChord) {
        if (_ticks == 0) return 0;
        return _currentChord[0].time;
    }
    return _song.totalTicks;
}

- (int)startTicks {
    return _lastPlayedNote.time;
}

# pragma mark - song properties

- (NSArray *)notes {
    return _song.soloNotes;
}

- (void) stopTimer {
    [timer invalidate];
}

- (void)setSong:(Song *)song isSamePiece:(BOOL)same {
    [_player reset];
    _timerCount = 0;
    int i = 0;
    for (RGNote *n in song.soloNotes) {
        n.state = NOT_PLAYED;
        n.timePlayed = -1;
        n.autoPlayed = NO;
        n.index = i;
        i++;
    }
    
    _isFinished = NO;
    if (_userNotes == song.soloNotes) {
        
    } else if (song == nil) {
        _userNotes = nil;
    }
    
    if (!same && _userNotes != song.soloNotes) {
        _doProgramChanges=YES;
    }
    
    [userChannels removeAllIndexes];
    NSArray *channels = [SongOptions activeChannels];
    for (NSNumber *channel in channels) {
        [userChannels addIndex:channel.intValue];
    }
    
    _userNotes = song.soloNotes;
    _bandNotes = song.bandNotes;
    _specialEvents = song.specialEvents;
    _song = song;
    
    notationDisplay = [NZNotationDisplay sharedDisplay];
    notationDisplay.exmatch = _exmatch;
    notationDisplay.isTwoRow = [SongOptions isTwoRow];
    [notationDisplay displayNotes:_userNotes lyrics:song.lyrics];
    
    handleTime = YES;
    
    _ticks = _realTicks = 0;
    userIsStuck = NO;
    stuckTime = 0;
    
    _player = [AudioPlayer sharedPlayer];
    
    _iCurrentChord = 0;
    _iCurrentEvent = 0; _iAutoPlay = 0; _iBandNote = 0;
    _notesInCurrentChord = 0;
    [_highlightedNotes removeAllObjects];
    [_userPlayingNotes removeAllObjects];
    [_bandPlayingNotes removeAllObjects];
    [_autoOffNotes removeAllObjects];
    
    [self stopTimer];
    
    _windowStop = _windowStart = 0;
    
    _rate = 1000000.0 * (double)song.division / 500000.0;

    
    _keyboard = [KeyboardView sharedView];
    [_keyboard reset];
    _lastPlayedNote = nil;
    _wrongNotes = 0;
    
    [self _moveToNextChord];
    [self updateNotesToPlayWindow];
    [self processEvents];
    [self pause];
    
        _steadyRate = _rate;
}

# pragma mark - start/stop

- (void) start {
    _player.muted = NO;
    self.fastForwarding = self.rewinding = NO;
    [self setupTimer];
}

- (void) restart {
    [self setSong:_song isSamePiece:YES];
    [[PerformanceViewController sharedController] resetProgram];
}

- (void) setupTimer {
    [self stopTimer];
    if (self.song) {
        interval = (24.0/(double)_song.division) * _rate * _tempoFactor;
        interval = 1.0/interval;
        timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
        _tempoMultiplier = _tempoFactor;
        self.isPaused = NO;
    }
}

- (void)pause {
    [self willChangeValueForKey:@"isPaused"];
    _isPaused = YES;
    [self didChangeValueForKey:@"isPaused"];
    self.fastForwarding = self.rewinding = NO;
    [self stopTimer];
    [_player attenuate:0.66];
}

# pragma mark - special MIDI events

- (void) pedal:(int)channel note:(int)note velocity:(int)vel {
    BOOL userChannel = [userChannels containsIndex:channel];

    if (_autoplaying || (userChannel && _autoPedal)) {
        [_player pedal:channel note:note velocity:vel];
        if (vel > 0) {
            [_keyboard noteOn:' '];
        } else {
            [_keyboard noteOff:' '];
        }
    }
}

- (void) changeTempo:(int)newTempo {
    _rate = 1000000.0 * (double)_song.division / (double)newTempo;
    if (!self.isPaused) {
        [self setupTimer];
    }
}

- (void) changeProgram:(int)program channel:(int)channel {
    if (_doProgramChanges || ![userChannels containsIndex:channel]) {
        [_player setProgram:program forChannel:channel];
        [[PerformanceViewController sharedController] updateProgram:program forChannel:channel];
    }
}

- (void)userDidChangeProgram {
    _doProgramChanges=NO;
}


# pragma mark - performance and synchronization

- (void) _timerTick {
    CFTimeInterval now = CACurrentMediaTime();
    
    // User driven mode
    if (_performanceMode == PERFORMANCE_USER_DRIVEN) {
        
        // Autoplaying
        if (_autoplaying) {
            [self incrementTicks];
            [self processAutoOffNotes];
            [self processAutoPlay];
            [self processBandNotes];
            [self processEvents];
            [self updateNotesToPlayWindow];
            
        // Not autoplaying
        } else {
            
            if (!_notesInCurrentChord || [_currentChord[0] time] > _ticks) {
                [self incrementTicks];
                [self processAutoOffNotes];
                [self processBandNotes];
                [self processEvents];
                [self updateNotesToPlayWindow];
                userIsStuck = NO;
                
            // If the user is stuck on a note, we don't increment the ticks
            } else {
                if (!userIsStuck) {
                    userIsStuck = YES;
                    stuckTime = CACurrentMediaTime();
                    originalTempo = _tempoFactor;
                }
                CFTimeInterval time = CACurrentMediaTime();
                if (time - stuckTime > 1 && ![_keyboard pedalIsOn]) {
                    BOOL attenuate = YES;
                    for (RGNote *n in _userPlayingNotes) {
                        if (!n.tie) {
                            attenuate = NO;
                            break;
                        }
                    }
                    
                    if (attenuate) {
                        [_player attenuate:1];
                    }
                }
                if (_autoTempo && time - stuckTime > 0.2 && _iCurrentChord > 0) {
                    float newTempo = originalTempo * MAX(0.85, 1 - (0.15 * ((time - stuckTime)/2.0)));
                    if (ABS (newTempo - _tempoFactor) > 0.01) {
                        self.tempoFactor = newTempo;
                        [[PerformanceViewController sharedController] tempoDidChange];
                    }
                }
                if (_iCurrentChord > 0) {
                    
                    _realTicks += _song.division/24;
                    if ((_realTicks - _ticks) * secondsPerBeat) {
                        
                    }
                }
            }
        }
        
        // Band driven mode
    } else {
        [self incrementTicks];
        
        
        // Autoplaying
        if (_autoplaying) {
            [self processAutoOffNotes];
            [self processAutoPlay];
            [self processBandNotes];
            [self processEvents];
            [self updateNotesToPlayWindow];
            
            // Not autoplaying
        } else {
            [self processAutoOffNotes];
            [self processBandNotes];
            [self processEvents];
            [self updateNotesToPlayWindow];
        }
    }
    
    // Check if the tempo has been adjusted
    if (_tempoMultiplier != _tempoFactor) {
        [self setupTimer];
    }
    
    // Check if we are finished
    if (_ticks >= _song.totalTicks && !_isFinished) {
        if (!_userPlayingNotes.count) {
            [self finish];
        }
    }
    
//    CFTimeInterval diff = CACurrentMediaTime() - now;
//    if (diff > interval/2.0) {
//       // NSLog(@"TOOK TOO LONG %f -- %f", diff * 1000, interval * 1000);
//    }
//    avg += diff;
//    if (avgCount % 50 == 0) {
//          // NSLog(@"%f", avg/(float)avgCount * 1000);
//        avg = avgCount = 0;
//    }
//    avgCount++;
    
    if (_metronomeEnabled) {
        if (_timerCount % 24 == 0) {
            playMetronomeSound();
            if (metronomeTick) {
                metronomeTick();
            }
        }
    }
    _timerCount++;
}

void playMetronomeSound() {
    [_inputHandlerPlayer play];
}

- (void) processEvents {
    while (_iCurrentEvent < _specialEvents.count) {
        SpecialEvent *e = _specialEvents[_iCurrentEvent];
        if (e.time <= _ticks) {
            if (e.type == SpecialEventTypeTempoChange) {
                [self changeTempo:e.value];
            } else if (e.type == SpecialEventTypeProgramChange) {
                [self changeProgram:e.value channel:e.channel];
            } else if (e.type == SpecialEventTypePedal) {
                [self pedal:e.channel note:e.value velocity:e.value2];
            }
            _iCurrentEvent++;
        } else {
            break;
        }
    }
}

- (void) processBandNotes {
    int time = (_lastPlayedNote && !_autoplaying && _performanceMode==PERFORMANCE_USER_DRIVEN && _lastPlayedNote.time > _ticks) ? _lastPlayedNote.time : _ticks;
    
    if (_iBandNote >= _bandNotes.count) {
        return;
    }
    
    // Turn off notes that have expired
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:_bandPlayingNotes.count];
    NSMutableArray *userToRemove = [NSMutableArray new];
    for (RGNote *n in _bandPlayingNotes) {
        if (n.time + n.duration <= time) {
//            if (n.removedFromUserNotes) {
//                [userToRemove addObject:n];
//            } else {
                [toRemove addObject:n];
          //  }
        }
    }
    for (RGNote *n in toRemove) {
        [self bandNoteOff:n];
    }
    for (RGNote *n in userToRemove) {
        [self turnOffNote:n withAudio:YES isTie:YES hint:nil handleKey:NO];
    }
    
    // Turn on new notes to play
    while (_iBandNote < _bandNotes.count) {
        RGNote *n = _bandNotes[_iBandNote];
        
        // User driven mode
        if (_performanceMode == PERFORMANCE_USER_DRIVEN && _notesInCurrentChord) {
            if (n.time < _currentChord[0].time && n.time <= time) {
                if (n.time + n.duration > time) {
                    if (n.removedFromUserNotes) {
                        //                        if (n.time + n.duration > time) {
                        //                            [self turnOnNote:n withAudio:YES isTie:YES isBand:NO velocity:-1 handleKey:NO];
                        //                        }
                        [self bandNoteOn:n];
                    } else {
                        [self bandNoteOn:n];
                    }
                }
                
                _iBandNote++;
            } else {
                break;
            }
            
        // Band driven mode
        } else {
            if (n.time <= time) {
                if (n.time + n.duration > time) {
                    if (n.removedFromUserNotes) {
                       // [self turnOnNote:n withAudio:YES isTie:YES isBand:NO velocity:01 handleKey:NO];// turnOffNote:n withAudio:YES isTie:YES hint:nil handleKey:_autoplaying];
                        [self bandNoteOn:n];
                    } else {
                        [self bandNoteOn:n];
                    }
                }
                _iBandNote++;
            } else {
                break;
            }
        }
    }
    
    if (_iBandNote >= _bandNotes.count) {
        return;
    }
}

- (void) processAutoPlay {
    
    // Turn off notes that have expired
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:_userPlayingNotes.count];
    for (RGNote *n in _userPlayingNotes) {
        if (n.time + n.duration <= _ticks) {
            [toRemove addObject:n];
        }
    }
    for (RGNote *n in toRemove) {
        [self turnOffNote:n withAudio:YES isTie:NO hint:nil handleKey:_autoplaying];
    }
    
    // Play new notes
    while (_iAutoPlay < _userNotes.count) {
        RGNote *n = _userNotes[_iAutoPlay];
        if (n.time <= _ticks) {
            if (n.note > 0 && n.state == NOT_PLAYED) {
                [self turnOnNote:n withAudio:YES isTie:NO isBand:NO velocity:-1 handleKey:_autoplaying];
                n.timePlayed = _ticks;
                n.autoPlayed = YES;
            }
            _iAutoPlay++;
        } else {
            break;
        }
    }
}

- (NSArray *)expectedNotes {
    NSArray *notes = [self getExpectedNotes:NO];
    [_expectedNotes removeAllObjects];
    for (RGNote *n in notes) {
        if (![_expectedNotes containsObject:@(n.qwerty)]) {
            [_expectedNotes addObject:@(n.qwerty)];
        }
    }
    return _expectedNotes;
}

- (NSArray *) getExpectedNotes:(BOOL)sorted {
    NSMutableArray *notes = @[].mutableCopy;
    
    float leeway = _userDrivenWindowTime / secondsPerBeat * (double)_song.division;
    
    for (int i = _iCurrentChord; i < _userNotes.count && i > -1;) {
        
        RGNote *n = _userNotes[i];
        if (n.note == 0) {
            if (i >= _iCurrentChord) i++;
            else i--;
            continue;
        }
        
        // range checks
        if (i >= _iCurrentChord && n.time > _ticks + leeway ) {
            
            // we got past the upper bound; restart at the current chord - 1
            i = _iCurrentChord - 1;
            continue;
        } else if (i < _iCurrentChord && n.time < _ticks - leeway*2) {
            
            // we got past the lower bound; done
            break;
        }
        if (n.state == NOT_PLAYED) {
            [notes addObject:n];
        }
        if (i >= _iCurrentChord) i++;
        else i--;
        continue;
    }
    if (sorted) {
        [notes sortUsingComparator:^NSComparisonResult(RGNote *a, RGNote *b) {
            int diffA = ABS(_ticks - a.time);
            int diffB = ABS(_ticks - b.time);
            if (diffA < diffB) return NSOrderedAscending;
            return NSOrderedDescending;
        }];
    }
    return notes;
}

- (void) processAutoOffNotes {
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:_autoOffNotes.count];
    for (RGNote *n in _autoOffNotes) {
        if (n.time + n.duration <= _ticks) {
            [toRemove addObject:n];
        }
    }
    for (RGNote *n in toRemove) {
        [self turnOffNote:n withAudio:YES isTie:n.tie hint:nil handleKey:_autoplaying];
    }
}

- (void) incrementTicks {
    _ticks += _song.division/24;
    _realTicks = _ticks;
    _time = CACurrentMediaTime();
}

- (void)setCurrentTicks:(int)currentTicks {
    [self setCurrentTicks:currentTicks sound:NO];
}

- (void)setFastForwarding:(BOOL)fastForwarding {
    if (_fastForwarding != fastForwarding) {
        [self willChangeValueForKey:@"fastForwarding"];
        _fastForwarding = fastForwarding;
        [self didChangeValueForKey:@"fastForwarding"];
        if (fastForwarding) {
            self.rewinding = NO;
            self.isPaused = YES;
            seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(fastForward) userInfo:nil repeats:YES];
        } else {
            [seekTimer invalidate];
        }

    }
}

- (void)setRewinding:(BOOL)rewinding {
    if (_rewinding != rewinding) {
        [self willChangeValueForKey:@"rewinding"];
        _rewinding = rewinding;
        [self didChangeValueForKey:@"rewinding"];
        if (rewinding) {
            self.fastForwarding = NO;
            self.isPaused = YES;
            seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(rewind) userInfo:nil repeats:YES];
        } else {
            [seekTimer invalidate];
        }
        
    }
}

- (void) setIsPaused:(BOOL)isPaused {
    if (_isPaused != isPaused) {
        [self willChangeValueForKey:@"isPaused"];
        _isPaused = isPaused;
        [self didChangeValueForKey:@"isPaused"];
        if (isPaused) {
            [self stopTimer];
        }
    }
}

- (void) fastForward {
    int increment = (_song.division / 24) * 3;
    [self setCurrentTicks:self.currentTicks+increment sound:YES];
    if (self.currentTicks >= _song.totalTicks) {
        self.fastForwarding = NO;
    }
}

- (void) rewind {
    int increment = (_song.division / 24) * 3;
    self.currentTicks = self.currentTicks - increment;
    if (self.currentTicks <= 0) {
        self.rewinding = NO;
    }
}

- (void)setCurrentTicks:(int)currentTicks sound:(BOOL)playSounds {
    settingTicks = YES;
    if (!_isPaused) {
        [self willChangeValueForKey:@"isPaused"];
        _isPaused = YES;
        [self stopTimer];
        [self didChangeValueForKey:@"isPaused"];
    }
    if (currentTicks > _song.totalTicks) currentTicks = _song.totalTicks;
    if (currentTicks < 0) currentTicks = 0;
    int tmp = _iCurrentChord;
    int chordEnd = _iCurrentChord + _notesInCurrentChord - 1;
    if (currentTicks > _ticks) {
        _ticks = currentTicks;
        _iAutoPlay = _iCurrentChord;
        if (tmp < _userNotes.count) {
            while (_notesInCurrentChord && _ticks > _currentChord[0].time) {
                [self _moveToNextChord];
            }
            for (int i = tmp; i < _iCurrentChord; i++) {
                RGNote *n = _userNotes[i];
                NoteView *nv = (NoteView *)n.noteView;
                if (nv.state == HIGHLIGHTED) {
                    [((NoteView *)n.noteView) setState:NORMAL duration:0];
                    [[KeyboardView sharedView] noteUnhighlight:n.qwerty duration:0];
                }
                [_highlightedNotes removeObject:n];
            }
        }
        if (playSounds) {
            BOOL wasAutoplaying = _autoplaying;
            _autoplaying = YES;
            
            [self processAutoPlay];
            [self processBandNotes];
            [self processEvents];
            _autoplaying = wasAutoplaying;
            if (!_autoplaying) {
                for (RGNote *n in _userPlayingNotes) {
                    [[KeyboardView sharedView] noteOff:n.qwerty];
                    [_autoOffNotes addObject:n];
                }
            }
        }
        
    } else if (currentTicks < _ticks) {
        _ticks = currentTicks;
        while (_iCurrentChord > 0 && [(RGNote *)_userNotes[_iCurrentChord-1] time] >= _ticks) {
            [self _moveToPreviousChord];
            for (int i = 0; i < _notesInCurrentChord; i++) {
                [notationDisplay cancelOverlaysForNote:_currentChord[i]];
            }
        }
        if (chordEnd > _userNotes.count - 1) {
            chordEnd = _userNotes.count - 1;
        }
        for (int i = chordEnd; i >= _iCurrentChord; i--) {
            RGNote *n = _userNotes[i];
            NoteView *nv = (NoteView *)n.noteView;
            if (nv.state == HIGHLIGHTED) {
                [[KeyboardView sharedView] noteUnhighlight:n.qwerty duration:0];
            }
            [self turnOffNote:n withAudio:YES isTie:NO hint:nil handleKey:YES];
            for (RGNote *tie in n.tieNotes) {
                [self turnOffNote:tie withAudio:YES isTie:YES hint:nil handleKey:YES];
            }
            n.state = NOT_PLAYED;
            [nv setState:NORMAL duration:0];
            [_highlightedNotes removeObject:n];
        }
        for (RGNote *n in _highlightedNotes) {
            NoteView *nv = (NoteView *)n.noteView;
            [nv setState:NORMAL duration:0];
        }
        [_highlightedNotes removeAllObjects];
        
        int curBandNote = _iBandNote;
        int nBandNotes = _bandNotes.count - 1;
        int min = MIN(curBandNote, nBandNotes);
        int i;
        for (i = min; i > -1 ; i--) {
            RGNote *bandNote = _bandNotes[i];
            if (bandNote.time < _ticks) {
                break;
            }
            [self bandNoteOff:bandNote];
            bandNote.state = NOT_PLAYED;
        }
        _iBandNote = MAX(0, i);
        _iAutoPlay = _iCurrentChord;
        

        [self resetNotesWindow];
        
        
//        for (int i = _iBandNote-1; i > -1 && i > (_iBandNote - 100); i--) {
//            RGNote *bandNote = _bandNotes[i];
//            if (bandNote.time + bandNote.duration > _ticks) {
//                if (![_bandPlayingNotes containsObject:bandNote]) {
//                    [self bandNoteOn:bandNote];
//                }
//            }
//        }
    }
//    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(attenuate) object:nil];
//    [self performSelector:@selector(attenuate) withObject:nil afterDelay:0.5];
   // [self calculateExpectedNotes];
    settingTicks = NO;
}

- (void) resetNotesWindow {
    BOOL done = NO;
    
    for (int i = _windowStart - 1; i > -1; i--) {
        RGNote *n = _userNotes[i];
        if (n.note == 0) continue;
        if (n.time < _ticks - _windowSize/2) {
            _windowStart = i + 1;
            break;
        }
    }
    
    _windowStop = _windowStart;
    
    // Highlight upcoming notes
    done = NO;
    for (int i = _windowStop; i < _userNotes.count; i++) {
        RGNote *n = _userNotes[i];
        if (n.note == 0) continue;
        if (_ticks + _windowSize > n.time) {
            
        } else {
            _windowStop = i;
            done = YES;
            break;
        }
    }
    if (!done) {
        _windowStop = _userNotes.count;
    }

}

- (void) attenuate {
    [_player attenuate:0.65];
}


- (void) updateNotesToPlayWindow {
    float time;
    RGNote *n;
    NoteView *view;
    
    if (tempo != _rate || tempoMultiplier != _tempoMultiplier) {
        tempo = _rate;
        tempoMultiplier = _tempoMultiplier;
        
        secondsPerBeat = (double)_song.division / tempo;

        _windowSize = _windowTime / secondsPerBeat * (double)_song.division;
    }
    
    // Highlight mode is next chord only
    if (_limitOneChordHighlightedAtATime) {
        if (_notesInCurrentChord && [_currentChord[0] time] < _windowSize + _ticks) {
//            for (int i = 0; i < _notesInCurrentChord; i++) {
//                n = _currentChord[i];
//                if (n.note == 0) continue;
//                if (n.state == NOT_PLAYED) {
//                    view = (NoteView *)n.noteView;
//                    if (view.state != HIGHLIGHTED) {
//                        if (_magnifyUpcomingNotes) {
//                            time = _windowTime * (1 / tempoMultiplier) * (float)(n.time - _ticks)/_windowSize;
//                            [view setState:HIGHLIGHTED duration:MAX(0, time-0.1)];
//                            if (_exmatch) {
//                                [_keyboard noteHighlight:n.qwerty duration:time];
//                            }
//                        }
//                        [_highlightedNotes addObject:n];
//                    }
//                }
//            }
            int quantum = _song.division*4/24;
            RGNote *prev = _currentChord[0];
            for (int i = _iCurrentChord; i < _userNotes.count; i++) {
                n = _userNotes[i];
                if (n.note == 0) continue;
                
                // Notes are considered as being in the same chord as long as they are all within quantum time of each other, or up to a max of 8 notes
                if (ABS(n.time - prev.time) > quantum || (i - _iCurrentChord >= 7) || (n != prev && n.isTrill)) break;
                
                if (n.state == NOT_PLAYED) {
                    view = (NoteView *)n.noteView;
                    if (view.state != HIGHLIGHTED) {
                        if (_magnifyUpcomingNotes) {
                            time = _windowTime * (1 / tempoMultiplier) * (float)(n.time - _ticks)/_windowSize;
                            [view setState:HIGHLIGHTED duration:MAX(0, time-0.1)];
                            if (_exmatch) {
                                [_keyboard noteHighlight:n.qwerty duration:time];
                            }
                        }
                        [_highlightedNotes addObject:n];
                    }
                }
                

                prev = n;
            }

        }
        
        for (int i = _highlightedNotes.count - 1; i > -1; i--) {
            n = _highlightedNotes[i];
            if (n.time + n.duration < _ticks - _windowSize/2 && n.state == NOT_PLAYED) {
                view = (NoteView *)n.noteView;
                if (view.state == HIGHLIGHTED) {
                    time = _windowTime * (1 / tempoMultiplier) ;
                    [view setState:NORMAL duration:time];
                    [_highlightedNotes removeObjectAtIndex:i];
                }
            }
        }
    }
    
    // If the time has passed for the current chord, turn on lyrics, and start fading out notes that are highlighted.
    if (_notesInCurrentChord && _currentChord[0].time + _song.division/24 <= _ticks) {
        for (int i = 0; i < _notesInCurrentChord; i++) {
            RGNote *n = _currentChord[i];
            if (n.note == 0) {
                n.state = PLAYED;
            } else if (n.state == NOT_PLAYED && _limitOneChordHighlightedAtATime) {
                view = (NoteView *)n.noteView;
                time = _windowTime * (1 / tempoMultiplier);
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if (view.state == HIGHLIGHTED) {
                        [view setState:NORMAL duration:time];
                        if (_exmatch) {
                            [_keyboard noteUnhighlight:n.qwerty duration:time];
                        }
                        [_highlightedNotes removeObject:n];
                    }
                });
            }
        }
        
        // Move to the next chord
        [self _moveToNextChord];
    }
    

    BOOL done = NO;
    for (int i = _windowStart; i < _userNotes.count; i++) {
        n = _userNotes[i];
        if (_ticks - _windowSize/2 > n.time) {
            if (!_limitOneChordHighlightedAtATime) {
                if (n.note == 0) continue;
                view = (NoteView *)n.noteView;
                if (view.state == HIGHLIGHTED) {
                    time = _windowTime * (1 / tempoMultiplier);
                    [view setState:NORMAL duration:time];
                    if (_exmatch) {
                        [_keyboard noteUnhighlight:n.qwerty duration:time];
                    }
                }
                [_highlightedNotes removeObject:n];
            }
        } else {
            _windowStart = i;
            done = YES;
            break;
        }
    }
    if (!done) {
        _windowStart = _userNotes.count;
    }
    if (_windowStop < _windowStart) {
        _windowStop = _windowStart;
    }
    

    
    // Highlight upcoming notes
    done = NO;
    for (int i = _windowStop; i < _userNotes.count; i++) {
        n = _userNotes[i];
        if (n.note == 0) continue;
        if (_ticks + _windowSize > n.time) {
            if (!_limitOneChordHighlightedAtATime) {
                if (n.state == NOT_PLAYED) {
                    view = (NoteView *)n.noteView;
                    if (view.state != HIGHLIGHTED) {
                        if (_magnifyUpcomingNotes) {
                            time = _windowTime * (1 / tempoMultiplier) * (n.time - _ticks)/_windowSize;
                            [view setState:HIGHLIGHTED duration:0];
                            if (_exmatch) {
                                [_keyboard noteHighlight:n.qwerty duration:time];
                            }
                        }
                        [_highlightedNotes addObject:n];
                    }
                }
            }
        } else {
            _windowStop = i;
            done = YES;
            break;
        }
    }
    if (!done) {
        _windowStop = _userNotes.count;
    }
    
    // Update expected notes
  //  [self calculateExpectedNotes];
    
}

//- (void) calculateExpectedNotes {
//    NSArray *notes = [self getExpectedNotes:NO];
//    [_expectedNotes removeAllObjects];
//    for (RGNote *n in notes) {
//        if (![_expectedNotes containsObject:@(n.qwerty)]) {
//            [_expectedNotes addObject:@(n.qwerty)];
//        }
//    }
//}

- (void) finish {
    _isFinished=YES;
    for (RGNote *n in [_userPlayingNotes allObjects]) {
        [self turnOffNote:n withAudio:YES isTie:NO hint:nil handleKey:_autoplaying];
    }
    
    [self performSelector:@selector(finishBandNotes) withObject:nil afterDelay:2];
    [_player attenuate:2];
    [self stopTimer];
    [[PerformanceViewController sharedController] performanceFinished];
}

- (void) finishBandNotes {
    for (RGNote *n in [_bandPlayingNotes allObjects]) {
        [self bandNoteOff:n];
    }
}

- (void)setTempoFactor:(float)tempoFactor {
    tempoFactor = MIN(tempoFactor, TEMPO_MAX);
    tempoFactor = MAX(tempoFactor, TEMPO_MIN);
    _tempoFactor = tempoFactor;
}


# pragma mark - note on/off

- (void) bandNoteOn:(RGNote *)n {
    if (n.note==0) {
        [(LyricView *)n.noteView setState:PLAYING animated:(!_fastForwarding && !_rewinding && !settingTicks)];
    } else {
        n.actualNotePlayed = n.note;
        int velocity = n.removedFromUserNotes ? n.volume : n.volume * _bandVolume;
        
        [_player playNote:n.actualNotePlayed onChannel:n.channel withVelocity:velocity];
        [_bandPlayingNotes addObject:n];
//        if (n.channel == 5) {
//            NSLog(@"bon: %d", n.note);
//        }
    }
}

- (void) bandNoteOff:(RGNote *)n {
    [_player unplayNote:n.actualNotePlayed onChannel:n.channel];
    [_bandPlayingNotes removeObject:n];
//    if (n.channel == 5) {
//        NSLog(@"boff: %d", n.note);
//    }
}

- (void)turnOnNote:(RGNote *)n withAudio:(BOOL)audio isTie:(BOOL)tie isBand:(BOOL)band velocity:(int)vel handleKey:(BOOL)handleKey {
    
    SetKeyAdjustedNote(n, _key);
    
    int volume = (vel > 0) ? vel : n.volume;
    
    // Turn off any duplicates of this note that are currently playing
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:_userPlayingNotes.count];
    for (RGNote *note in _userPlayingNotes) {
        if (n.actualNotePlayed == note.actualNotePlayed && note.channel == n.channel) {
            [toRemove addObject:note];
        }
    }
    for (RGNote *note in toRemove) {
        [self turnOffNote:note withAudio:YES isTie:note.tie hint:nil handleKey:handleKey];
    }
    
    // Turn on the note
    if (audio) {
        if (band) {
            [_player playNote:n.actualNotePlayed onChannel:n.channel withVelocity:volume];
        } else {
            [_player playNote:n.actualNotePlayed onChannel:n.channel withVelocity:volume];
        }
        if (_echoExternalMIDI) {
            const UInt8 data[] = {0x90+n.channel, n.note, n.volume};
            [[ExternalMIDIManager sharedManager] sendBytes:data length:sizeof(data)];
        }
    }
    
    n.state = PLAYING;
    n.timePlayed = _realTicks;
    [_userPlayingNotes addObject:n];
    
    if ((handleKey || _autoplaying) && !tie) {
        [_keyboard noteOn:n.qwerty];
    }
    
    if (!tie) {
        
        // For displayed notes, update them in the display
        [_highlightedNotes removeObject:n];
        NoteView *view = (NoteView *)n.noteView;
        if (view) {
            [view setState:n.state duration:(settingTicks || _fastForwarding || _rewinding) ? 0 : 0.1];
        }
    } else {
        
        // For tie notes, add them to the list for automatic turn-off
        //[_autoOffNotes addObject:n];
    }
    
    // Turn on any notes tied to this one
    for (RGNote *tie in n.tieNotes) {
        [self turnOnNote:tie withAudio:YES isTie:YES isBand:band velocity:vel handleKey:handleKey];
    }
}


- (void)turnOffNote:(RGNote *)n withAudio:(BOOL)audio isTie:(BOOL)tie hint:(id)iterator handleKey:(BOOL)handleKey {
    
    if (audio && n.state == PLAYING) {
        [_player unplayNote:n.actualNotePlayed onChannel:n.channel];
        if (_echoExternalMIDI) {
            const UInt8 data[] = {0x80+n.channel, n.note, 0x00};
            [[ExternalMIDIManager sharedManager] sendBytes:data length:sizeof(data)];
        }
    }
    
    n.state = PLAYED;
    [_userPlayingNotes removeObject:n];
    
    if ((handleKey || _autoplaying) && !tie) {
        [_keyboard noteOff:n.qwerty];
    }
    
    if (!tie) {

        NoteView *view = (NoteView *)n.noteView;
        if (view) {
            
//            int margin = 0.15 * n.rate;
//            int diff = (n.timePlayed - n.time);
//            if (diff > margin) {
//                [view setState:PLAYED modifier:PLAYED_TOO_LATE duration:0.2];
//            } else if (diff < -margin) {
//                [view setState:PLAYED modifier:PLAYED_TOO_EARLY duration:0.2];
//            } else {
                [view setState:PLAYED duration:0];
           // }
        }
    } else {
     
    }
       [_autoOffNotes removeObject:n];
    for (RGNote *tie in n.tieNotes) {
        
        // If this note had ties of the same duration, turn them off
        if (tie.state == PLAYING && tie.duration <= n.duration) {
            [self turnOffNote:tie withAudio:YES isTie:YES hint:iterator handleKey:handleKey];
        } else if (tie.state == PLAYING) {
            [_autoOffNotes addObject:tie];
        } else {
         //   NSLog(@"tie not playing?");
        }
    }
    n.timeFinished = _realTicks;
    
    BOOL perfect = NO;
    BOOL rightLength = NO;
    int margin = 0.15 * n.rate;
    int startDiff = (n.timePlayed - n.time);
    int endDiff = n.timeFinished - (n.time + n.duration);
    
    rightLength = ABS(endDiff) < margin;
    perfect = rightLength && ABS(startDiff) < margin;
    
    [notationDisplay noteOff:n wasPerfect:perfect heldForRightLength:rightLength];
    n.heldForRightDuration = rightLength;
}

- (void) _moveToPreviousChord {
    if (_iCurrentChord > 0) {
        RGNote *previousNote = _userNotes[_iCurrentChord - 1];
        if (previousNote.time >= _ticks) {
            int i;
            for (i = _iCurrentChord - 1; i > -1; i--) {
                RGNote *n = _userNotes[i];
                if (previousNote.time != n.time) {
                    i++;
                    break;
                }
            }
            if (i < 0) {
                i = 0;
            }
            for (int j = i; j <= _iCurrentChord - 1; j++) {
                _currentChord[j - i] = _userNotes[j];
            }
            _notesInCurrentChord = _iCurrentChord - i;
            _iCurrentChord = i;
        }
    }
}

- (void) _moveToNextChord {
    
    // Update the last played note
    if (_notesInCurrentChord) {
        _lastPlayedNote = _currentChord[0];
    }
    
    // Jump forward to the next note
    _iCurrentChord += _notesInCurrentChord;
    _notesInCurrentChord = 0;
    
    // Skip over lyrics and find the next group notes that have the same start time
    BOOL found = NO;
    BOOL done = YES;
    if (_iCurrentChord < _userNotes.count) {
        
        _currentChord[0] = _userNotes[_iCurrentChord];
        while (_currentChord[0].note == 0) {
            _iCurrentChord++;
            if (_iCurrentChord >= _userNotes.count-1) {
                break;
            }
            _currentChord[0] = _userNotes[_iCurrentChord];
        }
        found = _currentChord[0].note != 0;
        if (found) {
            RGNote *anchor = _currentChord[0];
            _notesInCurrentChord = 1;
            for (int i = _iCurrentChord+1; i < _userNotes.count; i++) {
                RGNote *n = _userNotes[i];
                if (n.time == anchor.time) {
                    if (n.note != 0) {
                    _currentChord[_notesInCurrentChord] = n;
                    _notesInCurrentChord++;
                    }
                } else {
                    break;
                }
            }
            
            _startTime = CACurrentMediaTime();
            _time = _startTime;
            if (_performanceMode == PERFORMANCE_USER_DRIVEN && _ticks > 0) {
                if (!_isPaused) {
                    [self processBandNotes];
                }
            }
        }
        for (int i = 0; i < _notesInCurrentChord; i++) {
            if (_currentChord[i].state == NOT_PLAYED) {
                done = NO;
                break;
            }
        }
        if (done) {
            [self _moveToNextChord];
        } else {
            if (_notesInCurrentChord) {
                RGNote *note = _currentChord[0];
                if ((note.time - _ticks) / self.ticksPerSecond > 7) {
                    [[PerformanceViewController sharedController] alertWaiting:note.time];
                }
            }
        }
    } else {
        // _isFinished = YES;
    }
}

# pragma mark - user input

- (BOOL)handleNoteOn:(unichar)key velocity:(int)velocity autoOff:(BOOL)autoOff andHandleKey:(BOOL)handleKey {
    BOOL chordFinished = YES;
    BOOL played = NO;
    BOOL match = NO;
    
    if (_isPaused && _song) {
        [self start];
        [[PerformanceViewController sharedController] performanceDidStart];
        if (_ticks == 0 && _currentChord[0].time > _ticks) {
            return NO;
        }
    }
    
    if (_autoplaying || _isPaused) return NO;
    
    // Allow some leeway to play notes ahead of time
    float leeway = _userDrivenWindowTime / secondsPerBeat * (double)_song.division;
    
    
    // If user is driving tempo
    if (_performanceMode == PERFORMANCE_USER_DRIVEN) { 
        if (_notesInCurrentChord) {
            
          
            if (_ticks < _currentChord[0].time && (float)(_ticks - _lastPlayedNote.time) / (float)(_currentChord[0].time - _lastPlayedNote.time) < 0.1) {
                  //return NO;
            }
            

            int iChordEnd = _iCurrentChord + _notesInCurrentChord;
            
            // If the next note to play is out of range, this is a wrong note
//            if (_currentChord[0].time > _ticks + leeway*1.5) {
//                _wrongNotes++;
//                return NO;
//            }
            
            // Check if any notes match the input note
            RGNote *playedNote;
            int playedIndex = -1;
            
            NSArray *expectedNotes = [self getExpectedNotes:YES];
            
            for (RGNote *n in expectedNotes) {
                if (_exmatch) {
                    match = n.qwerty == key;
                } else {
                    match = YES;
                }
                
                if (!played && match && n.state == NOT_PLAYED) {
                    if (!_exmatch) {
                        n.noteOffKey = key;
                    }
                    
                    if (n.index >= _iCurrentChord + _iCurrentChord) {
                        _realTicks = _ticks; // we are skipping forward
                    }
                    
                    [self turnOnNote:n withAudio:YES isTie:NO isBand:NO velocity:velocity handleKey:handleKey];
                    
                    int margin = 0.15 * n.rate;
                    int diff = (n.timePlayed - n.time);
                    int earlyLate = 0;
                    if (diff > margin) {
                        earlyLate = 1;
                    } else if (diff < -margin) {
                        earlyLate = -1;
                        
                    }
                    n.timing = earlyLate;
                    n.autoPlayed = NO;
                    [notationDisplay noteOn:n timing:earlyLate];
                    
                    playedNote = n;
                    playedIndex = n.index;
                    if (autoOff) {
                        [_autoOffNotes addObject:n];
                    }
                    played = YES;
                    if (n.index >= iChordEnd) {
                        chordFinished = YES;
                        break;
                    }
                } else if (n.index < iChordEnd && n.state == NOT_PLAYED && n.index >= _iCurrentChord) {
                    chordFinished = NO;
                }

            }
            
//            // we start at the current chord, and go forward till we get out of range.
//            // Then, we restart at the current chord-1, and go downward until we get out of range
//            for (int i = _iCurrentChord; i < _userNotes.count && i > -1;) {
//                RGNote *n = _userNotes[i];
//                
//                // Lyric note; skip it
//                if (n.note == 0) {
//                    if (n.state == NOT_PLAYED) {
//                        n.state = PLAYED;
//                    }
//                    if (i >= _iCurrentChord) i++;
//                    else i--;
//                    continue;
//                }
//                
//                // range checks
//                if (i >= _iCurrentChord && n.time > _ticks + leeway ) {
//                    
//                    // we got past the upper bound; restart at the current chord - 1
//                    i = _iCurrentChord - 1;
//                    continue;
//                } else if (i < _iCurrentChord && n.time < _ticks - leeway*2) {
//                    
//                    // we got past the lower bound; done
//                    break;
//                }
//                
//                if (_exmatch) {
//                    match = n.qwerty == key;
//                } else {
//                    match = YES;
//                }
//                
//                if (!played && match && n.state == NOT_PLAYED) {
//                    if (!_exmatch) {
//                        n.noteOffKey = key;
//                    }
//                    
//                    if (i >= _iCurrentChord + _iCurrentChord) {
//                        _realTicks = _ticks; // we are skipping forward
//                    }
//                    
//                    [self turnOnNote:n withAudio:YES isTie:NO isBand:NO velocity:velocity handleKey:handleKey];
//                    
//                    int margin = 0.15 * n.rate;
//                    int diff = (n.timePlayed - n.time);
//                    int earlyLate = 0;
//                    if (diff > margin) {
//                        earlyLate = 1;
//                    } else if (diff < -margin) {
//                        earlyLate = -1;
//                    } 
//                    [notationDisplay noteOn:n timing:earlyLate];
//                    
//                    playedNote = n;
//                    playedIndex = i;
//                    if (autoOff) {
//                        [_autoOffNotes addObject:n];
//                    }
//                    played = YES;
//                    if (i >= iChordEnd) {
//                        chordFinished = YES;
//                        break;
//                    }
//                } else if (i < iChordEnd && n.state == NOT_PLAYED && i >= _iCurrentChord) {
//                    chordFinished = NO;
//                }
//                
//                // incrememt or decrement i
//                if (i >= _iCurrentChord) i++;
//                else i--;
//            }
            if (chordFinished && playedIndex >= _iCurrentChord) {
                if (_autoTempo && playedNote) {
                    int diff = playedNote.time - _ticks;
                    if (diff > _song.division/24) {
                        float tempoChange = (float)diff/(float)leeway;
                        tempoChange = MIN(tempoChange*1.4, 1);
                        if (tempoChange > 0.05) {
                            self.tempoFactor *= (1 + (0.15 * tempoChange));
                            [[PerformanceViewController sharedController] tempoDidChange];
                        }
                        [[PerformanceViewController sharedController] tempoDidChange];
                    }
                }
                if (playedIndex < _iCurrentChord + _notesInCurrentChord) {
                    [self _moveToNextChord];
                } else {
                    while (_notesInCurrentChord && playedIndex >= (_iCurrentChord + _notesInCurrentChord - 1)) {
                        NoteView *view;
                        float time;
                        for (int i = 0; i < _notesInCurrentChord; i++) {
                            RGNote *n = _currentChord[i];
                            if (n.note == 0) {
                                n.state = PLAYED;
                            } else if (n.state == NOT_PLAYED && _limitOneChordHighlightedAtATime) {
                                view = (NoteView *)n.noteView;
                                time = _windowTime * (1 / tempoMultiplier);
                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                    if (view.state == HIGHLIGHTED) {
                                        [view setState:NORMAL duration:time];
                                        if (_exmatch) {
                                            [_keyboard noteUnhighlight:n.qwerty duration:time];
                                        }
                                        [_highlightedNotes removeObject:n];
                                    }
                                });
                            }
                        }
                        
                        [self _moveToNextChord];
                    }
                }
            }
        }
        
    // If band is driving tempo
    } else {
        
        NSArray *expectedNotes = [self getExpectedNotes:YES];
        
        for (RGNote *n in expectedNotes) {
            if (_exmatch) {
                match = n.qwerty == key;
            } else {
                match = YES;
            }
            
            if (!played && match && n.state == NOT_PLAYED) {
                if (!_exmatch) {
                    n.noteOffKey = key;
                }
                [self turnOnNote:n withAudio:YES isTie:NO isBand:NO velocity:velocity handleKey:handleKey];
                
                int margin = 0.15 * n.rate;
                int diff = (n.timePlayed - n.time);
                int earlyLate = 0;
                if (diff > margin) {
                    earlyLate = 1;
                } else if (diff < -margin) {
                    earlyLate = -1;
                }
                [notationDisplay noteOn:n timing:earlyLate];
                n.timing  = earlyLate;
                n.autoPlayed = NO;
                if (handleKey) {
                    [_keyboard noteOn:n.qwerty];
                }
                played = YES;
                break;
            }

        }
        
//        // Check all notes in the window for matches
//        for (int i = _iCurrentChord; i < _userNotes.count && i > -1;) {
//            RGNote *n = _userNotes[i];
//            if (n.note == 0) {
//                if (i >= _iCurrentChord) i++;
//                else i--;
//                continue;
//            }
//            
//            // range checks
//            if (i >= _iCurrentChord && n.time > _ticks + leeway ) {
//                
//                // we got past the upper bound; restart at the current chord - 1
//                i = _iCurrentChord - 1;
//                continue;
//            } else if (i < _iCurrentChord && n.time < _ticks - leeway*2) {
//                
//                // we got past the lower bound; done
//                break;
//            }
//            
//            if (_exmatch) {
//                match = n.qwerty == key;
//            } else {
//                match = YES;
//            }
//            
//            if (!played && match && n.state == NOT_PLAYED) {
//                if (!_exmatch) {
//                    n.noteOffKey = key;
//                }
//                [self turnOnNote:n withAudio:YES isTie:NO isBand:NO velocity:velocity handleKey:handleKey];
//                
//                int margin = 0.15 * n.rate;
//                int diff = (n.timePlayed - n.time);
//                int earlyLate = 0;
//                if (diff > margin) {
//                    earlyLate = 1;
//                } else if (diff < -margin) {
//                    earlyLate = -1;
//                }
//                [notationDisplay noteOn:n timing:earlyLate];
//                
//                if (handleKey) {
//                    [_keyboard noteOn:n.qwerty];
//                }
//                played = YES;
//                break;
//            }
//            if (i >= _iCurrentChord) i++;
//            else i--;
//        }
    }
    if (!played) {
        _wrongNotes++;
    }
    if (played) {
      //  [self calculateExpectedNotes];
    }
    
    return played;
}


- (void) handleNoteOff:(unichar)key andHandleKey:(BOOL)handleKey {
    if (_autoplaying || _isPaused) return;
    
    RGNote *foundNote = nil;
    
    for (RGNote *n in _userPlayingNotes) {
        if ((_exmatch && n.qwerty == key) || (!_exmatch && n.noteOffKey == key)) {
            if (!n.tie) {
                foundNote = n;
                break;
            }
        }
    }
    
    if (foundNote) {
        [self turnOffNote:foundNote withAudio:YES isTie:foundNote.tie hint:nil handleKey:(handleKey || _autoplaying)];
        if (handleKey) {
            [_keyboard noteOff:foundNote.qwerty];
        }
    }
}

# pragma mark - helpers

void SetKeyAdjustedNote(RGNote *n, int key) {
    int note = n.note;
    int ct = 0;
    if (key > 0) {
        while (ct < key && note + 12 <= 127) {
            note+= 12;
            ct++;
        }
    } else if (key < 0) {
        while (ct > key && note - 12 >= 0) {
            note -= 12;
            ct--;
        }
    }
    n.actualNotePlayed = note;
}

@end
