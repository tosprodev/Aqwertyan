//
//  AudioPlayer.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/20/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "AudioPlayer.h"
#import "crsynth/crmd.h"
#import "crmp.h"
#import <AvailabilityMacros.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "ChannelsView.h"
#import "NZInputHandler.h"
#import <AudioToolbox/AudioToolbox.h>

#define BEATS_PER_SEC 120.0;

#define MAIN_THREAD(a) if ([NSThread isMainThread]) { a } else { dispatch_sync(dispatch_get_main_queue(), ^(void) { a }); }


@interface AudioPlayer ()
- (void)callback:(CRMD_CALLBACK_TYPE) type data:(void *)data;

@end

static void _callback (CRMD_HANDLE handle, CRMD_CALLBACK_TYPE type, void *data, void *user)
{
	AudioPlayer *audioPlayer = (__bridge AudioPlayer *) user;
	[audioPlayer callback:type data:data];

}

static void _pcallback (CRMP_HANDLE handle, CRMP_CALLBACK_TYPE type, void *data, void *user)
{
	AudioPlayer *audioPlayer = (__bridge AudioPlayer *) user;
	[audioPlayer callback:type data:data];
}

@implementation AudioPlayer {
    CRMD_HANDLE handle;
	CRMD_FUNC *api;
    CRMP_HANDLE phandle;
	CRMP_FUNC *papi;

    BOOL notes[16][128];
    CRMD_ERR err;
    
    UInt8 lastProgram;
    
    bool record;
    int _sig;
    int attCount;
    NSTimer *timer;
    
    MusicTrack track;
    MusicSequence sequence;
    CFTimeInterval startTime;
    
    double time;
    int _chorus, _reverb;
    
    NZInputHandler *inputHandler;
    
    BOOL channelsToAutoplay[16];
    
    int _tempo;
    double _secondsPerBeat;
    float _tempoMultiplier;
    
    BOOL didPause;
    BOOL didStop;
    BOOL _attenuated;
    BOOL isPaused;
    unsigned long seekTo;
    
    unsigned long _totalTicks, _totalSeconds;
    unsigned short _division;
    
    int programs[16];
    
    int key;
}

- (id)init {
    self = [super init];
    [self initializeCrsynth];
    self.EchoToExternalMIDI = NO;
    record = NO;
    inputHandler = [NZInputHandler sharedHandler];
    self.sendToInputHandler = YES;
    _volume = CRMP_VOLUME_DEF;
    key = 0;
    
    for (int i = 0; i < 16; i++) programs[i] = 0;
    return self;
}

- (float)maxVolume {
    return CRMP_VOLUME_MAX;
}

- (float)minVolume {
    return CRMP_VOLUME_MIN;
}

- (void)setChorus:(BOOL)chorus {
    _chorus = chorus;
    int value = chorus;
    api->ctrl (handle, CRMD_CTRL_SET_CHORUS, &value, sizeof (value));
}

- (BOOL)chorus {
    int value;
    api->ctrl (handle, CRMD_CTRL_GET_CHORUS, &value, sizeof (value));
    return value;
}

- (void)setReverb:(BOOL)reverb {
    reverb = reverb ? 1 : 0;
    _reverb = reverb;
    api->ctrl (handle, CRMD_CTRL_SET_REVERB, &reverb, sizeof (reverb));
}

- (BOOL)reverb {
    int value;
    api->ctrl (handle, CRMD_CTRL_GET_REVERB, &value, sizeof (value));
    return value;
}
- (BOOL)isPaused {
    return isPaused;
}

+ (AudioPlayer *)sharedPlayer {
    static AudioPlayer *thePlayer = nil;
    
    if (thePlayer == nil) {
        thePlayer = [AudioPlayer new];
    }
    
    return thePlayer;
}

- (void)attenuate:(NSTimeInterval)duration {
    if (_attenuated) return;
    _attenuated=YES;
    attCount = 0;
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(lowerVolume) userInfo:[NSNumber numberWithFloat:duration] repeats:YES];
}

