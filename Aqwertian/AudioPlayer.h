//
//  AudioPlayer.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/20/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ExternalMIDIManager.h"

@interface AudioPlayer : NSObject

@property (nonatomic) int clocks;
@property (nonatomic) BOOL EchoToExternalMIDI;
@property (nonatomic) BOOL sendToChannelsView;
@property (nonatomic) BOOL sendToInputHandler;
@property (nonatomic) NSArray *autoplayChannels;
@property (nonatomic) NSString *midiFile;
@property (nonatomic) float volume, playerVolume;
@property (nonatomic) float maxVolume, minVolume;
@property (nonatomic) int speed;
@property (nonatomic, readonly) int ticksPerQuarterNote;
@property (nonatomic, readonly) int totalTicks;
@property (nonatomic) BOOL muted;
@property (nonatomic) BOOL chorus, reverb;
@property (nonatomic, readonly) long totalTime, currentTime;


+ (AudioPlayer *)sharedPlayer;

- (int) tempo;
- (void) attenuate:(NSTimeInterval)duration;
- (void) playNote:(int)note onChannel:(int)channel withVelocity:(int)velocity;
- (void) unplayNote:(int)note onChannel:(int)channel;
- (void) setProgram:(int)program forChannel:(int)channel;
- (void) resetProgram;
- (void) pedalOn:(int)channel;
- (void) pedalOff:(int)channel;

- (void) pedal:(int)channel note:(int)note velocity:(int)velocity;
- (int) program:(int)channel;

- (void) panic;
- (void) pitchBend:(NSInteger)bend channel:(int)channel;
- (void) getInfo:(unsigned long *)totalTicks dvision:(unsigned short *)division;
- (NSString *) getCurrentProgram:(int)channel;
- (int) getProgramNumber:(int)channel;
- (void) seek:(unsigned long)ticks;

- (void) metronomePulse;

- (void) setMidiFile:(NSString *)aFile;
- (void) startPlaying;
- (void) stopPlaying;
- (void) setMute:(BOOL)mute forChannel:(NSInteger)channel;

- (void) setSpeed:(int)speed;
- (int) secondsPerBeat;
- (float) tempoMultiplier;

- (void) startRecording;
- (void) cancelRecording;
- (void) finishRecording:(NSString *)filePath;
- (BOOL) isRecording;
- (BOOL) recordingHasStarted;
- (void) reset;

- (void) changeKey:(BOOL)up;
- (void) resetKey;

- (BOOL) isPlaying;
- (BOOL) isPaused;

@end
