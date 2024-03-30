//
//  KeyboardView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/20/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "KeyboardView.h"
#import "InputHandler.h"
#import "CPBPressureTouchGestureRecognizer.h"
#import "ButtonKey.h"
#import "NZInputHandler.h"
#import "SongOptions.h"
#import "Util.h"
#import "PitchBendWheel.h"

#define LINE_0 8
#define LINE_1 20
#define LINE_2 31
#define LINE_3 41
#define TOUPPER(a) (a + 'A'-'a')
#define BUTTON_PADDING 0

static KeyboardView *theKeyboardView;


@implementation KeyDownInfo
@end

@implementation KeyboardView {
    NSMutableArray *theKeys, *theThumbKeys;
    NSMutableSet* keyDownSet;
    CPBPressureTouchGestureRecognizer *thePressureRecognizer;
    NSMutableDictionary *keys, *thumbKeys;
    UIImageView *leftWood, *rightWood, *thumbCovers;
    int pedalOn;
    UIView *thumbView;
    PitchBendWheel *wheel;
    BOOL _usePressure;
}



+ (void)initialize {

}


////
# pragma mark - INIT
//

+ (KeyboardView *)sharedView {
    return theKeyboardView;
}

- (void)setup {
    pedalOn = 0;
    _mode = KeyboardTypeFullQwerty;
    leftWood = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piano-wood-left.png"]];
    rightWood= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piano-wood-right.png"]];
    thumbCovers = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumb-covers.png"]];
    [self addSubview:leftWood];
    [self addSubview:rightWood];
    [self addSubview:thumbCovers];
    [thumbCovers sizeToFit];
    [rightWood sizeToFit];
    [leftWood sizeToFit];
    rightWood.center = CGPointMake(1003, 134);
    leftWood.center = CGPointMake(21, 134);
    CGRect frame = thumbCovers.frame;
    frame.origin.y = self.frame.size.height - thumbCovers.frame.size.height;
    thumbCovers.frame = frame;
    theKeyboardView = self;
    rightWood.hidden = leftWood.hidden = thumbCovers.hidden = YES;
    self.expectedNoteExpansion = 40;
    _velocitySensitivity = 1;

    theKeys = [NSMutableArray new];
    keyDownSet = [NSMutableSet new];
    keys = [NSMutableDictionary new];
    thumbKeys = @{}.mutableCopy;
    theThumbKeys = @[].mutableCopy;
    
    thumbView = [UIView new];
    thumbView.backgroundColor = [UIColor clearColor];
    [thumbView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:thumbView];
    thumbView.hidden = YES;
    
    wheel = [PitchBendWheel sharedWheel];

    NSInteger i = 0;
    for (; i < LINE_0; i++) {
        [theKeys addObject:[self newButtonWithChar:[self charForKey:i]]];
        [self addSubview:[theKeys lastObject]];
        [[theKeys lastObject] setCenter:[self centerForKey:i]];
        [[theKeys lastObject] setHidden:YES];
        
        [theThumbKeys addObject:[self newThumbKeyWithChar:[self charForKey:i]]];
        [thumbView addSubview:theThumbKeys.lastObject];
        [theThumbKeys.lastObject setHidden:YES];
        [theThumbKeys.lastObject setCenter:[self centerForThumbKey:i]];
        [(UIView *)theThumbKeys.lastObject setTransform:CGAffineTransformMakeRotation([self angleForThumbKey:i])];
    }
    i+=2;
    for (; i < LINE_1; i++) {
        [theKeys addObject:[self newButtonWithChar:[self charForKey:i]]];
        [self addSubview:[theKeys lastObject]];
        [[theKeys lastObject] setCenter:[self centerForKey:i]];
        
        [theThumbKeys addObject:[self newThumbKeyWithChar:[self charForKey:i]]];
        [thumbView addSubview:theThumbKeys.lastObject];
        [theThumbKeys.lastObject setHidden:YES];
        [theThumbKeys.lastObject setCenter:[self centerForThumbKey:i]];
       
    }
    for (; i < LINE_2; i++) {
        [theKeys addObject:[self newButtonWithChar:[self charForKey:i]]];
        [self addSubview:[theKeys lastObject]];
        [[theKeys lastObject] setCenter:[self centerForKey:i]];
       // [[theKeys lastObject] setHidden:YES];
        
        [theThumbKeys addObject:[self newThumbKeyWithChar:[self charForKey:i]]];
        [thumbView addSubview:theThumbKeys.lastObject];
        [theThumbKeys.lastObject setHidden:YES];
        [theThumbKeys.lastObject setCenter:[self centerForThumbKey:i]];
    }
    for (; i < LINE_3; i++) {
        [theKeys addObject:[self newButtonWithChar:[self charForKey:i]]];
        [self addSubview:[theKeys lastObject]];
        [[theKeys lastObject] setCenter:[self centerForKey:i]];
      //  [[theKeys lastObject] setHidden:YES];
        
        [theThumbKeys addObject:[self newThumbKeyWithChar:[self charForKey:i]]];
        [thumbView addSubview:theThumbKeys.lastObject];
        [theThumbKeys.lastObject setHidden:YES];
        [theThumbKeys.lastObject setCenter:[self centerForThumbKey:i]];
    }
    for (; i < LINE_3+2; i++) {
        [theKeys addObject:[self newButtonWithChar:[self charForKey:i]]];
        [self addSubview:[theKeys lastObject]];
        [[theKeys lastObject] setCenter:[self centerForKey:i]];
        
        [theThumbKeys addObject:[self newThumbKeyWithChar:[self charForKey:i]]];
        [thumbView addSubview:theThumbKeys.lastObject];
        [theThumbKeys.lastObject setHidden:YES];
        [theThumbKeys.lastObject setCenter:[self centerForThumbKey:i]];
    }
    
    //[self setFrame:self.frame];
    self.multipleTouchEnabled = YES;
    thumbView.multipleTouchEnabled = YES;
    self.Player = [AudioPlayer sharedPlayer];
   // thePressureRecognizer = [[CPBPressureTouchGestureRecognizer alloc] initWithTarget:self action:@selector(pressure:)];
    _shouldAcceptInput = YES;
    //[self addGestureRecognizer:thePressureRecognizer];
}

