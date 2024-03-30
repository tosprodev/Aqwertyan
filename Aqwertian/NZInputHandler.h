//
//  NZInputHandler.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 1/9/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conversions.h"

@interface NZInputHandler : NSObject

#define PERFORMANCE_USER_DRIVEN 0
#define PERFORMANCE_BAND_DRIVEN 1

#define TEMPO_MAX 2
#define TEMPO_MIN 0.25

@property (nonatomic) float tempoFactor;
@property (nonatomic) int nonChordJumpAheadLimit;
@property (nonatomic) int chordJumpAheadLimit;
@property (nonatomic) float windowTime, userDrivenWindowTime;
@property (nonatomic) float baseNoteHighlightTime;
@property (nonatomic) BOOL limitOneChordHighlightedAtATime;
@property (nonatomic) BOOL magnifyUpcomingNotes;
@property (nonatomic) BOOL exmatch;
@property (nonatomic) float volumeMultiplier;
@property (nonatomic) int recordingRate;
@property (nonatomic) BOOL autoplaying;
@property (nonatomic) int performanceMode;
@property (nonatomic) float bandVolume;
@property (nonatomic, readonly) double startTime;
@property (nonatomic, readonly) int startTicks;
@property (nonatomic, readonly) int stopTicks;
@property (nonatomic) int currentTicks;
@property (nonatomic, readonly) double ticksPerSecond;
@property (nonatomic, readonly) double time;
@property (nonatomic, readonly) int wrongNotes;
@property (nonatomic, readonly) BOOL soloing;
@property (nonatomic, readonly) BOOL isFinished;
@property (nonatomic, readonly) Song *song;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic) BOOL autoPedal;
@property (nonatomic) int key;
@property (nonatomic) BOOL autoTempo;
@property (nonatomic) BOOL echoExternalMIDI;
@property (nonatomic) BOOL fastForwarding;
@property (nonatomic) BOOL rewinding;
@property (nonatomic, readonly) NSArray *expectedNotes;
@property (nonatomic) int seekIncrement; // in ticks, per 0.1 second
@property (nonatomic) BOOL metronomeEnabled;
@property (nonatomic) float metronomeVolume;

+ (NZInputHandler *)sharedHandler;

- (NSArray *) notes;

- (void) setMetronomeTickHandler:(void(^)())handler;

- (void) restart;
- (void) stop;
- (void) start;
- (void) pause;

- (int) currentSeconds;
- (int) totalSeconds;

- (void) setSong:(Song *)song isSamePiece:(BOOL)same;

- (void)setCurrentTicks:(int)currentTicks sound:(BOOL)playSounds;

- (BOOL) handleNoteOn:(unichar)key velocity:(int)velocity autoOff:(BOOL)autoOff andHandleKey:(BOOL)handleKey;
- (void) handleNoteOff:(unichar)key andHandleKey:(BOOL)handleKey;

- (void) userDidChangeProgram;

@end
