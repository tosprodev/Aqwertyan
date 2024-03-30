//
//  Header.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#ifndef Aqwertian_mid2jmid_h
#define Aqwertian_mid2jmid_h

#import "SongOptions.h"

void mid2jmidmain(NSArray *args);
NSArray *get_program_events(NSString *aFile);
NSArray *get_events(NSString *aFile);



@interface NZMidiEvent : NSObject

@property NSInteger Event;
@property NSInteger Note;
@property NSInteger Velocity;

@end


#endif
