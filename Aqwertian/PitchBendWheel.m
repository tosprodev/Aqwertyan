//
//  PitchBendWheel.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/10/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "PitchBendWheel.h"
#import "AudioPlayer.h"
#import "NZInputHandler.h"
#import "SongOptions.h"

#define MAX_BEND 16383

static PitchBendWheel *theWheel = nil;

@implementation PitchBendWheel {
    UIImageView *theImageView, *thumbView;
    UIScrollView *scrollView;
    float y, offset;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

+ (PitchBendWheel *)sharedWheel {
    return theWheel;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (!enabled && [SongOptions CurrentItem]) {
        [[AudioPlayer sharedPlayer] pitchBend:MAX_BEND/2 channel:[SongOptions activeChannel]];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void) setup {
    theWheel = self;
    _enabled = YES;
    theImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pitch-wheel-ridges.png"]];
    thumbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pitch-wheel-thumb.png"]];
    [theImageView setFrame:CGRectMake(0, 0, theImageView.image.size.width, theImageView.image.size.height)];
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pitch-wheel-ridges.png"]];
    [self addSubview:scrollView];
   // [scrollView addSubview:theImageView];
    [scrollView addSubview:thumbView];
    [thumbView sizeToFit];
    scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height*2);
    thumbView.center = CGPointMake(thumbView.frame.size.width/2, self.frame.size.height);
    _sensitivity = 1;
    scrollView.delegate = self;
    
    CGPoint center = self.center;
    [self setFrame:CGRectMake(0, 0, theImageView.image.size.width, self.frame.size.height)];
    self.center = center;
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.decelerationRate = MAXFLOAT;
    scrollView.userInteractionEnabled= NO;
  //  NSLog(@"%f", self.contentOffset.y);
    [self performSelector:@selector(setOffset) withObject:nil afterDelay:0.05];
 //   NSLog(@"%f---", self.bounds.size.width);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f", self.contentOffset.y);
//     NSLog(@"%f---", self.bounds.size.width);
//     NSLog(@"%f---", self.frame.size.width);
    float vol = scrollView.contentOffset.y * (2.0/(scrollView.contentSize.height - scrollView.frame.size.height));
    //float vol = scrollView.contentOffset.y / 80;
   // [[NZInputHandler sharedHandler] setVolumeMultiplier:vol];
    
}

- (void) setOffset {
    [scrollView setContentOffset:CGPointMake(0, self.frame.size.height/2)];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    y = [[touches anyObject] locationInView:self].y;
    offset = scrollView.contentOffset.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self snap];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event     {
    [self snap];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    float point = offset - ([touches.anyObject locationInView:self].y - y);
    if (point > self.frame.size.height-10) point = self.frame.size.height-10;
    if (point < 10) point = 10;
  
    scrollView.contentOffset = CGPointMake(0,point);
    float vol = (point-10)/(self.frame.size.height-20);
    //float vol = scrollView.contentOffset.y / 80;
    //[[NZInputHandler sharedHandler] setVolumeMultiplier:vol];
   // thumbView.transform = CGAffineTransformMakeScale(1, 1.0 - (fabs(vol - 1)/2.0));
    if (vol > 2.0) vol = 2.0;
    thumbView.transform = CGAffineTransformMakeScale(1, 1.0 - ((0.5-vol) * (0.5-vol))/0.5);
   //   NSLog(@"%f", vol);
    [self doPitchBend:vol];
  
}

- (void)doPitchBend:(float)vol {
    if (!_enabled) return;
    if (vol > 2.0) vol = 2.0;
    if (vol < 0) vol = 0;
    
    float bend = vol/2.0;
    bend -= 0.5;
    bend *= _sensitivity;
    bend += 0.5;
    bend *= MAX_BEND;
    
    if (bend > MAX_BEND) bend = MAX_BEND;
    if (bend < 0) bend = 0;
    if ([SongOptions CurrentItem]) {
        [[AudioPlayer sharedPlayer] pitchBend:bend channel:[SongOptions activeChannel]];
//        NSLog(@"%d", (int)bend);
//        if ((int)bend < 1) {
//            NSLog(@"low");
//        }
    }
}

- (void) snap {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [self setOffset];
    thumbView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView commitAnimations];
    if ([SongOptions CurrentItem]) {
        [self doPitchBend:1];
    }
    
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
