//
//  RotatingNamePlate.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/10/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "RotatingNamePlate.h"
#import <QuartzCore/QuartzCore.h>
#import "AudioPlayer.h"
#import "SongSelectionController.h"
#import "MusFileManager.h"
//#import "InputHandler.h"
#import "SongOptions.h"
#import "NZInputHandler.h"

#define SONG 1
#define INSTRUMENT 2

#define IMG_HEIGHT 33

@implementation RotatingNamePlate {
    UIImageView *theImageView;
    UITouch *theTouch;
    NSInteger initialY, lastY;
    NSInteger theImageIndex;
    UILabel *theLabel;
    UILabel *theSongLabel;
    NSInteger theMode;
    NSInteger initialMode;
    NSInteger program;
    NSDate *initialTime;
    bool flashing;
}


////
# pragma markj - INIT
//

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void) setup {
    theImageIndex = 0;
    theImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rotating-plate.png"]];
    [theImageView setFrame:CGRectMake(0, 0, theImageView.image.size.width, theImageView.image.size.height)];
    [self addSubview:theImageView];
    self.clipsToBounds = YES;
    
    theSongLabel = [UILabel new];
    [self addSubview:theSongLabel];
    theSongLabel.alpha = 0;
    
    theLabel = [UILabel new];
    [self addSubview:theLabel];
    [theLabel setFrame:CGRectMake(5, 0, self.frame.size.width - 10, self.frame.size.height)];
    [theSongLabel setFrame:theLabel.frame];
    theLabel.backgroundColor = theSongLabel.backgroundColor = [UIColor clearColor];
    theLabel.font = theSongLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:20];
    theLabel.textColor = [UIColor colorWithRed:44.0/255.0 green:30.0/255.0 blue:4.0/255.0 alpha:1];
    theLabel.shadowOffset = theSongLabel.shadowOffset = CGSizeMake(0,1);
    theLabel.shadowColor = theSongLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    theLabel.textAlignment = theSongLabel.textAlignment =  UITextAlignmentCenter;
    theLabel.adjustsFontSizeToFitWidth = theSongLabel.adjustsFontSizeToFitWidth =  YES;
    //theLabel.layer.shadowOpacity = 0.5;
    
    theLabel.text = @"GRAND PIANO";
    theSongLabel.text = @"FUR ELISE";
    theMode = INSTRUMENT;
    program = -1;
    [self performSelector:@selector(updateProgram) withObject:nil afterDelay:0.1f];
}


////
# pragma mark - SEGUES
//

- (void) showSongSelection {
    [[PerformanceViewController sharedController] showLibrary];
}

- (void)flashSongName {
    if (theMode == SONG) return;
    theImageIndex = 0;
    flashing = YES;
    [self flip];
    [self performSelector:@selector(flip) withObject:nil afterDelay:3];
    [self performSelector:@selector(doneFlashing) withObject:nil afterDelay:4];
}

- (void) doneFlashing {
    flashing = NO;
}

- (int)program {
    return program;
}


////
# pragma mark - SONG CONTROL
//

- (void)setSong:(NSString *)text {
    theSongLabel.text = text;
}


////
# pragma mark - PROGRAM CONTROL
//

- (void)next:(id)sender {
     if (theMode == INSTRUMENT) {
    if (program < 127) {
        program++;
    }
         for (NSNumber *ch in [SongOptions activeChannels]) {
             [[AudioPlayer sharedPlayer] setProgram:program forChannel:[ch intValue]];
         }
       //  [[AudioPlayer sharedPlayer] setProgram:program forChannel:0];
    
    [self performSelector:@selector(updateProgram) withObject:nil afterDelay:0.1f];
     }
    [[NZInputHandler sharedHandler] userDidChangeProgram];
}

- (void)previous:(id)sender {
    if (theMode == INSTRUMENT) {
    if (0 < program) {
        program--;
    }
        for (NSNumber *ch in [SongOptions activeChannels]) {
            [[AudioPlayer sharedPlayer] setProgram:program forChannel:[ch intValue]];
        }
    
    [self performSelector:@selector(updateProgram) withObject:nil afterDelay:0.1f];
    }
    [[NZInputHandler sharedHandler] userDidChangeProgram];
}

