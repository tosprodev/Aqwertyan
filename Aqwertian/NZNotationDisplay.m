 //
//  NZNotationDisplay.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 1/10/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "NZNotationDisplay.h"
#import "MusicFile.h"
#import "NZInputHandler.h"
#import "Mus.h"
#import "NowLine.h"
#import "RollersView.h"
#import "NoteView.h"
#import <QuartzCore/QuartzCore.h>
#import "Conversions.h"
#import "AudioPlayer.h"
#import "PerformanceViewController.h"
#import "LyricView.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "NSObject+NZHelpers.h"
#import "OverlayView.h"

#define MIN_WIDTH_TWOROW 25


#define INNER_PADDING 25
#define OUTER_PADDING 32
#define VERTICAL_PADDING 18

#define TO_OUTER_COORD(x) (x + INNER_PADDING + OUTER_PADDING)
#define TO_INNER_COORD(x) (x - INNER_PADDING - OUTER_PADDING)

NZNotationDisplay *theNZNotationDisplay;

@implementation NZNotationDisplay {
    UIImageView *_shadeView;
    NowLine *_nowLineEven, *_nowLineOdd;
    RollersView *_rollers;
    NSMutableArray *_views, *_lyricViews;
    BOOL setup;
    
    NZInputHandler *inputHandler;
    
    CADisplayLink *timer;
    float lastUpdate, lastX;
    
    BOOL hasRefreshed;
    BOOL trackingNowLine;
    BOOL wasPaused;
    
    int viewIndex;
    
    double _nowLineOffset;
    
    UIImageView *measureView;
    
    NSArray *_notes, *_lyrics;
    
    int lastTime;
    BOOL ignoreScrollingForRollers;
    
    UIScrollView *_lyricsView;
    UIView *_lyricsBG;
    AudioPlayer *_player;
    
    NSMutableArray *activeOverlays, *allOverlays;
}

- (id)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size = CGSizeMake(1, 1);
    }
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

+ (NZNotationDisplay *)sharedDisplay {
    return theNZNotationDisplay;
}

- (void) setup {
    if (setup) return; setup = YES;
    
    activeOverlays = [NSMutableArray new];
    allOverlays = [NSMutableArray new];
    self.delegate = self;
    self.widthMultiplier = 0.25;
    self.animationDuration = 0.25;
    self.autoCalculateWidthMultiplier = YES;
    self.userInteractionEnabled = YES;
    _widthBase = 80;
    self.gestureRecognizers = nil;
    self.performanceHighlightingEnabled = YES;

    _mode = NOTATION_MOVING_NOW;
    
    theNZNotationDisplay = self;
    
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"paper.png"]]];
    
    self.contentSize = CGSizeMake(self.frame.size.width*10, self.frame.size.height);
//    measureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note-grid.png"]];
//    [self addSubview:measureView];
//    [measureView setFrame:CGRectMake(INNER_PADDING, VERTICAL_PADDING, self.frame.size.width - 2*INNER_PADDING, self.frame.size.height-2*VERTICAL_PADDING)];
    measureView.layer.shouldRasterize=YES;
    measureView.layer.rasterizationScale=[UIScreen mainScreen].scale;
    
    self.showsHorizontalScrollIndicator = self.showsVerticalScrollIndicator = NO;
    self.bounces = NO;
    self.clipsToBounds = YES;
    
    _shadeView = [UIImageView new];
    _shadeView.image = [UIImage imageNamed:@"paper-shades.png"];
    [_shadeView setFrame:CGRectMake(0, 0, _shadeView.image.size.width, _shadeView.image.size.height)];
    _shadeView.userInteractionEnabled = NO;
    [_shadeView setCenter:self.center];
    
    _nowLineEven = [NowLine new];
    _nowLineOdd = [NowLine new];
   // _currentNowLine = _nowLineEven;
    
    _views  = [NSMutableArray new];
    _lyricViews  = [NSMutableArray new];
    
    _lyricsView = [UIScrollView new];
    _lyricsView.backgroundColor = [UIColor clearColor];
    _lyricsView.frame = CGRectMake(self.frame.origin.x, -4, self.frame.size.width, self.frame.origin.y+5);
//    _lyricsBG = [UIView new];
//    _lyricsBG.layer.shadowOpacity = 1;
//    _lyricsBG.layer.cornerRadius = _lyricsView.layer.cornerRadius = 3;
//    _lyricsBG.layer.shadowOffset=CGSizeMake(0,1);
//    _lyricsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_bg_tan.png"]];
//    _lyricsBG.backgroundColor = [UIColor whiteColor];
//    _lyricsBG.frame = _lyricsView.frame;
    
//    self.layer.shouldRasterize=YES;
//    self.layer.rasterizationScale=[UIScreen mainScreen].scale;
}

- (void)_clear {
    for (UIView *view in self.subviews) {
        if (view != measureView) {
            [view removeFromSuperview];
        }
    }
    for (UIView *view in _lyricsView.subviews) {
        [view removeFromSuperview];
    }
    [_views removeAllObjects];
    [_lyricViews removeAllObjects];
    [self clearOverlays];
   // hasRefreshed = NO;

}

- (void) clearOverlays {
    [activeOverlays removeAllObjects];
    for (UIView *overlay in allOverlays) {
        [overlay removeFromSuperview];
    }
    [allOverlays removeAllObjects];
}

