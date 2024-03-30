//
//  ExternalMIDIManager.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/12/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMidi.h"
//#import "Structs.h"

@class ExternalMIDIManager;

typedef NS_ENUM(NSInteger, MIDIConnectionChangeType) {
    MIDIConnectionChangeTypeNewSource,
    MIDIConnectionChangeTypeNewDestination,
    MIDIConnectionChangeTypeSourceRemoved,
    MIDIConnectionChangeTypeDestinationRemoved
};

@protocol MIDIManagerDelegate <NSObject>

- (void) connectionsChanged:(ExternalMIDIManager *)manager type:(MIDIConnectionChangeType)changeType connection:(PGMidiConnection *)connection;
- (void) eventReceived:(NSString *)event;

@end

@interface ExternalMIDIManager : NSObject <PGMidiDelegate, PGMidiSourceDelegate>

+ (ExternalMIDIManager *)sharedManager;

@property (readonly) NSArray *Sources;
@property (readonly) NSArray *Destinations;
@property (nonatomic) PGMidiSource *Source;
@property (nonatomic) PGMidiDestination *Destination;
@property (nonatomic) BOOL AcceptAllSources;

@property id<MIDIManagerDelegate> Delegate;

- (BOOL)hasSource;
- (BOOL)hasDestination;
- (void) sendBytes:(const UInt8 *)data length:(int)length;


@end