- (void) lowerVolume {
    if (!_attenuated) {
        [timer invalidate];
        return;
    }
    float incr = [timer.userInfo floatValue];
    incr = incr * 20;
    int value = _volume - (_volume *attCount++/incr);
    value = MAX(value, CRMD_VOLUME_MIN);
    api->ctrl (handle, CRMD_CTRL_SET_MASTER_VOLUME, &value, sizeof (value));
    if (_volume == CRMD_VOLUME_MIN) {
        [timer invalidate];
        attCount = 0;
    }
}

- (void)resetProgram {
    [self setProgram:lastProgram forChannel:0];
}

- (int)tempo {
    return _tempo;
}

- (void)setMuted:(BOOL)muted {
    if (muted) {
        float vol = _volume;
        self.volume = 0;
        _volume = vol;
        _muted=YES;
    } else {
        _muted=NO;
        self.volume = _volume;
    }
}

- (void) recalculateSecondsPerBeat {
    if (_speed > 0) {
        _tempoMultiplier = (_speed + 100.0) / 100.0; 
    } else {
        _tempoMultiplier = powf(2, _speed / 100.0);
    }
    // 1/(tempoMultiplier * tempo) [usec/beat] * 1/1000000 [sec/usec] = [sec/beat]
    _secondsPerBeat = (1.0/(_tempoMultiplier*_tempo)) * 1.0/1000000.0;
}

- (void) panic {
//    for (int channel = 0; channel < 16; channel++) {
//        for (int note = 0; note < 128; note++) {
//            [self unplayNote:note onChannel:channel];
//        }
//    }
    int programsCopy[16];
    for (int i = 0; i < 16; i++) {
        programsCopy[i] = programs[i];
    }
    float volume = self.volume;
    [self reset];
    for (int i = 0; i < 16; i++) {
        [self setProgram:programsCopy[i] forChannel:i];
    }
}

- (void)reset {
    api->stop(handle);
    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 128; j++) {
            notes[i][j] = NO;
        }
    }
    for (int i = 0; i < 16; i++) {
        programs[i] = 0;
    }
    api->start(handle);
    _attenuated=NO;
    self.volume = _volume;
    self.chorus = _chorus;
    self.reverb = _reverb;
}
- (int)getProgramNumber:(int)channel {
    return programs[channel];
}

- (BOOL)isPlaying {
    return papi->isPlaying(phandle);
}

- (float)tempoMultiplier {
    return _tempoMultiplier;
}