- (void)setupForPerformanceStart {
  //  _currentNowLine = _nowLineEven;
    if (_mode == NOTATION_MOVING_NOW) {
        [_nowLineOdd setCenter:CGPointMake(-40, _nowLineEven.center.y)];
        [_nowLineEven setCenter:CGPointMake(INNER_PADDING + OUTER_PADDING, _nowLineEven.center.y)];
    } else {
        [_nowLineEven setCenter:CGPointMake(OUTER_PADDING + INNER_PADDING + (self.frame.size.width - INNER_PADDING*2)/2, _nowLineEven.center.y)];
        [_nowLineOdd setCenter:CGPointMake(-40, _nowLineEven.center.y)];
    }
    [self stopUpdates];
    hasRefreshed = NO;
    [self performSelector:@selector(startUpdates) withObject:nil afterDelay:0.01];
    lastX = 0;
    [[PerformanceViewController sharedController] performSelector:@selector(notationDisplayReady) withObject:nil afterDelay:1];
}

- (void) stopUpdates {
    timer.paused = YES;
}

- (void) startUpdates {
    if (!timer) {
        timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        timer.frameInterval = 1;
        [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
       
    }
    timer.paused = NO;
    lastTime = 0;
    lastUpdate = CACurrentMediaTime();
}

- (void)setMode:(int)mode {
    if (mode != _mode) {
        _mode = mode;
        scaleBack = mode == NOTATION_STATIONARY_NOW;
        
        // We need to rearrange the views on a mode switch
        [self arrangeViews:YES];
        [self clearOverlays];
    }
}


- (void)noteChangedState:(ComAqwertianFingeringMusicFile_Note *)note {
    NoteView *view = (NoteView *)note.noteView;
    if (view) {
        [view setState:note.state duration:0];
    }
}

- (void) resetRollers {
    ignoreScrollingForRollers = NO;
}

- (void)setShowLyrics:(BOOL)showLyrics {
    if (_showLyrics != showLyrics) {
        _showLyrics = showLyrics;
//            [UIView beginAnimations:@"Show" context:nil];
//            [UIView setAnimationDuration:0.6];
        [self positionLyricView];
//            [UIView commitAnimations];
        
    }
               

    _lyricsView.alpha = showLyrics? 1 : 0;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    static int count = 0;
    if (count < 2) {
        [self arrangeExternalElements];
        count++;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self arrangeExternalElements];
}

- (void) arrangeExternalElements {
    [_shadeView setFrame:self.frame];
    _nowLineEven.center = CGPointMake(-40, self.center.y+1);
    _nowLineOdd.center = CGPointMake(-40, self.center.y+1);
    _rollers.frame = CGRectMake(0,0,self.frame.size.width + 12, self.frame.size.height + 30);
    [_rollers setCenter:self.center];
}

- (void) arrangeViews:(BOOL)animated {
    
    // Layout the "measure" views
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationDidStopSelector:@selector(resetRollers)];
        ignoreScrollingForRollers = YES;
    }
    
    // Break up the notes across the pages if in moving now mode
    for (RGNote *note in _notes) {
        if (note.note > 0) {
            NoteView *nv = (NoteView *)note.noteView;
            if (_mode == NOTATION_MOVING_NOW) {
                [nv showAttachedViews];
            } else {
                [nv collapseAttachedViews];
            }
        }
    }
    
    for (int i = 0; i < _views.count; i++) {
        UIImageView *v = _views[i];
        UIView *lv = _lyricViews[i];
        if (_mode == NOTATION_MOVING_NOW) {
            if (i%2 == 0) {
                lv.frame = CGRectMake(INNER_PADDING, 0, (self.frame.size.width - INNER_PADDING*2)/2.0, _lyricsView.frame.size.height);
                v.frame = CGRectMake(INNER_PADDING, VERTICAL_PADDING, (self.frame.size.width - INNER_PADDING*2)/2.0-2, self.frame.size.height- 2*VERTICAL_PADDING);
                
            } else {
                lv.frame = CGRectMake(INNER_PADDING +(self.frame.size.width - INNER_PADDING*2)/2.0, 0.0, (self.frame.size.width - INNER_PADDING*2)/2.0, _lyricsView.frame.size.height-2*VERTICAL_PADDING);
                v.frame = CGRectMake(INNER_PADDING +(self.frame.size.width - INNER_PADDING*2)/2.0, VERTICAL_PADDING, (self.frame.size.width - INNER_PADDING*2)/2.0-2, self.frame.size.height - 2*VERTICAL_PADDING);
            }
            v.alpha = lv.alpha = (i == viewIndex || i == viewIndex+1)
;
        } else {
            lv.frame = CGRectMake(INNER_PADDING +i*(self.frame.size.width - INNER_PADDING*2)/2.0, 0, (self.frame.size.width - INNER_PADDING*2)/2.0, _lyricsView.frame.size.height);
            v.frame = CGRectMake(INNER_PADDING +i*(self.frame.size.width - INNER_PADDING*2)/2.0, VERTICAL_PADDING, (self.frame.size.width - INNER_PADDING*2)/2.0-2, self.frame.size.height-2*VERTICAL_PADDING);
            v.alpha = lv.alpha = 1;
        }
    }
  

    
    // Set the background image frame
    if (_mode == NOTATION_STATIONARY_NOW) {
       
        // Find the length of the canvas
        float maxPoint = [(RGNote *)[_notes lastObject] time] + [(RGNote *)[_notes lastObject] duration];
        maxPoint *= _widthMultiplier;
        
        [self setContentSize:CGSizeMake(maxPoint + 500, self.contentSize.height)];
        [measureView setFrame:CGRectMake(INNER_PADDING, VERTICAL_PADDING, maxPoint, self.frame.size.height-2*VERTICAL_PADDING)];
        for (int i = _views.count-1; i > -1; i--) {
            [self bringSubviewToFront:_views[i]];
        }
    } else {
        [self setContentSize:self.frame.size];
        
        
        [measureView setFrame:CGRectMake(INNER_PADDING, VERTICAL_PADDING, self.contentSize.width - 2*INNER_PADDING, self.frame.size.height-2*VERTICAL_PADDING)];
    }
    _lyricsView.contentSize = CGSizeMake(self.contentSize.width, _lyricsView.frame.size.height);
    [self positionLyricView];
    if (animated) {
        [UIView commitAnimations];
    }
    if (_mode == NOTATION_MOVING_NOW) {
        [_lyricsView setContentOffset:CGPointMake(0, 0) animated:animated];
        [self setContentOffset:CGPointMake(0, 0) animated:animated];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mode == NOTATION_MOVING_NOW) {
        float nowLineX = TO_INNER_COORD(_nowLineEven.center.x);
        float touchX = [touches.anyObject locationInView:self].x - INNER_PADDING;
        if (ABS(touchX - nowLineX) < 20) {
            trackingNowLine = YES;
            [[NZInputHandler sharedHandler] pause];
        }
    } else {
        trackingNowLine = YES;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event  {
    if (trackingNowLine) {
    trackingNowLine = NO;
     [[AudioPlayer sharedPlayer] attenuate:0.65];   
    }
}

- (void)noteOn:(RGNote *)note timing:(int)earlyLate {
    if (!_performanceHighlightingEnabled) return;
    if (note.note == 0) return;
    NoteView *noteView = (NoteView *)note.noteView;
    
    OverlayView *overlay = [self createOverlayViewForTiming:earlyLate];
    overlay.note = note;
    
//    if (note.noteView.frame.origin.x + note.noteView.frame.size.width > note.noteView.superview.bounds.size.width) {
//        overlay.extend = YES;
//    }
    
    UIView *currentMeasureView = [self currentMeasureView];
    float offsetX = (_mode == NOTATION_MOVING_NOW) ? _nowLineEven.center.x - OUTER_PADDING : self.contentOffset.x + self.frame.size.width/2;
    float overlayX = offsetX - currentMeasureView.frame.origin.x;
    
    CGRect frame = [self _rectForNote:note];//noteView.frame;
   // frame.origin.y += 3;
    //frame.size.height -= 6;
    frame.origin.x = overlayX;
    frame.size.width = 0;
    overlay.frame = frame;
    [currentMeasureView addSubview:overlay];
    
    [activeOverlays addObject:overlay];
    [allOverlays addObject:overlay];
    [note.overlays addObject:overlay];
}

- (OverlayView *) duplicateOverlay:(OverlayView *)overlay {
    OverlayView *view = [OverlayView new];
    view.note = overlay.note;
    view.backgroundColor = overlay.backgroundColor;
    return view;
}

- (OverlayView *) createOverlayViewForTiming:(int)earlyLate {
    OverlayView *view = [OverlayView new];
    if (earlyLate < 0) {
        view.backgroundColor = OverlayViewEarlyColor;
    } else if (earlyLate > 0) {
        view.backgroundColor = OverlayViewLateColor;
    } else {
        view.backgroundColor = OverlayViewOnTimeColor;
    }
    return view;
}

- (void)noteOff:(RGNote *)note wasPerfect:(BOOL)perfect heldForRightLength:(BOOL)rightLength {
    if (note.note == 0) return;
    
    OverlayView *overlay = nil;
    for (OverlayView *ov in activeOverlays) {
        if (ov.note == note) {
            overlay = ov;
            break;
        }
    }
    
    if (overlay) {
        [activeOverlays removeObject:overlay];
        overlay.moving = NO;
        if (overlay.position == OverlayViewPositionCenter) {
            overlay.position = OverlayViewPositionRight;
        } else if (overlay.position == OverlayViewPositionLeft) {
            overlay.position = OverlayViewPositionNone;
        }
    }
    if (perfect) {
        for (OverlayView *overlay in note.overlays) {
            [overlay wasPerfect];
        }
    } else if (rightLength) {
        for (OverlayView *overlay in note.overlays) {
            [overlay wasHeldForRightLength];
        }
    }
}

- (UIView *) currentMeasureView {
    if (_mode == NOTATION_MOVING_NOW) {
    float width = self.frame.size.width;
    float nowLineX = _nowLineEven.center.x - OUTER_PADDING;
    if (nowLineX > width/2 && _views.count > viewIndex+1) {
        return _views[viewIndex+1];
    } else if (viewIndex < _views.count) {
        return _views[viewIndex];
    }
    return nil;
    } else {
        float width = (self.frame.size.width - INNER_PADDING*2)/2.0;
        float offset = self.contentOffset.x + self.frame.size.width/2 - INNER_PADDING;
        
        int index = (int)(offset / width);
        if (index > -1 && index < _views.count) {
            return _views[index];
        }
        return nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (_mode == NOTATION_MOVING_NOW) {
        float nowLineX = TO_INNER_COORD(_nowLineEven.center.x);
        float previousX = [touch previousLocationInView:self].x - INNER_PADDING;
        if (trackingNowLine || ABS(nowLineX - previousX) < 20) {
            if (!trackingNowLine) {
                trackingNowLine = YES;
                [[NZInputHandler sharedHandler] pause];
            }
            float offset = [touch locationInView:self].x - INNER_PADDING;
            if (offset > self.frame.size.width - INNER_PADDING * 2 + 20) {
                offset = self.frame.size.width - INNER_PADDING*2 + 2;
                trackingNowLine = NO;
                [[AudioPlayer sharedPlayer] attenuate:0.65];
            } else if (offset > self.frame.size.width - INNER_PADDING*2) {
                if (previousX > offset) return;
                offset = self.frame.size.width - INNER_PADDING*2;
                
            } else if (offset < -20) {
                offset = -2;
                trackingNowLine = NO;
                [[AudioPlayer sharedPlayer] attenuate:0.65];
            } else if (offset < 1) {
                offset = 1;
            }
            float newTicks = (self.frame.size.width - INNER_PADDING*2) * (viewIndex/2) + offset;
            newTicks /= _widthMultiplier;
            _nowLineEven.center = CGPointMake(TO_OUTER_COORD(offset), _nowLineEven.center.y);
            [[NZInputHandler sharedHandler] setCurrentTicks:newTicks sound:YES];
        } else {
            
        }
    } else {
        float diff = [touch locationInView:self].x - [touch previousLocationInView:self].x;
        float newX = self.contentOffset.x + self.frame.size.width/2 - INNER_PADDING - diff;
        if (newX > self.contentSize.width - self.frame.size.width) {
            newX = self.contentSize.width - self.frame.size.width;
        }
        self.contentOffset = CGPointMake(newX - self.frame.size.width/2 + INNER_PADDING, self.contentOffset.y);
        float newTicks = newX / _widthMultiplier;
        [[NZInputHandler sharedHandler] setCurrentTicks:newTicks sound:YES];
        NSLog(@"%f 0 %f", self.contentOffset.x, self.contentSize.width);
    }
}

- (void)cancelOverlaysForNote:(ComAqwertianFingeringMusicFile_Note *)n {

    [activeOverlays removeObjectsInArray:n.overlays];
    for (UIView *v in n.overlays) {
        [v removeFromSuperview];
    }
    [n.overlays removeAllObjects];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (trackingNowLine) {
        trackingNowLine = NO;
        [[AudioPlayer sharedPlayer] attenuate:0.65];   
    }
}

- (void) positionLyricView {
//    if (_mode == NOTATION_STATIONARY_NOW) {
//        if (_showLyrics) {
//            _lyricsView.frame = CGRectMake(self.frame.origin.x, -5, self.frame.size.width, self.frame.origin.y+5);
//        } else {
//            _lyricsView.frame = CGRectMake(self.frame.origin.x, -self.frame.origin.y - 10, self.frame.size.width, self.frame.origin.y+5);
//        }
//    } else {
//        if (_showLyrics) {
//            _lyricsView.frame = CGRectMake(self.frame.origin.x, -5, self.frame.size.width, self.frame.origin.y+5);
//        } else {
//            _lyricsView.frame = CGRectMake(self.frame.origin.x, -self.frame.origin.y - 10, self.frame.size.width, self.frame.origin.y+5);
//        }
//    }
  //  [_lyricsBG setFrame:_lyricsView.frame];
   
}



- (void)placeNoteInView:(UIView *)noteView div:(float)div isLyric:(BOOL)lyric {
    if (YES || self.mode == NOTATION_MOVING_NOW) {
        float location = div;
        int index = 0;
        
        // Find the index of the view for this note
        while (location <= noteView.frame.origin.x + 5) {
            index++;
            location += div;
        }
        
        // Make sure we have enough views, and add the note view to the appropriate view
        while (index >= _views.count) {
            
            // Note views
            UIImageView *v = [UIImageView new];
            [_views addObject:v];
            v.image = [UIImage imageNamed:@"paper-grid.png"];
//            v.layer.shouldRasterize=YES;
//            v.layer.rasterizationScale=[UIScreen mainScreen].scale;
            [self addSubview:v];
            
            // Lyric views
            v = [UIView new];
            [_lyricViews addObject:v];
            [_lyricsView addSubview:v];
        }
        if (lyric) {
            [_lyricViews[index] addSubview:noteView];
        } else {
            [_views[index] addSubview:noteView];
            [_views[index] sendSubviewToBack:noteView];
            if (index%2 == 0) {
                [(NoteView *)noteView setIsFirstHalf:YES];
            }
        }
        
        // Adjust x origin for placement in the view
        CGRect frame = noteView.frame;
        frame.origin.x -= (location - div);
        noteView.frame = frame;
        
        double diff = noteView.frame.origin.x + noteView.frame.size.width - div;
        
        if (diff > 2 && !(index%2 == 1 && diff < 10) && !lyric/* && !(index%2 == 0 && diff < 20)*/) {

            NoteView *newNoteView = [NoteView new];
            
            CGRect frame = noteView.frame;
            double fixed = div - noteView.frame.origin.x;
            frame.origin.x = location;
            frame.origin.y = noteView.frame.origin.y;
            frame.size.width = diff;//noteView.frame.size.width - fixed;
            newNoteView.frame = frame;
            
            frame = noteView.frame;
            frame.size.width -=diff;// = fixed;
            
            if (index%2 != 0) {
                frame.size.width = MAX(frame.size.width, 20);
            }
            noteView.frame = frame;
            
            [(NoteView *)noteView addAttachedView:newNoteView];
            [self placeNoteInView:newNoteView div:div isLyric:NO];
        }
        
    } else {
        if (lyric) {
            [_lyricsView addSubview:noteView];
        } else {
            [self addSubview:noteView];
        }
    }
}

- (void)showStats:(BOOL)animated {
    [self stopUpdates];
    if (_statsDisplay.alpha == 1) return;
        _statsDisplay.hidden = NO;
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
    }
        for (UIView *view in _views) {
            view.alpha = 0;
        }
 
//    if (x > 1024/2) {
//        [_currentNowLine animateCenter:CGPointMake(1024, _currentNowLine.center.y) time:1];
//    } else {
//        [_currentNowLine animateCenter:CGPointMake(1024, _currentNowLine.center.y) time:1];
//    }
    _nowLineEven.alpha = _nowLineOdd.alpha = 0;
    _statsDisplay.alpha = 1;
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)hideStats:(BOOL)animated {
    if (_statsDisplay.alpha == 0) return;
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
    }
    _nowLineEven.alpha = _nowLineOdd.alpha = 1;
    _statsDisplay.alpha = 0;
    if (animated) {
        [UIView commitAnimations];
    }
    double delayInSeconds = animated ? 0.5 : 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _statsDisplay.hidden=YES;
    });
}

