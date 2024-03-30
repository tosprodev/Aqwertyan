//
//  KeyboardView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/20/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitView.h"
#import "AudioPlayer.h"
#import "ButtonKey.h"
#import "Arrangement.h"

//#define USE_OLD

char ToLetterKey(char key);



@interface KeyboardView : InitView <ButtonKeyDelegate>

@property AudioPlayer *Player;
@property BOOL UsePressure;
@property (nonatomic) float velocitySensitivity;
@property BOOL shouldAcceptInput;
@property (nonatomic) float volume;
@property (nonatomic) KeyboardType mode;
@property (nonatomic) float expectedNoteExpansion;

+ (KeyboardView *) sharedView;

- (IBAction)pitchBend:(id)sender;
- (void) setColumned:(BOOL)columned;
- (void) noteOn:(char)key;
- (void) noteHighlight:(char)key duration:(NSTimeInterval)dur;
- (void) noteUnhighlight:(char)key duration:(NSTimeInterval)dur;
- (void) noteOff:(char)key;
- (void) reset;
- (BOOL) pedalIsOn;


@end

@interface KeyDownInfo : NSObject {
    
}



@property (nonatomic, retain) UITouch* touch;
@property (nonatomic) float originalY, currentY;
@property (nonatomic, retain) ButtonKey* keyView;
@property (nonatomic) BOOL expanded;
@end
