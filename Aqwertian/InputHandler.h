//
//  InputHandler.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/19/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Synchronizer.h"
//#import "NotationDisplay.h"
//#include "MySync.h"
//#include "MaxSeqDoc.h"
//#import "Structs.h"

#define EVBUF 512

@class NotationDisplay;


@interface InputHandler : NSObject <SynchronizerDelegate> {

//CMaxMidiOut* EchoOut;

//MySync *Sync;   // Only important when doing CMP and recording, so that you can
// finish
//CMaxSeqDoc* pDoc;

Play_state *m_PS;
int initial_programs[16];
BOOL StopProgram;
BOOL StopPedal;
BOOL StopWheel;
int StopNote;
int StopF0;
int scroll_penult;
int bufNoteOff;
}

@property NotationDisplay *NotationDisplay;
@property BOOL IgnoreInput;
@property BOOL Band;
@property BOOL MuteBand;
@property (readonly) Play_state *PS;
+ (InputHandler *)sharedHandler;
+ (InputHandler *)bandHandler;
+ (Piece *)readMusFile:(char *)file;
+ (void) deletePiece:(Piece *)p;
+ (void) doChording:(Piece *)aPiece;
+ (void) doColumns:(Piece *)aPiece;
+ (void) normalize:(Piece *)aPiece;
+ (void) removeExmatch:(Piece *)aPiece;
+ (NSArray *)getTracks:(NSString *)aFile;
+ (NSArray *)getEvents:(NSString *)aFile;
+ (void) getKeysForKey:(char)key buffer:(int *)array;

- (BOOL) ProcessMidiData:(LPMIDIEVENT )lpEvent;

- (void) keyDown:(char)key velocity:(int)velocity;
- (void) keyUp:(char)key;

- (void) StartNewMeasure:(Measure *)m;
- (void) AdvanceLine:(int)ln;
- (void) FlushBuf;
- (int) PlayMeasureStart;
- (void) GoToNextPlayable:(int)ln;
- (void) MoveGraceNotes:(int)hand;
- (int) FindRightNote:(Krec_event *)ke;
- (void) KillBeat:(int) hand;
- (void) InitPlayState:(Piece *)p vol:(int) volperc;
- (void) DeletePlayState;
- (void) PassThrough:(Krec_event *)ke;

- (void) ShouldIScroll;   /* For the display -- should I scroll it? */
- (void) RedrawDisplay;
- (void) DisplayNote:(Note *)n;
- (void) DisplayBouncingBall:(Note *)n;
- (void) SetUpProjections:(int) hand;
- (void) DisplayYAH:(int) invalidate;
- (void) DeleteYAH:(int) invalidate;

- (void) UnplayNote:(Note *)n time:(struct timeval *)tv;
- (void) PlayTies:(Note *)n onoff:(int) onoff event:(Krec_event *)ke hand:(int) hand;
- (void) FinishPiece;


//void SetEchoOutput(CMaxMidiOut* moDevice) { EchoOut = moDevice; };
@property BOOL Thru;
@property BOOL Recording;
@property BOOL FreePlay;

- (void) FinishRecording;
- (void) prepareToPlay:(Piece *)aPiece;
- (void) StartCmp:(Piece *)p measure:(int) start_measure;
- (int) PlayMeasure:(LPMIDIEVENT)lpMsg;
- (void) ProcessBeat:(int)beats;
- (void) PlayNote:(Note *)n time:(struct timeval *)tv hand:(int) hand;


extern int mins[3];
extern int maxs[3];



@end