- (void) initializeCrsynth {
    
    // DRIVER
    AudioSessionInitialize(NULL, NULL, NULL, (__bridge void *)(self));
	UInt32 category = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    
	AudioSessionSetActive(true);
    
	Float32 bufferSize = 0.005;
	SInt32 size = sizeof(bufferSize);
	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, size, &bufferSize);
    
    
	api = crmdLoad ();
    
	err = CRMD_OK;
	
	if (err == CRMD_OK) {
		// initialize
		NSString *path = [[NSBundle mainBundle] pathForResource:@"crsynth" ofType:@"dlsc"];
		const char *lib = [path cStringUsingEncoding:NSASCIIStringEncoding];
		const unsigned char key[64] = {
            0xE1, 0xF1, 0x4B, 0xF9, 0x39, 0xA7, 0x6C, 0x32,
            0x2A, 0xE0, 0x10, 0xED, 0x5B, 0x1F, 0x89, 0x1B,
            0x63, 0x55, 0x58, 0xC7, 0xEF, 0xDA, 0x84, 0xE5,
            0x7B, 0xCD, 0x87, 0x27, 0xE1, 0x39, 0xE5, 0x17,
            0x52, 0xB2, 0x25, 0x96, 0x0C, 0x52, 0x14, 0x38,
            0xFA, 0x89, 0xFE, 0xEB, 0xA5, 0x10, 0xE0, 0x61,
            0xBD, 0x74, 0x62, 0x9B, 0xD5, 0xDC, 0xC6, 0x9B,
            0x4C, 0x04, 0x62, 0x40, 0xD0, 0x16, 0xB5, 0xE6,
        };

		err = api->initializeWithSoundLib (&handle, _callback, (__bridge void *) self, lib, NULL, key);
	}
    
	if (err == CRMD_OK) {
		// revweb on
		int value = 1;
		err = api->ctrl (handle, CRMD_CTRL_SET_REVERB, &value, sizeof (value));
        api->ctrl(handle, CRMD_CTRL_GET_REVERB, &value, sizeof (value));
        NSLog(@"reverb: %d", value);
	}
    
   
    
	if (err == CRMD_OK) {
		// open wave output device
		err = api->open (handle, NULL, NULL);
	}
    
	if (err == CRMD_OK) {
		// start realtime MIDI
		err = api->start (handle);
	}
    
    // PLAYER
    papi = crmpLoad ();
    
	err = CRMP_OK;
	
	if (err == CRMP_OK) {
		// initialize
		NSString *path = [[NSBundle mainBundle] pathForResource:@"crsynth" ofType:@"dlsc"];
		const char *lib = [path cStringUsingEncoding:NSASCIIStringEncoding];
		const unsigned char key[64] = {
            0xE1, 0xF1, 0x4B, 0xF9, 0x39, 0xA7, 0x6C, 0x32,
            0x2A, 0xE0, 0x10, 0xED, 0x5B, 0x1F, 0x89, 0x1B,
            0x63, 0x55, 0x58, 0xC7, 0xEF, 0xDA, 0x84, 0xE5,
            0x7B, 0xCD, 0x87, 0x27, 0xE1, 0x39, 0xE5, 0x17,
            0x52, 0xB2, 0x25, 0x96, 0x0C, 0x52, 0x14, 0x38,
            0xFA, 0x89, 0xFE, 0xEB, 0xA5, 0x10, 0xE0, 0x61,
            0xBD, 0x74, 0x62, 0x9B, 0xD5, 0xDC, 0xC6, 0x9B,
            0x4C, 0x04, 0x62, 0x40, 0xD0, 0x16, 0xB5, 0xE6,
        };

		err = papi->initializeWithSoundLib (&phandle, _pcallback, (__bridge void *) self, lib, NULL, key);
	}
    
	if (err == CRMP_OK) {
		// revweb on
		int value = 1;
		//err = papi->ctrl (phandle, CRMP_CTRL_SET_REVERB, &value, sizeof (value));
	}
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mid"];
//    const char *lib = [path cStringUsingEncoding:NSShiftJISStringEncoding];
//    err = papi->setFile (phandle, lib);
    
	if (err == CRMP_OK) {
		// open wave output device
		err = papi->open (phandle, NULL, NULL);
	}
}

////                   
//////  MIDI PLAYER  
////                   

- (void)setMidiFile:(NSString *)aFile {
    if (![_midiFile isEqualToString:aFile]) {
       
        _midiFile = aFile;
        const char *lib = [aFile cStringUsingEncoding:NSShiftJISStringEncoding];
         NSLog(@"set midi file - %@", aFile);
        err = papi->setFile (phandle, lib);
        [self getInfo:&_totalTicks dvision:&_division];
       
        NSLog(@"division - %d", _division);
    } else {
        if (self.isPlaying) {
            [self stopPlaying];
            didStop = YES;
        }
        [self seek:0];
        
        didPause = NO;
        
    }
    seekTo = -1;
    isPaused = NO;
    self.clocks = 0;
}

- (void)startPlaying {
    if (didPause || didStop) return;
    seekTo = -1;
    if (papi->isPlaying(phandle) == 0) {
        papi->start(phandle);
        isPaused = NO;
    }
}

- (void)setSpeed:(int)speed {
    _speed = MIN(50, speed);
    papi->ctrl (phandle, CRMP_CTRL_SET_SPEED, &_speed, sizeof (_speed));
    [self recalculateSecondsPerBeat];
    NSLog(@"%d speed", _speed);
}

- (int)ticksPerQuarterNote {
    return _division;
}