- (void)setUsePressure:(BOOL)UsePressure {
    _usePressure = UsePressure;
    if (_usePressure) {
        if (thePressureRecognizer == nil) {
            thePressureRecognizer = [[CPBPressureTouchGestureRecognizer alloc] initWithTarget:self action:@selector(pressure:)];
        }
        
    } else {
        thePressureRecognizer = nil;
    }
    
}

- (BOOL)UsePressure {
    return _usePressure;
}


////
#pragma mark - PITCH BEND
//

- (void) pitchBend:(id)sender {
 //   [self.Player pitchBend:10];
}


////
#pragma mark - TOUCHES
//
//
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = [self pointInside:point withEvent:event];
    if (inside) return self;
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = [self keyViewForPoint:point withEvent:event initialTouch:YES info:nil] != nil;
    return inside;
}

-(UIView *)findSubviewAtPoint:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            UIView *theView = [view hitTest:[self convertPoint:point toView:view] withEvent:event];
            if (theView) return theView;
        }
    }
    return nil;
}

- (void)setMode:(KeyboardType)mode {
    if (mode != _mode) {
        _mode = mode;
        [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
            [self showHideKeys];
        }completion:nil];
    }
}

//- (void)setPianoKeys:(BOOL)pianoKeys {
//    if (_pianoKeys != pianoKeys) {
//        _pianoKeys = pianoKeys;
//       
//        
//       // [self setNeedsDisplay];
//    }
//}

- (BOOL)pedalIsOn {
    return pedalOn > 0;
}

- (void) showHideKeys {
    for (int i = 0; i < theKeys.count-2; i++) {
        ButtonKey *key = theKeys[i];
        ButtonKey *thumbKey = theThumbKeys[i];
        if (i < LINE_0) {
            key.hidden = _mode != KeyboardTypeFullPiano;
            thumbKey.hidden = _mode != KeyboardTypeThumbPiano;
        } else {
            key.hidden = _mode != KeyboardTypeFullQwerty;
            thumbKey.hidden = _mode != KeyboardTypeThumbQwerty;
        }
    }
    rightWood.hidden = leftWood.hidden = _mode != KeyboardTypeFullPiano;
    if (_mode == KeyboardTypeThumbPiano || _mode == KeyboardTypeThumbQwerty) {
        thumbView.hidden = NO;
        thumbCovers.hidden = NO;
    } else {
        thumbView.hidden = YES;
        thumbCovers.hidden = YES;
    }
}

- (KeyDownInfo*)findKey:(UITouch*)touch {
//    NSArray* keyDownArray = [keyDownSet allObjects];
//    for (int i = 0; i < [keyDownArray count]; ++i) {
//        KeyDownInfo* keyDown = [keyDownArray objectAtIndex:i];
    for (KeyDownInfo *keyDown in keyDownSet) {
        if (keyDown.touch == touch) {
            return keyDown;
        }
    }
    return nil;
}

