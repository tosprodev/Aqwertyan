//
//  MicrophoneManager.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/9/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "MicrophoneManager.h"
#import "Novocaine.h"
#import "RingBuffer.h"





//MicrophoneManager *theMic = nil;
Novocaine *audioManager;
RingBuffer *ringBuffer = nil;
float volume;
BOOL _on;


@implementation MicrophoneManager

+ (void)initialize {
    volume = 1;
}

+ (BOOL)startPassthrough {
    
    @try {
        if (ringBuffer == nil) {
            ringBuffer = new RingBuffer(32768, 2);
        }
        
        if (audioManager == nil) {
            
            audioManager = [Novocaine audioManager];
            
            [audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
                vDSP_vsmul(data, 1, &volume, data, 1, numFrames*numChannels);
                ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
            }];
            
            
            [audioManager setOutputBlock:^(float *outData, UInt32 numFrames, UInt32 numChannels) {
                ringBuffer->FetchInterleavedData(outData, numFrames, numChannels);
            }];
            
            volume = 0.5;
        }
        if (!audioManager.playing) {
            [audioManager play];
        }

    }
    @catch (NSException *exception) {
        return NO;
    }
       _on = YES;
    return _on;
}

+ (float)volume {
    return volume;
}

+ (BOOL)isOn {
    return _on;
}

+ (void)stop {
    _on = NO;
    [audioManager pause];
}

+ (void)setVolume:(double)avolume {
    volume = avolume;
}


@end