- (void)stopPlaying {
    if (papi->isPlaying(phandle) == 1) {
        papi->stop(phandle);
        didPause = YES;
        
        seekTo = self.clocks*_division/24;
    }
    isPaused = YES;
}

- (void)setMute:(BOOL)mute forChannel:(NSInteger)channel {
    int value = mute ? 1 : 0;
    NSLog(@"Chanel %d %@", channel, (mute ? @"MUTED" : @"UNMUTED"));
    papi->ctrl(phandle, CRMD_CTRL_SET_MUTE + channel, &value, sizeof (value));
}

- (void)getInfo:(unsigned long *)totalTicks dvision:(unsigned short *)division {
    papi->getFileInfo (phandle, NULL, division, totalTicks, &_totalSeconds);
}

- (void)seek:(unsigned long)ticks {
    NSLog(@"seek to %lu - %d", ticks, [[NZInputHandler sharedHandler] currentTicks]);
    if (ticks == 0) {
        isPaused = NO;
    }
    seekTo = ticks;
    self.clocks = 0;
    papi->seek(phandle, ticks);
    if (!didPause) {
        [[ChannelsView sharedView] clearNotes];
    }
}

- (void)resetKey     {
    key = 0;
}

- (void)metronomePulse {
    [self channelMessage:0 status:0x90 data1:60 data2:100];
}

- (void)changeKey:(BOOL)up {
    int value;
  //  papi->ctrl(phandle, CRMP_CTRL_GET_MASTER_KEY, &value, sizeof (value));
   // NSLog(@"current key: %d", value);
    if (up) {
        if (key < 5) {
            key++;
        }
    } else {
        if (key > -5) {
            key--;
        }
    }
  //  api->ctrl(handle, CRMP_CTRL_SET_MASTER_KEY, &value, sizeof (value));
}


////
//////  MIDI DRIVER
////

- (void)playNote:(int)note onChannel:(int)channel withVelocity:(int)velocity {
    if (_attenuated) {
        _attenuated = NO;
        self.volume = _volume;
    }
//    if (key > 0) {
//        int ct = 0;
//        while (ct < key && note + 12 <= 127) {
//            note += 12;
//            ct++;
//        }
//    } else if (key < 0) {
//        int ct = 0;
//        while (ct > key && note - 12 >= 0) {
//            note -= 12;
//            ct--;
//        }
//    }
    if (velocity > 127) velocity=127;
    if (notes[channel][note] || velocity == 0) {

        if (velocity == 0) {
            [self unplayNote:note onChannel:channel];
            return;
        }
      //  NSLog(@"bad");
    }
    [self channelMessage:0 status:0x90+channel data1:note data2:velocity];
    notes[channel][note] = YES;
  //  NSLog(@"[%d] Note on: %d velocity: %d",channel, note, velocity);
}

- (void)unplayNote:(int)note onChannel:(int)channel {
//    if  (!notes[channel][note]) {
//        NSLog(@"umm");
//    }
    [self channelMessage:0 status:0x80+channel data1:note data2:0x00];
    notes[channel][note] = NO;
   // NSLog(@"[%d] Note off: %d",channel, note);

}

- (void)setProgram:(int)program forChannel:(int)channel {
   // if (channel == (UInt8)8) return;
    int ch = (int)channel;
    NSLog(@"CH %d program %d", channel, program);
    programs[channel] = program;
    [self channelMessage:0 status:0xC0+channel data1:program data2:0x00];
    for (int i = 0; i < 128; i++) {
        notes[channel][i] = NO;
        
    }
}

- (void) channelMessage:(int)port status:(int)status data1:(int)data1 data2:(int) data2 {
    api->setChannelMessage (handle, (UInt8)port, (unsigned char)status, (unsigned char)data1, (unsigned char)data2);
    status += port;
    if (_EchoToExternalMIDI) {

    }
    if (record) {
        [self recordStatus:status data1:data1 data2:data2 time:CACurrentMediaTime()];
    }
}