- (UIView *) tryGetKeyViewForPoint:(CGPoint)point initialToucn:(BOOL)initial info:(KeyDownInfo *)info event:(UIEvent *)event {
    UIView *theView;
    if (info.expanded) {
        if ([info.keyView containsPoint:point withExpansion:_expectedNoteExpansion]) {
            theView = info.keyView;
        }
    } else if (_mode == KeyboardTypeFullQwerty) {
        theView = [self findExpectedKeyForPoint:point event:event];
        if (theView) info.expanded = YES;
        else info.expanded = NO;
    } 
    return theView;
}

- (ButtonKey*)keyViewForPoint:(CGPoint)point withEvent:(UIEvent *)event initialTouch:(BOOL)initial info:(KeyDownInfo *)info {
    UIView *theView = [self tryGetKeyViewForPoint:point initialToucn:initial info:info event:event];
    if (!theView) {
        theView = [self findSubviewAtPoint:point withEvent:event];
        info.expanded = NO;
    }
    if (theView.class != [ButtonKey class]) return nil;
    return (ButtonKey *)theView;
}

- (ButtonKey *) findExpectedKeyForPoint:(CGPoint)point event:(UIEvent *)event {
    NSArray *expectedKeys = [NZInputHandler sharedHandler].expectedNotes;
    
    if (event) {
        ButtonKey *actualKey = (ButtonKey *)[self findSubviewAtPoint:point withEvent:event];
        if ([expectedKeys containsObject:@(actualKey.tag)]) {
            return actualKey;
        }
    }
    for (NSNumber *key in expectedKeys) {
        ButtonKey *button = keys[key];
        if ([button containsPoint:point withExpansion:_expectedNoteExpansion]) {
            return button;
        }
    }
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSArray* touchArray = [touches allObjects];
//    for (int i = 0; i < [touchArray count]; ++i) {
//        UITouch* touch = [touchArray objectAtIndex:i];
   // NSLog(@"TOUCH");
    for (UITouch *touch in touches) {
        KeyDownInfo* keyPress = [self findKey:touch];
        if (keyPress) {
            NSLog(@"Unexpected; Touch already began: %@", touch);
            continue;
        } else {
            keyPress = [[KeyDownInfo alloc] init];
        }
        
        ButtonKey *keyView = [self keyViewForPoint:[touch locationInView:self] withEvent:event initialTouch:YES info:keyPress];
        if (!keyView || keyView.tag == 0) {
            continue;
        }
        [keyView keyDown:nil];
        if (keyView.tag == ' ' || keyView.tag == '_') {
            pedalOn++;
        }
       // [keyboardDelegate noteOn:[keyView keyNumber]];
        
        // Store the key for later access
        
        keyPress.touch = touch;
        keyPress.keyView = keyView;
        keyPress.originalY = keyPress.currentY = [touch locationInView:keyView].y;
        float height = keyView.frame.size.height;
        if (_mode == KeyboardTypeFullPiano && height > 100) {
            PitchBend(keyPress.currentY, keyPress.originalY, height, wheel);
        }
        
        [keyDownSet addObject:keyPress];
    }
}

void NormalPitchBend(PitchBendWheel *wheel) {
    [wheel doPitchBend:1];
}

void PitchBend(float currentY, float originalY, float height, PitchBendWheel *wheel) {
    float offset = PitchBendOffset(currentY, originalY, height);
    float bend = 1 + offset;

    [wheel doPitchBend:bend];
}