- (void)displayNotes:(NSArray *)notes lyrics:(NSArray *)lyrics {
    static float lastWidthBase = -1;
    viewIndex = 0;
    _nowLineOffset = 0;

 
        _player = [AudioPlayer sharedPlayer];
    
    if (notes == nil) {
        [self _clear];
        return;
    }
    
    if (notes == _notes && _widthBase == lastWidthBase && _lyrics == lyrics) {
        
//        if ([NZInputHandler sharedHandler].currentTime == 0) {
//            [self setupForPerformanceStart];
//            return;
//        }
        
        // If notes are already drawn, just set them all to unplayed.
        for (RGNote *n in _notes) {
            if (n.note > 0) {
                [(NoteView *)n.noteView setState:NORMAL duration:0];
            } else {
                [(LyricView *)n.noteView setState:NORMAL];
            }
            
        }
        for (RGNote *n in _lyrics) {
            [(LyricView *)n.noteView setState:NORMAL];
        }
        [self clearOverlays];
        for (RGNote *n in notes) {
            [n.overlays removeAllObjects];
        }
        [self arrangeViews:NO];
        
    } else {
        
        // Otherwise clear all old note views and create new ones
        [self _clear];
        _notes = notes;
        _lyrics = lyrics;
        if (_autoCalculateWidthMultiplier) {
            [self calculateWidthMultiplier];
        }
        _hasPendingNoteWidthChange = NO;
        
        inputHandler = [NZInputHandler sharedHandler];
        
        // This is the width of each individual measure view
        float div = (self.frame.size.width - INNER_PADDING*2.0) / 2.0;
        
        // Create a note view for each note and position it in the display
        if (lyrics.count) {
            notes = [notes arrayByAddingObjectsFromArray:lyrics];
        }
        for (RGNote *note in notes) {
            UIView *noteView;
            if (note.note == 0) {
                if (note.lyrics.length) {
                    char c = [note.lyrics characterAtIndex:0];
                    if (c == '@') {
                        note.lyrics = nil;
                    } else if (c == '/' || c == ' ' || c == '\\') {
                        if (note.lyrics.length > 1) {
                            note.lyrics = [note.lyrics substringFromIndex:1];
                        } else {
                            note.lyrics = nil;
                        }
                    }
                    if (note.lyrics) {
                        LyricView *view = [LyricView new];
                        note.noteView = view;
                        [view setLyric:note.lyrics];
                        noteView = view;
                        noteView.frame = [self _rectForNote:note];
                        CGSize size = [view sizeThatFits:view.frame.size];
                        if (size.width < view.frame.size.width) {
                            CGRect frame = view.frame;
                            frame.size.width = size.width;
                            [view setFrame:frame];
                        }
                    }
                }
            } else {
                noteView = [NoteView new];
                if (_exmatch) {
                    ((NoteView *)noteView).Note = [NSString stringWithFormat:@"%c", note.qwerty];
                }
                
                note.noteView = noteView;
                noteView.frame = [self _rectForNote:note];
                if (noteView.frame.origin.y > (self.frame.size.height - 2*VERTICAL_PADDING)/2 - 2) {
                    [(NoteView *)noteView setHand:LEFT_HAND];
                } else {
                    [(NoteView *)noteView setHand:RIGHT_HAND];
                }
                
            }
            if (noteView) {
             //   NSLog(@"placing note - %c", note.qwerty);
                [self placeNoteInView:noteView div:div isLyric:note.note == 0];
         
               
            }
        }
        
        // Arrange the views based on the display mode
        [self arrangeViews:NO];
        for (int i = _views.count-1; i > -1; i--) {
            [self bringSubviewToFront:_views[i]];
        }
    }
    
    lastWidthBase = _widthBase;
    
    if (_mode == NOTATION_MOVING_NOW) {
        for (UIView *view in _views) {
            view.alpha = 0;
        }
    
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.45];
            for (int i = 0; i < _views.count; i++) {
                [_views[i] setAlpha:i < 2];
                [_lyricViews[i] setAlpha:i < 2];
            }
            [UIView commitAnimations];
        });
    }
    
                
    // Get ready to start the performance
    [self setupForPerformanceStart];
    [self hideStats:YES];
}