- (void) updateProgram {
    if ([SongOptions activeChannels].count) {
    [self setProgramName:[NSString stringWithFormat:@"%@",[[AudioPlayer sharedPlayer] getCurrentProgram:[[SongOptions activeChannels][0] intValue]]]];
    }
}

- (void)setProgramName:(NSString *)text {
    text = [text uppercaseString];
    theLabel.text = text;
}



////
# pragma mark - TOUCHES
//

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    theTouch = [[touches allObjects] lastObject];
    initialY = [theTouch locationInView:self].y;
    initialMode = theMode;
    initialTime = [NSDate date];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    theTouch = [[touches allObjects] lastObject];
    lastY = [theTouch locationInView:self].y;
    float diff = lastY - initialY;
    
    if (flashing) return;
    
    theImageIndex = 12*MIN(diff,IMG_HEIGHT)/IMG_HEIGHT;
    if (theImageIndex > 5) {
        theMode = (initialMode == SONG) ? INSTRUMENT : SONG;
    } else {
        theMode = initialMode;
    }
   // NSLog(@"%d", theImageIndex);
    [self updateImage];
}

////
# pragma mark - ANIMATIONS
//


- (void) updateImage {
    if (theImageIndex == 12 || theImageIndex < 0) theImageIndex = 0;
    [theImageView setFrame:CGRectMake(0, -theImageIndex * IMG_HEIGHT, theImageView.frame.size.width, theImageView.frame.size.height)];
    
    float x;
    switch (theImageIndex) {
        case 0:
            x = 1;
            break;
        case 1:
            x = 0.65;
            break;
        case 2:
            x = 0.5;
            break;
        case 3:
            x = 0.3;
            break;
        case 4:
            x = 0.16;
            break;
        case 5:
            x = 0.05;
            break;
        case 6:
            x = 0;
            break;
        case 7:
            x = 0.05;
            break;
        case 8:
            x = 0.2;
            break;
        case 9:
            x = 0.4;
            break;
        case 10:
            x = 0.6;
            break;
        case 11:
            x = 0.8;
            break;
            
        default:
            break;
    }
    theLabel.transform = theSongLabel.transform = CGAffineTransformMakeScale(1.0, x);
    if (theImageIndex < 2 || theImageIndex > 6) theLabel.shadowOffset = theSongLabel.shadowOffset = CGSizeMake(0,1);
    else   theLabel.shadowOffset = theSongLabel.shadowOffset = CGSizeMake(0,0);
    
    if (theMode == INSTRUMENT) {
        theSongLabel.alpha = 0;
        theLabel.alpha = 1;
    } else {
        theSongLabel.alpha = 1;
        theLabel.alpha = 0;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (flashing) return;
    [self animate];
}

- (void) animate {
    if (flashing) return;
    if (theImageIndex < 12 && theImageIndex > 0) {
        if (theImageIndex > 5) theImageIndex++;
        else theImageIndex--;
        [self performSelector:@selector(updateImage) withObject:nil afterDelay:0.05];
        if (theImageIndex < 12 && theImageIndex > 0) {
            [self performSelector:@selector(animate) withObject:nil afterDelay:0.05];
        }
    }
}

- (void) flip {
    theImageIndex++;
    if (theImageIndex == 6) {
    if (theMode == SONG) {
        theMode = INSTRUMENT;
    } else {
        theMode = SONG;
    }
    }
    [self performSelector:@selector(updateImage) withObject:nil afterDelay:0.03];
    if (theImageIndex < 12) {
        [self performSelector:@selector(flip) withObject:nil afterDelay:0.03];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    theTouch = [[touches allObjects] lastObject];
    lastY = [theTouch locationInView:self].y;
    if (theMode == SONG && abs(lastY - initialY) < 5 && [[NSDate date] timeIntervalSinceDate:initialTime] < 1) {
        [self showSongSelection];
    }
    [self animate];
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