float PitchBendOffset(float currentY, float originalY, float height) {
    if (currentY > height) currentY = height;
    if (currentY < 0) currentY = 0;
    float offset = (currentY - originalY) / (height * 0.5);
    return -offset;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        KeyDownInfo* keyPress = [self findKey:touch];
        if (!keyPress) {
            // We got forwarded a touch that did not start on the keyboard.  It might
            // be worth handling this (and the touch moved off a key case below)
            continue;
        }
        ButtonKey *keyView = [self keyViewForPoint:[touch locationInView:self] withEvent:event initialTouch:NO info:keyPress];
        if (keyPress.keyView == keyView) {
            float height = keyView.frame.size.height;
            if (_mode == KeyboardTypeFullPiano && height > 100) {
                keyPress.currentY = [touch locationInView:keyView].y;
                PitchBend(keyPress.currentY, keyPress.originalY, height, wheel);
            }

            // The touch moved, but did not change keys
            continue;
        }
        if (!keyView) {
            // The touch moved off of a key.  Do not update the current key pressed
            // and continue to play the same note.  The "off" event will be handled
            // in touchesEnded.
            continue;
        }
        
        // Press the new key, release the old key
        [keyView keyDown:nil];
       // [keyboardDelegate noteOn:[keyView keyNumber]];
        ButtonKey* previousKeView = keyPress.keyView;
        [previousKeView keyUp:nil];
        if (previousKeView.tag == ' ' || previousKeView.tag == '_') {
            pedalOn--;
        }
       // [keyboardDelegate noteOff:[previousKeView keyNumber]];
        
        // Record the new key that is being pressed
        keyPress.keyView = keyView;
        

    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    float maxBend = 0;
//    KeyDownInfo *maxInfo = nil;
//    for (KeyDownInfo *info in keyDownSet) {
//        float bend = ABS(PitchBendOffset(info.currentY, info.originalY, info.keyView.frame.size.height));
//        if (bend > maxBend) {
//            maxBend = bend;
//            maxInfo = info;
//        }
//    }
    for (UITouch *touch in touches) {
        KeyDownInfo* keyPress = [self findKey:touch];
        if (!keyPress) {
            // The TouchForwardingUIScrollView may invoke us multiple times for the
            // same event as a workaround for its parent UIScrollView not always
            // invoking touchesEnded.
            continue;
        }
        ButtonKey* previousKeyView = keyPress.keyView;
        [previousKeyView keyUp:nil];
        if (previousKeyView.tag == ' ' || previousKeyView.tag == '_') {
            pedalOn--;
        }
        
        
        //[keyboardDelegate noteOff:[previousKeyView keyNumber]];
        
        // Stop tracking the touch event
        [keyDownSet removeObject:keyPress];
    }
    
//    if (![keyDownSet containsObject:maxInfo]) {
//        if (keyDownSet.count == 0) {
//            NormalPitchBend(wheel);
//        } else {
//            float maxBend = 0;
//            KeyDownInfo *maxInfo = nil;
//            for (KeyDownInfo *info in keyDownSet) {
//                float bend = ABS(PitchBendOffset(info.currentY, info.originalY, info.keyView.frame.size.height));
//                if (bend > maxBend) {
//                    maxBend = bend;
//                    maxInfo = info;
//                }
//            }
//            if (maxInfo) {
//                PitchBend(maxInfo.currentY, maxInfo.originalY, maxInfo.keyView.frame.size.height, wheel);
//            } else {
//                NormalPitchBend(wheel);
//            }
//        }
//    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

////
#pragma mark - KEY EVENTS
//

- (void) pressure:(id)sender {
    NSLog(@"pressure");
}

- (void) keyDown:(id)sender {
    if (!_shouldAcceptInput) return;
    UIButton *theButton = (UIButton *)sender;
    if (theButton.tag == ' ' || theButton.tag == '_') {
        for (NSNumber *channel in [SongOptions activeChannels]) {
            [self.Player pedalOn:channel.intValue];
        }
    } else {
        if (self.UsePressure) {
            [thePressureRecognizer start];
            [self performSelector:@selector(logPressure:) withObject:theButton afterDelay:0.05];
        } else {
            char key = theButton.tag;
            if (_mode == KeyboardTypeFullPiano) {
                key = ToLetterKey(key);
            }
           [[NZInputHandler sharedHandler] handleNoteOn:key velocity:-1 autoOff:NO andHandleKey:NO];
        }
    }
}

char ToLetterKey(char key) {
    if (!(key >= '0' && key <= '9')) {
        return key;
    }
    switch (key) {
        case '1':
            return 'A';
            break;
        case '2':
            return 'S';
            break;
        case '3':
            return 'D';
            break;
        case '4':
            return 'F';
            break;
        case '5':
            return 'J';
            break;
        case '6':
            return 'K';
            break;
        case '7':
            return 'L';
            break;
        case '8':
            return ';';
            break;
            
        default:
            return 'A';
            break;
    }
}

-(void)setVelocitySensitivity:(float)velocitySensitivity {
    if (velocitySensitivity > 1.5) velocitySensitivity = 1.5;
    if (velocitySensitivity < 0.5) velocitySensitivity = 0.5;
    _velocitySensitivity = velocitySensitivity;
}

- (void)noteOff:(char)key {
    if (_mode == KeyboardTypeFullPiano) {
        key = ToNumberKey(key);
    }
    ButtonKey *theKey = [self currentButtonForKey:key];
    
    theKey.highlighted = NO;
}

- (void)noteHighlight:(char)key duration:(NSTimeInterval)dur {
    if (_mode == KeyboardTypeFullPiano) {
        key = ToNumberKey(key);
    }
    ButtonKey *theKey = [self currentButtonForKey:key];
    if (ios5 || scaleBack) {
        theKey.selected = YES;
    } else {
    [UIView transitionWithView:theKey
                      duration:MAX(0, dur-0.1)
                       options:(UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction)
                    animations:^{  theKey.selected = YES; }
                    completion:nil];
    }
   
}

- (ButtonKey *) currentButtonForKey:(char)key {
    ButtonKey *theKey = nil;
    if (key == ' ' || key == '_') {
        theKey = keys[@(key)];
    }
    else if (_mode == KeyboardTypeThumbQwerty || _mode == KeyboardTypeThumbPiano) {
        theKey = thumbKeys[@(key)];
    } else {
        theKey = keys[@(key)];
    }
    return theKey;
}

- (void)noteUnhighlight:(char)key duration:(NSTimeInterval)dur {
    if (_mode == KeyboardTypeFullPiano) {
        key = ToNumberKey(key);
    }
    ButtonKey *theKey = [self currentButtonForKey:key];
    if (ios5 || scaleBack) {
        theKey.selected = NO;
    } else {
    [UIView transitionWithView:theKey
                      duration:dur
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                    animations:^{  theKey.selected = NO; [theKey setNeedsDisplay];}
                    completion:nil];
    }
}

- (void)noteOn:(char)key {
    if (_mode == KeyboardTypeFullPiano) {
        key = ToNumberKey(key);
    }
    ButtonKey *theKey = [self currentButtonForKey:key];
//    [UIView transitionWithView:theKey
//                      duration:0.1
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
                        theKey.selected = NO;
                        theKey.highlighted = YES;
//                    }
//                    completion:nil];
   
}



#define min(a,b) a > b ? b : a
- (void) logPressure:(ButtonKey *)theButton {
    
   // NSLog(@"%f", thePressureRecognizer.pressure);
    float pressure = 50;
    pressure += min(thePressureRecognizer.pressure * 127 * _velocitySensitivity, 127-50);
    char key = theButton.tag;
    if (_mode == KeyboardTypeFullPiano) {
        key = ToLetterKey(key);
    }
    [[NZInputHandler sharedHandler] handleNoteOn:key velocity:pressure autoOff:NO andHandleKey:NO];
    [thePressureRecognizer end];
}
- (void)reset {
    for (ButtonKey *theKey in theKeys) {
        theKey.highlighted = NO;
        theKey.selected = NO;
    }
    for (ButtonKey *theKey in theThumbKeys) {
        theKey.highlighted = NO;
        theKey.selected = NO;
    }
    pedalOn=0;
}

- (void) keyUp:(id)sender {
    if (!_shouldAcceptInput) return;
    UIButton *theButton = (UIButton *)sender;
    if (theButton.tag == ' ' || theButton.tag == '_') {
        for (NSNumber *channel in [SongOptions activeChannels]) {
            [self.Player pedalOff:channel.intValue];
        }
    } else {
        char key = theButton.tag;
        if (_mode == KeyboardTypeFullPiano) {
            key = ToLetterKey(key);
        }
        if (self.UsePressure) {
            double delayInSeconds = 0.05;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NZInputHandler sharedHandler] handleNoteOff:key andHandleKey:NO];
            });
        } else {
        [[NZInputHandler sharedHandler] handleNoteOff:key andHandleKey:NO];
        }
    }
    //[self performSelector:@selector(setKeyUp:) withObject:sender afterDelay:0.1];
}