- (void)setPerformanceHighlightingEnabled:(BOOL)performanceHighlightingEnabled {
    _performanceHighlightingEnabled = performanceHighlightingEnabled;
    if (!_performanceHighlightingEnabled) {
        [activeOverlays removeAllObjects];
        [self clearOverlays];
    }
}

- (void) updateOverlays {
    if (!_performanceHighlightingEnabled) return;
    float offsetX = (_mode == NOTATION_MOVING_NOW) ? _nowLineEven.center.x - OUTER_PADDING : self.contentOffset.x + self.frame.size.width/2;
    UIView *currentMeasure = [self currentMeasureView];
    if (currentMeasure == nil || activeOverlays.count == 0) return;
    NSMutableArray *toRemove = nil;
    NSMutableArray *toAdd = nil;
    for (OverlayView *overlay in activeOverlays) {
        if (_mode == NOTATION_MOVING_NOW && overlay.superview != currentMeasure) {
            if (toRemove == nil) toRemove = [NSMutableArray new];
            if (toAdd == nil) toAdd = [NSMutableArray new];
            CGRect frame = overlay.frame;
            frame.size.width = overlay.superview.frame.size.width - overlay.frame.origin.x + 2;
            overlay.frame = frame;
            OverlayView *newOverlay = [self duplicateOverlay:overlay];
            frame.origin.x = 0;
            frame.size.width = offsetX - currentMeasure.frame.origin.x;
            newOverlay.frame = frame;
            [currentMeasure addSubview:newOverlay];
            [toRemove addObject:overlay];
            overlay.moving = NO;
            if (overlay.position == OverlayViewPositionNone) {
                overlay.position = OverlayViewPositionLeft;
            } else if (overlay.position == OverlayViewPositionRight) {
                overlay.position = OverlayViewPositionCenter;
            } else {
                overlay.position = overlay.position;
            }
            
            newOverlay.position = OverlayViewPositionCenter;

            [toAdd addObject:newOverlay];
            [allOverlays addObject:newOverlay];
            [newOverlay.note.overlays addObject:newOverlay];
        } else {
            CGRect frame = overlay.frame;
            frame.size.width = offsetX - overlay.superview.frame.origin.x - frame.origin.x;
            overlay.frame = frame;
        }
    }
    if (toAdd) [activeOverlays addObjectsFromArray:toAdd];
    if (toRemove.count > 0) {
        [activeOverlays removeObjectsInArray:toRemove];
    }
}

