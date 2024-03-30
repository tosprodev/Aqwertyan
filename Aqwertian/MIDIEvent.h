//
//  MIDIEvent.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/19/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	BEnumNoteEvent,
	BEnumTempoEvent,
	BEnumLyricEvent,
    BEnumChannelEvent
} MIDIEventType;

@interface MIDIEvent : NSObject {
    NSInteger startTime;
}

@property MIDIEventType EventType;
@property NSInteger StartTime;

@end