- (void) setKeyUp:(ButtonKey *)theButton {
    if (!_shouldAcceptInput) return;
    if (theButton.tag == ' ' || theButton.tag == '_') {
        for (NSNumber *channel in [SongOptions activeChannels]) {
            [self.Player pedalOff:channel.intValue];
        }
    } else {
#ifdef USE_OLD
     [[InputHandler sharedHandler] keyUp:theButton.tag];   
#else
        [[NZInputHandler sharedHandler] handleNoteOff:ToLetterKey(theButton.tag) andHandleKey:NO];
#endif
         
    
    }
}


////
#pragma mark - UTILITY FUNCTIONS
//

- (UIButton *)newButtonWithChar:(char)aChar {
    ButtonKey *theButton = [ButtonKey new];
    [theButton setChar:aChar thumb:NO];
    theButton.Delegate = self;
    
    keys[[NSNumber numberWithChar:aChar]] = theButton;
    
    return theButton;
}

- (UIButton *) newThumbKeyWithChar:(char)aKey {
    ButtonKey *theButton = [ButtonKey new];
    [theButton setChar:aKey thumb:YES];
    theButton.Delegate = self;
    
    thumbKeys[[NSNumber numberWithChar:aKey]] = theButton;
    
    return theButton;
}


- (char) charForKey:(int)key {
    switch (key) {
        case 0:
            return '1';
            break;
        case 1:
            return '2';
            break;
        case 2:
            return '3';
            break;
        case 3:
            return '4';
            break;
        case 4:
            return '5';
            break;
        case 5:
            return '6';
            break;
        case 6:
            return '7';
            break;
        case 7:
            return '8';
            break;
        case 8:
            return '9';
            break;
        case 9:
            return '0';
            break;
        case 10:
            return 'Q';
            break;
        case 11:
            return 'W';
            break;
        case 12:
            return 'E';
            break;
        case 13:
            return 'R';
            break;
        case 14:
            return 'T';
            break;
        case 15:
            return 'Y';
            break;
        case 16:
            return 'U';
            break;
        case 17:
            return 'I';
            break;
        case 18:
            return 'O';
            break;
        case 19:
            return 'P';
            break;
        case 20:
            return 'A';
            break;
        case 21:
            return 'S';
            break;
        case 22:
            return 'D';
            break;
        case 23:
            return 'F';
            break;
        case 24:
            return 'G';
            break;
        case 25:
            return 'H';
            break;
        case 26:
            return 'J';
            break;
        case 27:
            return 'K';
            break;
        case 28:
            return 'L';
            break;
        case 29:
            return ';';
            break;
        case 30:
            return '\'';
            break;
        case 31:
            return 'Z';
            break;
        case 32:
            return 'X';
            break;
        case 33:
            return 'C';
            break;
        case 34:
            return 'V';
            break;
        case 35:
            return 'B';
            break;
        case 36:
            return 'N';
            break;
        case 37:
            return 'M';
            break;
        case 38:
            return ',';
            break;
        case 39:
            return '.';
            break;
        case 40:
            return '/';
            break;
        case 41:
            return ' ';
            break;
        case 42:
            return '_';
            break;

        default:
            return ' ';
            break;
    }
}