- (void)startOneSecond {
    _nowLineEven.center = CGPointMake(10, _nowLineEven.center.y);
    [_nowLineEven animateCenter:CGPointMake(OUTER_PADDING + INNER_PADDING, _nowLineEven.center.y) time:1];
}
/*
 0.77 sec/beat  96 ticks/beat   0.77 sec/beat * (1/96) beats/tick
 */

- (void) update {
    if ([_nowLineEven animating] || [_nowLineOdd animating]) return;
    double time, diff, calc;
    
    if (NO) {//inputHandler.soloMode != INPUT_USER_DRIVE || !inputHandler.soloing || inputHandler.autoplaying) {
        time = CACurrentMediaTime();
        diff = MAX(0,time - inputHandler.startTime);
        //    if (diff > 0.1) {
        //        NSLog(@"%f", diff);
        //    }
        
        calc = inputHandler.startTicks + diff * inputHandler.ticksPerSecond;
        // calc = MAX(calc, inputHandler.startTicks + _pl)
    } else {
        time = CACurrentMediaTime();
        diff = MAX(0,time - inputHandler.time);
        calc = inputHandler.currentTicks + diff * inputHandler.ticksPerSecond;
    }
    lastUpdate = time;
    double x = MIN(inputHandler.currentTicks + _division/24, calc);
    if (inputHandler.performanceMode == PERFORMANCE_USER_DRIVEN) {
        x = MIN(x, inputHandler.stopTicks);
    }
    if (inputHandler.isPaused) {
        x = inputHandler.currentTicks;
    }
    if (x - lastX > 10) {
        //   NSLog(@"break");
    }
    lastX = x;
    x *= _widthMultiplier;
    
    if (_mode == NOTATION_STATIONARY_NOW) {
        
        float center = (self.frame.size.width - INNER_PADDING*2)/2;
        
        [self setContentOffset:CGPointMake(x - self.frame.size.width/2 + INNER_PADDING, 0) animated:NO];
        
        [_nowLineEven setCenter:CGPointMake(center + OUTER_PADDING + INNER_PADDING, _nowLineEven.center.y)];
        [self updateOverlays];

    } else {
        [self setupMeasureViewsForTime:x];
        
        float width = self.frame.size.width - INNER_PADDING*2;
        float offsetX = x - (width * (viewIndex/2));
        
        NowLine *currentNowLine = _nowLineEven;
        
        [currentNowLine setCenter:CGPointMake(offsetX + OUTER_PADDING + INNER_PADDING, currentNowLine.center.y)];
        [self updateOverlays];
//        if (x > self.frame.size.width * 0.7 && !hasRefreshed) {
//            
//            if (viewIndex + 2 < _views.count) {
//                [self refreshFirstHalf];
//                
//                _nextNowLine = (_currentNowLine == _nowLine1) ? _nowLine2 : _nowLine1;
//                _nextNowLine.center = CGPointMake(-40, _nextNowLine.center.y);
//                [self performSelector:@selector(bringInNextNowLine) withObject:nil afterDelay:0.01];
//            }
//            hasRefreshed = YES;
//        }
//        if (x > self.frame.size.width - INNER_PADDING*2) {
//            if (viewIndex + 2 < _views.count) {
//                [self refreshSecondHalf];
//                
//                [_currentNowLine setCenter:CGPointMake(self.frame.size.width + 40, _currentNowLine.center.y)];
//
//                _currentNowLine = _nextNowLine;
//            }
//            hasRefreshed = NO;
//        }
    }
}