- (void) recordStatus:(unsigned char)status data1:(unsigned char)data1 data2:(unsigned char)data2 time:(CFTimeInterval)theTime {
    if (startTime == 0) {
        startTime = theTime;
        [self setRecordingTempo:_tempo time:startTime];
        [self setRecordingTimeSignature:_sig time:startTime];
        NSLog(@"started record");
    }
    
    MIDIChannelMessage *message = malloc(sizeof(MIDIChannelMessage));
    message->status = status;
    message->data1 = data1;
    message->data2 = data2;
    
    
    MusicTimeStamp time;
    MusicSequenceGetBeatsForSeconds(sequence, theTime - startTime, &time);
    // NSLog(@"event - %f", time);
    
    MusicTrackNewMIDIChannelEvent(track, time, message);

}

- (BOOL)recordingHasStarted {
    return startTime != 0;
}

- (BOOL)isRecording {
    return record;
}

- (void)startRecording {
    OSStatus status;
    
    status = NewMusicSequence(&sequence);
    if(status){
        printf("Error new sequence: %ld\n", status);
        status = 0;
    }
    MusicSequenceSetSequenceType(sequence, kMusicSequenceType_Beats);
    
    status = MusicSequenceNewTrack(sequence, &track);
    if(status){
        printf("Error adding main track: %ld\n", status);
        status = 0;
    }
    
    UInt32 tracks;
    
    MusicSequenceGetTrackCount(sequence, &tracks);
    NSLog(@"%ld tracks at start", tracks);
    
    record = YES;
    startTime = CACurrentMediaTime();
    
    NSLog(@"**Recording");

}

- (void)cancelRecording {
    record = NO;
}

- (void) setRecordingTempo:(int)tempo time:(CFTimeInterval)theTime {
    if (startTime == 0) return;
    MusicTrack tempoTrack;
    MusicSequenceGetTempoTrack (sequence, &tempoTrack);
    
    MusicTimeStamp time;
    MusicSequenceGetBeatsForSeconds(sequence, theTime - startTime, &time);

    MusicTrackNewExtendedTempoEvent(tempoTrack, time, 120);
}

- (void) setRecordingTimeSignature:(int)sig time:(CFTimeInterval)theTime {
    if (startTime == 0) return;
    MusicTrack tempoTrack;
    MusicSequenceGetTempoTrack (sequence, &tempoTrack);
    
    //Set time signature to 7/16
    MIDIMetaEvent timeSignatureMetaEvent;
    timeSignatureMetaEvent.metaEventType = 0x58;
    timeSignatureMetaEvent.dataLength = 4;
    timeSignatureMetaEvent.data[0] = sig >> 24;
    timeSignatureMetaEvent.data[1] = sig >> 16;
    timeSignatureMetaEvent.data[2] = sig >> 8;
    timeSignatureMetaEvent.data[3] = sig >> 0;
    
    MusicTimeStamp time;
    MusicSequenceGetBeatsForSeconds(sequence, theTime - startTime, &time);
    
    MusicTrackNewMetaEvent(tempoTrack, time, &timeSignatureMetaEvent);
}

- (void)finishRecording:(NSString *)filePath {
    if (!record)
        return;
    
    UInt32 tracks;
    
    MusicSequenceGetTrackCount(sequence, &tracks);
    NSLog(@"%ld tracks", tracks);
    
    OSStatus status = 0;


    MusicSequenceGetTrackCount(sequence, &tracks);
    NSLog(@"%ld tracks", tracks);
    
    Boolean hasCurrentEvent;
    MusicEventIterator iterator;
    MusicTimeStamp stamp;
    NewMusicEventIterator(track, &iterator);
    MusicEventIteratorHasCurrentEvent (iterator, &hasCurrentEvent);
    while (hasCurrentEvent) {
        // do work here
        MusicEventIteratorNextEvent (iterator);
        MusicEventIteratorGetEventInfo(iterator, &stamp, nil, nil, nil);
        NSLog(@"%f", stamp);
        MusicEventIteratorHasCurrentEvent (iterator, &hasCurrentEvent);
    }
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    status = MusicSequenceFileCreate(sequence, (__bridge CFURLRef) url, kMusicSequenceFile_MIDIType, kMusicSequenceFileFlags_EraseFile, 0);
    if(status != noErr){
        printf("Error on create: %ld\n", status);
        status = 0;
    }
    
    NSLog(@"File written");
    record = NO;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    int value = (int)volume;
    if (!_muted && !_attenuated) {
        api->ctrl (handle, CRMD_CTRL_SET_MASTER_VOLUME, &value, sizeof (value));
    }
    
}
- (void)setPlayerVolume:(float)playerVolume {
    int value = (int)playerVolume;
    papi->ctrl (phandle, CRMP_CTRL_SET_MASTER_VOLUME, &value, sizeof (value));
}
- (float)playerVolume {
    int value;
    papi->ctrl (phandle, CRMP_CTRL_GET_MASTER_VOLUME, &value, sizeof (value));
    return value;
}