static const float startAngle = M_PI_2 - 0.19;
static const float endAngle = 0.23;
static const float angleIncrement = (endAngle - startAngle) / 3;
static const float radius = 142;

- (CGFloat) angleForThumbKey:(int)key {
    float angle = 0;
    
    switch (key) {
            
            // 12345
        case 0:
            angle = startAngle + angleIncrement * 0;
            break;
        case 1:
            angle = startAngle + angleIncrement * 1;
            break;
        case 2:
            angle = startAngle + angleIncrement * 2;
            break;
        case 3:
            angle = startAngle + angleIncrement * 3;
            break;
        case 4:
            angle = M_PI + (M_PI-[self angleForThumbKey:0]);
            break;
            
            // 67890
        case 5:
            angle = M_PI + (M_PI-[self angleForThumbKey:1]);
            break;
        case 6:
             angle = M_PI + (M_PI-[self angleForThumbKey:2]);
            break;
        case 7:
             angle = M_PI + (M_PI-[self angleForThumbKey:3]);
            break;
        default:
            break;
    }
    if (key < 4)
        return ABS(M_PI_2 - angle);
    else
        return -M_PI_2 - angle + 0.04;
}

- (CGPoint) centerForThumbKey:(int)key {
    double x,y;
    
//    CGPoint center = [self centerForKey:key];
//    if (key < 4) {
//        center.x *= 0.6;
//        center.y *= 0.6;
//    } else {
//        center.x = 1024 - ((1024 - center.x) * 0.6);
//        center.y *= 0.6;
//    }
//    return center;
    
    static const float width = 90.0;
    static const float halfWidth = width/2.0;
    static const float padding = 7.0;
    static const float rightHandStart = 1024.0 - (width * 2) - (padding * 3);

    
    BOOL rh = key >= 4;
    if (rh) {
        //key -= 4;
    }
    
    float angle = [self angleForThumbKey:key];
    angle = M_PI_2 - angle;
    x = radius * cos(angle);
    y = radius * sin(angle);
    if (!rh) {
        return CGPointMake(x, radius - y + 132);
    } else {
        return CGPointMake(x + 1024, radius - y + 132);
    }
    
    switch (key) {
            
        case 0:
            x = halfWidth + padding;
            y = halfWidth + padding;
            break;
        case 1:
            x = width + padding*2 + halfWidth;
            y = halfWidth + padding;
            break;
        case 2:
            x = halfWidth + padding;
            y = width + padding*2 + halfWidth;
            break;
        case 3:
            x = width + padding*2 + halfWidth;
            y = width + padding*2 + halfWidth;
            break;
        case 4:
            x = rightHandStart + halfWidth + padding;
            y = halfWidth + padding;
            break;
            
            // 67890
        case 5:
            x = rightHandStart + width + padding*2 + halfWidth;
            y = halfWidth + padding;
            break;
        case 6:
            x = rightHandStart + halfWidth + padding;
            y = width + padding*2 + halfWidth;
            break;
        case 7:
            x = rightHandStart + width + padding*2 + halfWidth;
            y = width + padding*2 + halfWidth;
            break;
        case 8:
            x = 777;
            y = 78;
            break;
        case 9:
            x = 896;
            y = 56;
            break;

            
            // 12345
//        case 0:
//            x = halfWidth + padding;
//            y = halfWidth + padding;
//            break;
//        case 1:
//            x = width + padding*2 + halfWidth;
//            y = halfWidth + padding;
//            break;
//        case 2:
//            x = halfWidth + padding;
//            y = width + padding*2 + halfWidth;
//            break;
//        case 3:
//            x = width + padding*2 + halfWidth;
//            y = width + padding*2 + halfWidth;
//            break;
//        case 4:
//            x = rightHandStart + halfWidth + padding;
//            y = halfWidth + padding;
//            break;
//            
//            // 67890
//        case 5:
//            x = rightHandStart + width + padding*2 + halfWidth;
//            y = halfWidth + padding;
//            break;
//        case 6:
//            x = rightHandStart + halfWidth + padding;
//            y = width + padding*2 + halfWidth;
//            break;
//        case 7:
//            x = rightHandStart + width + padding*2 + halfWidth;
//            y = width + padding*2 + halfWidth;
//            break;
//        case 8:
//            x = 777;
//            y = 78;
//            break;
//        case 9:
//            x = 896;
//            y = 56;
//            break;
            
            // QWERT
        case 10:
            x = 52;
            y = 55;
            break;
        case 11:
            x = 147;
            y = 73;
            break;
        case 12:
            x = 250;
            y = 92;
            break;
        case 13:
            x = 353;
            y = 110;
            break;
        case 14:
            x = 454;
            y = 129;
            break;
            
            // YUIOP
        case 15:
            x = 557;
            y = 131;
            break;
        case 16:
            x = 646;
            y = 114;
            break;
        case 17:
            x = 748;
            y = 97;
            break;
        case 18:
            x = 850;
            y = 78;
            break;
        case 19:
            x = 958;
            y = 58;
            break;
            
            // ASDFG
        case 20:
            x = 48;
            y = 144;
            break;
        case 21:
            x = 140;
            y = 162;
            break;
        case 22:
            x = 243;
            y = 180;
            break;
        case 23:
            x = 346;
            y = 199;
            break;
        case 24:
            x = 443;
            y = 216;
            break;
            
            //HJKL;
        case 25:
            x = 576;
            y = 216;
            break;
        case 26:
            x = 668;
            y = 200;
            break;
        case 27:
            x = 770;
            y = 182;
            break;
        case 28:
            x = 873;
            y = 164;
            break;
        case 29:
            x = 969;
            y = 145;
            break;
            
            
            //        case 30:
            //            x = 50;
            //            y = 138;
            //            break;
            // ZXCVB
        case 31:
            x = 45;
            y = 233;
            break;
        case 32:
            x = 134;
            y = 250;
            break;
        case 33:
            x = 237;
            y = 268;
            break;
        case 34:
            x = 339;
            y = 287;
            break;
        case 35:
            x = 431;
            y = 303;
            break;
            
            // NM,./
        case 36:
            x = 596;
            y = 302;
            break;
        case 37:
            x = 692;
            y = 285;
            break;
        case 38:
            x = 794;
            y = 267;
            break;
        case 39:
            x = 897;
            y = 249;
            break;
        case 40:
            x = 982;
            y = 232;
            break;
            
            // Sustain
        case 41:
            x = 354;
            y = 364;
            break;
        case 42:
            x = 671;
            y = 364;
            break;
            
        default:
            x = 492;
            y = 361;
            break;
    }
    return CGPointMake(x, y+10);
    
}