- (void) setupMeasureViewsForTime:(float)time {
    float width = self.frame.size.width - INNER_PADDING*2;
    int index = (int)(time / width);
    viewIndex = index*2;
    float offset = time - (index * width);
    
    BOOL firstHalfShouldBeRefreshed = NO;
    if (viewIndex + 2 < _views.count && offset > width * 0.75) {
        firstHalfShouldBeRefreshed = YES;
    }
    
    UIView *firstHalfMeasureView;
    UIView *secondHalfMeasureView;
    UIView *nextFirstHalfMeasureView;
    
    BOOL isAlreadyInCorrectState = YES;
    
    if (viewIndex + 2 < _views.count) {
        firstHalfMeasureView = _views[viewIndex];
        secondHalfMeasureView = _views[viewIndex + 1];
        nextFirstHalfMeasureView = _views[viewIndex + 2];
        
        if (secondHalfMeasureView.alpha != 1) {
            isAlreadyInCorrectState = NO;
            trackingNowLine = NO;
        } else if (firstHalfShouldBeRefreshed && firstHalfMeasureView.alpha == 1) {
            isAlreadyInCorrectState = NO;
        } else if (!firstHalfShouldBeRefreshed && firstHalfMeasureView.alpha != 1) {
            isAlreadyInCorrectState = NO;
        }
    } else if (viewIndex + 1 < _views.count) {
        firstHalfMeasureView = _views[viewIndex];
        secondHalfMeasureView = _views[viewIndex + 1];
        if (secondHalfMeasureView.alpha != 1) {
            isAlreadyInCorrectState = NO;
            trackingNowLine = NO;
        } else if (firstHalfMeasureView.alpha != 1) {
            isAlreadyInCorrectState = NO;
        }
    } else if (viewIndex < _views.count) {
        firstHalfMeasureView = _views[viewIndex];
        if (firstHalfMeasureView.alpha != 1) {
            isAlreadyInCorrectState = NO;
        }
    }
    
    if (!isAlreadyInCorrectState) {
       // __block BOOL shouldBringInNextNowLine = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:_animationDuration];
        [_views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            if (view == secondHalfMeasureView) {
                [view setAlpha:1];
            } else if (view == firstHalfMeasureView) {
                if (firstHalfShouldBeRefreshed) {
                    [view setAlpha:0];
                } else {
                    [view setAlpha:1];
                }
            } else if (view == nextFirstHalfMeasureView && firstHalfShouldBeRefreshed) {
                if (view.alpha != 1) {
                    [view setAlpha:1];
                }
            } else {
                [view setAlpha:0];
            }
        }];
        [_lyricViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            if (idx == viewIndex+1) {
                [view setAlpha:1];
            } else if (idx == viewIndex) {
                if (firstHalfShouldBeRefreshed) {
                    [view setAlpha:0];
                } else {
                    [view setAlpha:1];
                }
            } else if (idx == viewIndex + 2 && firstHalfShouldBeRefreshed) {
                [view setAlpha:1];
            } else {
                [view setAlpha:0];
            }
        }];
        [UIView commitAnimations];