- (void)pedalOn:(int)channel {
    [self channelMessage:0 status:0xB0+channel data1:0x40 data2:0xFF];
}

- (void)pedalOff:(int)channel {
    [self channelMessage:0 status:0xB0+channel data1:0x40 data2:0x00];
}

- (void)pedal:(int)channel note:(int)note velocity:(int)velocity {
    if (velocity > 63) {
       // NSLog(@"pedal on CH %d - %d", channel, velocity);
    } else {
       // NSLog(@"pedal off CH %d - %d", channel, velocity);
    }
    [self channelMessage:0 status:0xB0+channel data1:0x40 data2:velocity];
}

- (void)pitchBend:(NSInteger)bend channel:(int)channel {
    [self channelMessage:0 status:0xE0+channel data1:(UInt8)(bend & 127) data2:(UInt8)((bend >> 7) & 127)];
}

- (int)totalTicks {
    return _totalTicks;
}

- (long)totalTime {
    return _totalSeconds;
}

- (long)currentTime {
    return (float)(_clocks * (_division / 24))/(float)_totalTicks * (float)_totalSeconds;
}

- (void)callback:(CRMD_CALLBACK_TYPE)type data:(void *)data {
    switch (type) {
        case CRMD_CALLBACK_TYPE_OPEN:
            NSLog (@"opened");
            break;
        case CRMD_CALLBACK_TYPE_CLOSE:
            NSLog (@"closed");
            break;
        case CRMD_CALLBACK_TYPE_START:
            NSLog (@"started");
          //  stopped = NO;
            break;
        case CRMD_CALLBACK_TYPE_STOP:
            NSLog (@"stopped");
            if (didStop) {
                [self seek:0];
            } else if (didPause) {
          //      [self seek:seekTo];
            }
            didStop = didPause = NO;
            break;
        case CRMD_CALLBACK_TYPE_FILE_SEEK:
          //  NSLog (@"seek");
            break;
        case CRMD_CALLBACK_TYPE_CLOCK:
            _clocks++;
            //if (self.clocks %2 == 0)
            //if (!didStop && !didPause) {
            if (_clocks * _division/24 >= seekTo) seekTo = -1;
            if (_sendToChannelsView && seekTo == -1) {
 
                MAIN_THREAD(
                    [[ChannelsView sharedView] setClocks:self.clocks];
                );
                
            }
//            if (self.sendToInputHandler) {
//                MAIN_THREAD(
//                    [inputHandler tick:_clocks];
//                );
//            }
           // }
//            if (_clocks%24 == 0) {
//                NSLog(@"%f seconds per 24 clocks", CACurrentMediaTime() - time);
//                time = CACurrentMediaTime();
//            }
           // NSLog(@"%d clocks", self.clocks);
            break;
        case CRMD_CALLBACK_TYPE_TEMPO:
          //  NSLog (@"tempo = %lu[usec/beat]", *(unsigned long *) data);
            _tempo = *(unsigned long *) data;
            [self recalculateSecondsPerBeat];
            [self setRecordingTempo:_tempo time:CACurrentMediaTime()];
            break;
        case CRMD_CALLBACK_TYPE_TIME_SIGNATURE:
         //   NSLog (@"set time signature = %lu", *(unsigned long *) data);
            _sig = *(unsigned long *) data;
            [self setRecordingTimeSignature:_sig time:CACurrentMediaTime()];
            break;
        case CRMD_CALLBACK_TYPE_CHANNEL_MESSAGE:
		{
//            if (didPause || didStop) {
//                return;
//            }
            unsigned char port = (*(unsigned long *) data >> 24) & 0x000000FF;
			unsigned char status = (*(unsigned long *) data >> 16) & 0x000000FF;
			unsigned char data1 = (*(unsigned long *) data >> 8) & 0x000000FF;
			unsigned char data2 = (*(unsigned long *) data >> 0) & 0x000000FF;
            
			//unsigned char status_ = status & 0xF0;
			unsigned char ch = status & 0x0F;
            if (status >= 144 && status <= 169) {
              //  NSLog(@"note on %lu", *(unsigned long *) data);
            } else if (status <= 143 && status >= 128) {
              // NSLog(@"note off");
            } 
            //NSLog(@"%d", port);
            
            
            if (_sendToChannelsView) {
                
                if (status >= 144 && status <= 169 && data2 != 0) {
                    MAIN_THREAD(
                                [[ChannelsView sharedView] noteOn:data1 channel:ch];
                                );
                } else if ((status <= 143 && status >= 128) || (status >= 144 && status <= 169 && data2 == 0)) {
                    MAIN_THREAD(
                                [[ChannelsView sharedView] noteOff:data1 channel:ch];
                                );
                }
                
            }
            
//            if (_autoplayChannels) {
//                
//                if (channelsToAutoplay[ch]) {
//                    if (status >= 144 && status <= 169 && data2 > 0) {
//                        MAIN_THREAD(
//                                    [inputHandler autoPlayNoteOn:data1 channel:ch time:self.clocks-1];
//                                    );
//                    } else if ((status <= 143 && status >= 128) || (status >= 144 && status <= 169 && data2 == 0)) {
            //                        MAIN_THREAD(
            //                                    [inputHandler autoPlayNoteOff:data1 channel:ch time:self.clocks-1];
            //                                    );
            //                    }
            //                }
            //
            //            }
            
            if (record) {
                int value;
                if (128 <= status && status <= 169) {
                    papi->ctrl (phandle, CRMP_CTRL_GET_MUTE + ch, &value, sizeof (value));
                } else {
                    value = 0;
                }
                if (!value) {
                    MAIN_THREAD(
                                
                                [self recordStatus:status data1:data1 data2:data2 time:CACurrentMediaTime()];
                                
                                );
                }
            }
            
            //    if (ch == 13) {
		//	if (ch == 3 && ((status_ == 0x90) || (status_ == 0x80))) {
				//NSString *str = [NSString stringWithFormat:@"ch %d -- %02X %02X %02X\n", ch, status_, data1, data2];
              //  NSLog(@"ch %d -- %d %0d %d\n", ch,  status, data1, data2);
				//NSNotification *notification = [NSNotification notificationWithName:@"MIDI Callback" object:str];
				//[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
		//	}
         //   }
		}
            break;
        case CRMD_CALLBACK_TYPE_SYSTEM_EXCLUSIVE_MESSAGE:
            break;
        default:
            break;
	}

}

- (void)setAutoplayChannels:(NSArray *)autoplayChannels {
    _autoplayChannels = autoplayChannels;
    
    if (!autoplayChannels) return;
    
    for (int i = 0; i < 16; i++) {
        if ([autoplayChannels containsObject:[NSNumber numberWithInt:i]]) {
            channelsToAutoplay[i] = YES;
        } else {
            channelsToAutoplay[i] = NO;
        }
    }
}

- (NSString *)getCurrentProgram:(int)channel {
    char name[128];
	api->ctrl (handle, CRMD_CTRL_GET_INSTRUMENT_NAME+channel, name, sizeof (name));
	
	NSString *string = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
	return string;
}



@end