- (CGPoint) centerForKey:(int)key {
    double x,y;
    switch (key) {
            
            // 12345
        case 0:
            x = 81;
            y = 150;
            break;
        case 1:
            x = 198;
            y = 172;
            break;
        case 2:
            x = 315;
            y = 193;
            break;
        case 3:
            x = 431;
            y = 213;
            break;
        case 4:
            x = 594;
            y = 213;
            break;
            
            // 67890
        case 5:
            x = 711;
            y = 192;
            break;
        case 6:
            x = 826;
            y = 171;
            break;
        case 7:
            x = 944;
            y = 151;
            break;
        case 8:
            x = 777;
            y = 78;
            break;
        case 9:
            x = 896;
            y = 56;
            break;
            
        // QWERT
        case 10:
            x = 52;
            y = 55;
            break;
        case 11:
            x = 147;
            y = 73;
            break;
        case 12:
            x = 250;
            y = 92;
            break;
        case 13:
            x = 353;
            y = 110;
            break;
        case 14:
            x = 454;
            y = 129;
            break;
            
        // YUIOP
        case 15:
            x = 557;
            y = 131;
            break;
        case 16:
            x = 646;
            y = 114;
            break;
        case 17:
            x = 748;
            y = 97;
            break;
        case 18:
            x = 850;
            y = 78;
            break;
        case 19:
            x = 958;
            y = 58;
            break;
        
        // ASDFG
        case 20:
            x = 48;
            y = 144;
            break;
        case 21:
            x = 140;
            y = 162;
            break;
        case 22:
            x = 243;
            y = 180;
            break;
        case 23:
            x = 346;
            y = 199;
            break;
        case 24:
            x = 443;
            y = 216;
            break;
            
        //HJKL;
        case 25:
            x = 576;
            y = 216;
            break;
        case 26:
            x = 668;
            y = 200;
            break;
        case 27:
            x = 770;
            y = 182;
            break;
        case 28:
            x = 873;
            y = 164;
            break;
        case 29:
            x = 969;
            y = 145;
            break;
            
        
//        case 30:
//            x = 50;
//            y = 138;
//            break;
        // ZXCVB
        case 31:
            x = 45;
            y = 233;
            break;
        case 32:
            x = 134;
            y = 250;
            break;
        case 33:
            x = 237;
            y = 268;
            break;
        case 34:
            x = 339;
            y = 287;
            break;
        case 35:
            x = 431;
            y = 303;
            break;
            
        // NM,./
        case 36:
            x = 596;
            y = 302;
            break;
        case 37:
            x = 692;
            y = 285;
            break;
        case 38:
            x = 794;
            y = 267;
            break;
        case 39:
            x = 897;
            y = 249;
            break;
        case 40:
            x = 982;
            y = 232;
            break;
            
        // Sustain
        case 41:
            x = 354;
            y = 364;
            break;
        case 42:
            x = 671;
            y = 364;
            break;
            
        default:
            x = 492;
            y = 361;
            break;
    }
    return CGPointMake(x, y);
}

