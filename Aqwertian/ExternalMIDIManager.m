//
//  ExternalMIDIManager.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/12/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "ExternalMIDIManager.h"

@implementation ExternalMIDIManager {
    PGMidi *midi;
}

+ (ExternalMIDIManager *)sharedManager {
    static ExternalMIDIManager *manager = nil;
    
    if (!manager) {
        manager = [ExternalMIDIManager new];
    }
    
    return manager;
}

- (id)init {
    self = [super init];
    midi = [[PGMidi alloc] init];
    midi.delegate = self;
    self.AcceptAllSources = YES;
    for (PGMidiSource *source in midi.sources) {
        source.delegate = self;
    }
    return self;
}

- (NSArray *)Sources {
    return midi.sources;
}

- (NSArray *)Destinations {
    return midi.destinations;
}

- (BOOL)hasSource {
    for (PGMidiSource *source in self.Sources) {
        if (source.delegate == self && !source.isNetworkSession) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasDestination {
    for (PGMidiDestination *dest in self.Destinations) {
        if (!dest.isNetworkSession) {
            return YES;
        }
    }
    return NO;
}

- (void)setAcceptAllSources:(BOOL)AcceptAllSources {
    _AcceptAllSources = AcceptAllSources;
    if (AcceptAllSources) {
        for (PGMidiSource *source in self.Sources) {
            source.delegate = self;
        }
    } else {
        for (PGMidiSource *source in self.Sources) {
            source.delegate = (source == self.Source) ? self : nil;
        }
    }
}

////
# pragma mark - MIDI DELEGATE
//

- (void)midi:(PGMidi *)midi destinationAdded:(PGMidiDestination *)destination {
    [self.Delegate connectionsChanged:self type:MIDIConnectionChangeTypeNewDestination connection:destination];
}

- (void)midi:(PGMidi *)midi destinationRemoved:(PGMidiDestination *)destination {
    if (destination == self.Destination) {
        self.Destination = nil;
    }
    [self.Delegate connectionsChanged:self type:MIDIConnectionChangeTypeDestinationRemoved connection:destination];
}

- (void)midi:(PGMidi *)midi sourceAdded:(PGMidiSource *)source {
    if (self.AcceptAllSources) {
        source.delegate = self;
    }
    [self.Delegate connectionsChanged:self type:MIDIConnectionChangeTypeNewSource connection:source];
}

- (void)midi:(PGMidi *)midi sourceRemoved:(PGMidiSource *)source {
    if (source == self.Source) {
        self.Source = nil;
    }
    [self.Delegate connectionsChanged:self type:MIDIConnectionChangeTypeSourceRemoved connection:source];
}

- (void)midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList {
    MIDIPacket *packet = &packetList->packet[0];
  
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        if (packet->length > 2) {
            [(NSObject *)self.Delegate performSelectorOnMainThread:@selector(eventReceived:)
                                   withObject:[NSString stringWithFormat:@"%02x %02x %02x", packet->data[0], packet->data[1], packet->data[2]]
                                waitUntilDone:NO];
        }
        packet = MIDIPacketNext(packet);
    }
}

//- (MidiEvent *) eventFromPacket:(MIDIPacket *)packet {
//    MidiEvent *Evt = malloc(sizeof(MidiEvent));
//	Evt->time = 0xFFFFFFFF;
//
//    Evt->status = packet->data[0];
//		Evt->data1 = packet->data[1];
//		Evt->data2 = packet->data[2];
//    
//    return Evt;
//}

- (void)sendBytes:(const UInt8 *)date length:(int)length {
    [midi sendBytes:date size:length];
}



@end