//        if (shouldBringInNextNowLine) {
//            [self bringInNextNowLine];
//        }
    }
}

//- (void)setWidthBase:(float)widthBase {
//    if (_widthBase != widthBase) {
//        _widthBase = widthBase;
//        [self displayNotes:_notes lyrics:_lyrics];
//    }
//}
- (void) bringInNextNowLine {
    NowLine *nextNowLine = viewIndex % 4 == 0 ? _nowLineOdd : _nowLineEven;
    [nextNowLine setCenter:CGPointMake(OUTER_PADDING + INNER_PADDING, nextNowLine.center.y)];
}

- (float)minimumTicksWidthForDivision:(int)division singleKeyPerHand:(BOOL)twoRow {
    float mult = _widthBase / division;
    if (twoRow) {
        float min = MIN_WIDTH_TWOROW;
        return min / mult;
    } else {
        float min = 15;
        return min / mult;
    }
}

- (void) refreshFirstHalf {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:_animationDuration];
    //viewIndex = [NZInputHandler sharedHandler].currentTime * _widthMultiplier / (self.frame.size.width - INNER_PADDING*2.0);
    if (viewIndex+2 < _views.count) {
        [_views[viewIndex+2] setAlpha:1];
        [_views[viewIndex] setAlpha:0];
        [_lyricViews [viewIndex+2] setAlpha:1];
        [_lyricViews [viewIndex] setAlpha:0];
        
    }
    
    [UIView commitAnimations];
}

