//
//  MIDINote.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/19/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "MIDIEvent.h"

@interface MIDINote : MIDIEvent

@property UInt8 Channel;
@property UInt8 Note;
@property UInt8 Velocity;
@property UInt8 ReleaseVelocity;
@property NSInteger Track;

@end