////
# pragma mark - LAYOUT
//

- (void)setColumned:(BOOL)columned {
    for (int i = 0; i < theKeys.count; i++) {
        [[theKeys objectAtIndex:i] setColumned:columned];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    
//    NSInteger height = frame.size.height - BUTTON_PADDING*5;
//    height /= 5;
//    NSInteger width = frame.size.width - BUTTON_PADDING*11;
//    width /= 12;
//    
//    int i = 0;
//    for (i = 0; i < theKeys.count; i++) {
//        [[theKeys objectAtIndex:i] setCenter:[self centerForKey:i]];
//    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"begin");
//    [self getKeys:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"moved");
//    [self getKeys:touches withEvent:event];
//}
//
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//     NSLog(@"ended");
//   // [onButtons removeAllObjects];
//    for (UITouch *touch in touches) {
//        UIView *theButton = [super hitTest:[touch locationInView:self] withEvent:event];
//        if (theButton) {
//        [onButtons removeObject:theButton];
//        if (theButton != self) {
//            [(ButtonKey *)theButton keyUp:nil];
//        }
//        }
//    }
//}
//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    return self;
//}

//- (void) getKeys:(NSSet *)touches withEvent:(UIEvent *)event {
//    [onButtons removeAllObjects];
//    for (UITouch *touch in touches) {
//        UIView *theButton = [super hitTest:[touch locationInView:self] withEvent:event];
//        if (theButton) {
//        [onButtons addObject:theButton];
//        if (theButton != self) {
//            [(ButtonKey *)theButton keyDown:nil];
//        }
//        }
//    }
//    for (ButtonKey *theButton in theKeys) {
//        if (![onButtons containsObject:theButton]) {
//            [theButton keyUp:nil];
//        }
//    }
//}