- (void) refreshSecondHalf {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:_animationDuration];
    
    //viewIndex = [NZInputHandler sharedHandler].currentTime * _widthMultiplier / (self.frame.size.width - INNER_PADDING*2.0);
    
    if (viewIndex+1 < _views.count) {
        [_views[viewIndex+1] setAlpha:0];
        [_lyricViews[viewIndex+1] setAlpha:0];
    }
    viewIndex+= 2;
    if (viewIndex+1 < _views.count) {
        [_views[viewIndex+1] setAlpha:1];
        [_lyricViews[viewIndex+1] setAlpha:1];
    }
    
    [UIView commitAnimations];
    
    _nowLineOffset += self.frame.size.width - INNER_PADDING*2;
}

- (void) calculateWidthMultiplier {
//    int min = 1000000;
//    for (RGNote *n in _notes) {
//        if (n.duration < min && n.duration > 0) {
//            min = n.duration;
//        }
//    }
//    _widthMultiplier = 0.25;
//    if (min * _widthMultiplier < 20) {
//        _widthMultiplier = 20.0 / (float)min;
//    }
   // w * tpqn = 40
    _widthMultiplier = _widthBase / self.division;
    if ([[SongOptions CurrentItem].Title hasPrefix:@"Final Fantasy VI - Terra's Theme"]) {
        _widthMultiplier *= 0.7;
    }
}

- (void) setupLayout {
    
//    _rollers = [[RollersView alloc] init];
//    [self.superview addSubview:_rollers];

    [self.superview insertSubview:_nowLineEven aboveSubview:self];
    [self.superview insertSubview:_nowLineOdd aboveSubview:self];

     //   [self.superview addSubview:_lyricsBG];
    [self.superview addSubview:_lyricsView];
    [self.superview insertSubview:_shadeView aboveSubview:self];
    [self arrangeExternalElements];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _lyricsView.contentOffset = self.contentOffset;
    if (ignoreScrollingForRollers) return;
    [_rollers setIndex:fabs(self.contentOffset.x/2)];
}

double offset(int y) {
    if (y == 2) {
        return -1;
    }
    if (y == 4) {
        return -1;
    }
    if (y == 3) {
        return -1;
    }
    if (y == 5) {
        return -1;
    }
    if (y == 6) {
        return -2;
    }
    if (y == 7) {
        return -2;
    }
    if (y == 8) {
        return 0;
    }
    return 0;
}

- (CGRect) _rectForNote:(RGNote *)note {
    CGRect r;
    float height = 29;//(self.frame.size.height - VERTICAL_PADDING*2 - 8)/8.0;
    int col;
    static double halfM = -1;
    if (halfM == -1) {
        halfM = (self.frame.size.height - 40)/2.0;
    }
    
    r.origin.x = note.time * _widthMultiplier;
    
    if (note.note == 0) {
        r.origin.y = 6;
        r.size.height = 40;
        r.size.width = note.duration * _widthMultiplier;
    } else  {
        col = [Conversions columnForKey:note.qwerty withChord:note.chord];
        float y = col;
        r.origin.y = y * height + (y)*3 + offset(y);
        r.size.height = height;
        r.size.width = note.duration * _widthMultiplier;
    }

    if (_isTwoRow) {
        r.size.width = MAX(r.size.width, MIN_WIDTH_TWOROW);
    } else {
        r.size.width = MAX(r.size.width, 15);
    }
//    } else {
//        
//        // 60 is middle C
//        if (note.note < 60) {
//            r.origin.y = halfM - (halfM / 60.0 * note.note) + 20 + halfM;
//            
//        // most RH notes will be less than 100, so allot 75% of space for those
//        } else if (note.note < 100) {
//            r.origin.y = (halfM*.75) - ((halfM*.75) / 40.0 * (note.note - 60)) + 20 + (halfM*.25); //[self MAM_Y:aNote->top x:aNote->left lr:'l' playstate:self.PS];
//            
//        // squeeze notes 100 - 127 into the upper 25% of space
//        } else {
//            r.origin.y = (halfM*.25) - ((halfM*.25) / 27.0 * (note.note- 100)) + 20;
//        }
//        r.size.height = 5;
//        r.size.width = note.duration * _widthMultiplier;
//    }
    
//    r.origin.y+= 2;
//    r.size.height -= 3;
    
    if (_isTwoRow && note.note != 0) {
        if (col < 4) {
//            r.size.height *= 1.76;
//            r.origin.y = r.origin.y*.7;
            r.size.height = 92;
            r.origin.y = 32;
        } else {
            static float rightHandStart = 4 * 29 + (4)*3 - 1 + 17;
//            r.size.height *= 1.76;
//            r.origin.y = rightHandStart + (r.origin.y - rightHandStart)*.7;
            r.size.height = 92;
            r.origin.y = rightHandStart + 15;
        }
    }
    return r;
}

@end
