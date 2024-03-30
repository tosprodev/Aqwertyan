//
//  ChannelView.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//
#import "AudioPlayer.h"
#import "ChannelView.h"
#import "InsetShadowView.h"
#import <QuartzCore/QuartzCore.h>
#import "NoteView.h"
#import "ChannelsView.h"
#import "PushButton.h"

NSMutableArray *theProgramNames = nil;
NSMutableArray *thePercussionNames = nil;
@implementation ChannelView {
    BOOL isMuted;
    Channel *theChannel;
    UILabel *theLabel;
    //UIButton *theButton;
    PushButton *band, *solo, *mute;
    InsetShadowView *shadowView;
    UIView *notes[128];
    NSMutableArray *allViews;
    UIView *bgView;
}

- (void)setMelody:(BOOL)melody {
    _melody = melody;
    if (melody) {
        if (!bgView) {
            bgView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
            bgView.layer.cornerRadius = 4;
            bgView.backgroundColor = [UIColor yellowColor];
            [self addSubview:bgView];
            [self sendSubviewToBack:bgView];
            bgView.alpha = 0.33;
        }
        bgView.hidden = NO;
    } else {
        bgView.hidden = YES;
    }
}

- (void)noteOff:(int)key {
    if (!notes[key]) return;
    CGRect frame = notes[key].frame;
    frame.size.width = MIN(frame.size.width , self.scrollView.contentOffset.x + self.scrollView.frame.size.width - frame.origin.x);
    notes[key].frame = frame;
   // [notes[key] setHand:LEFT_HAND];
    notes[key] = nil;
}

#define max(a,b) a > b ? a : b

#define X 25.0
#define W 0.75
#define M 127.0/2.0
- (void)noteOn:(int)key {
    if (notes[key]) {
        [self noteOff:key];
    }
    UIView *n = [UIView new];
    if (self.active == CH_ACTIVE) {
        n.backgroundColor = [UIColor colorWithRed:202.0/255.0 green:41.0/255.0 blue:26.0/255.0 alpha:1];
    } else {
        n.backgroundColor = [UIColor colorWithRed:79.0/255.0 green:40.0/255.0 blue:41.0/255.0 alpha:1];
    }
    if (self.active == CH_MUTE) {
        n.alpha = 0.35;
    }
    
    //[n setState:SHADOW];
    [self.scrollView addSubview:n];
    [allViews addObject:n];
    float y;
    if (key >= M - X && key <= M + X) {
        y = (key - (M - X)) / (2*X) * (_scrollView.frame.size.height * W) + (_scrollView.frame.size.height * ((1.0 - W) / 2.0));
    } else if (key > M + X) {
        y = (key - (M + X)) / (float)(127 - M - X) * (_scrollView.frame.size.height  * ((1.0 - W) / 2.0)) + _scrollView.frame.size.height * ((1.0 - W) / 2.0 + W);
    } else {
        y = key / (float)(M - X) * (_scrollView.frame.size.height  * ((1.0 - W) / 2.0));
    }
    y = _scrollView.frame.size.height - y;
   // = max(0, (key - 30) * (self.scrollView.frame.size.height / 70.0));
    [n setFrame:CGRectMake(_scrollView.frame.size.width + _scrollView.contentOffset.x, y, 200, 2)];
    notes[key] = n;
}

- (void)clearNotes {
    [UIView transitionWithView:_scrollView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        for (UIView *view in self.scrollView.subviews) {
            [view removeFromSuperview];
        }
    } completion:nil];
    
    for (int i = 0; i < 128; i++) {
        notes[i] = nil;
    }
    [allViews removeAllObjects];
}

+ (NSString *)nameForProgram:(NSInteger)program channel:(NSInteger)channel {
    if (theProgramNames == nil) {
        [ChannelView loadProgramNames];
    }
    if (channel == 9) {
        return @"Percussion";
    } else {
        return [theProgramNames objectAtIndex:program];
    }
}

- (void) optionChanged:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) return;
    int result = -1;
    if (sender == solo) {

            result = CH_ACTIVE;
//        solo.selected = YES;
//        band.selected = mute.selected = NO;
       
    } else if (sender == mute) {
//        mute.selected = YES;
//        band.selected = solo.selected = NO;
        result = CH_MUTE;
    } else {
//        band.selected = YES;
//        mute.selected = solo.selected = NO;
        result = CH_ACCOMP;
    }
    self.active = result;
    [[ChannelsView sharedView] channelView:self chanedTo:result];
}

//- (void) switch:(id)sender {
//    int result;
//    if (theSegControl.selectedSegmentIndex == 0) {
//        [self setActive:CH_ACTIVE];
//        result=CH_ACTIVE;
//    } else if (theSegControl.selectedSegmentIndex == 1) {
//        [self setActive:CH_ACCOMP];
//        result=CH_ACCOMP;
//    } else {
//        [self setActive:CH_MUTE];
//        result=CH_MUTE;
//    }
//    [[ChannelsView sharedView] channelView:self chanedTo:result];
//}

+ (void) loadProgramNames {
    theProgramNames = [NSMutableArray new];
    thePercussionNames = [NSMutableArray new];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"program_names" ofType:@"txt"];
    NSString* contents =
    [NSString stringWithContentsOfFile:path
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* lines = [contents componentsSeparatedByCharactersInSet:
                      [NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        int i;
        for (i = 0; i < line.length; i++) {
            if ([line characterAtIndex:i] == ' ')
                break;
        }
        NSString *theName = [line substringFromIndex:i+1];
     //   NSLog(theName);
        [theProgramNames addObject:theName];
    }
    
    for (int i =0; i < 33; i++) {
        [thePercussionNames addObject:@"Percussion"];
    }
    path = [[NSBundle mainBundle] pathForResource:@"percussion_names" ofType:@"txt"];
    contents =
    [NSString stringWithContentsOfFile:path
                              encoding:NSUTF8StringEncoding error:nil];
    lines = [contents componentsSeparatedByCharactersInSet:
             [NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        int i;
        for (i = 0; i < line.length; i++) {
            if ([line characterAtIndex:i] == ' ')
                break;
        }
        NSString *theName = [line substringFromIndex:i+1];
      //  NSLog(theName);
        [thePercussionNames addObject:theName];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        allViews = [NSMutableArray new];
    }
    return self;
}

+ (UIImage *)upImage {
    static UIImage *theImage = nil;
    if (!theImage) {
        theImage = [[UIImage imageNamed:@"button_bg_clear"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    return theImage;
}

+ (UIImage *)downImage {
    static UIImage *theImage = nil;
    if (!theImage) {
        theImage = [[UIImage imageNamed:@"button_bg_pressed_clear"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    return theImage;
}

+ (UIColor *)scrollViewColor {
   // return [UIColor clearColor];
    static UIColor *c = nil;
    if (!c) {
        
        c = [UIColor colorWithPatternImage:[UIImage imageNamed:@"so-grid.png"]];
    }
return c;
}

- (id)init {
    self = [super init];
//    theButton = [UIButton new];
//    [theButton setBackgroundImage:[ChannelView upImage] forState:UIControlStateHighlighted];
//    [theButton setBackgroundImage:[ChannelView downImage] forState:UIControlStateNormal];
//    [theButton addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:theButton];
//    theSegControl = [[UISegmentedControl alloc] initWithItems:@[@"Solo", @"Accompany", @"Mute"]];
//    theSegControl.segmentedControlStyle = UISegmentedControlStyleBar;
//    [theSegControl setTitle:@"Solo" forSegmentAtIndex:0];
//    [theSegControl setTitle:@"Accompany" forSegmentAtIndex:1];
//    [theSegControl setTitle:@"Mute" forSegmentAtIndex:2];
    
    solo = [PushButton new];
    band = [PushButton new];
    mute = [PushButton new];
    
    solo.upImage = [UIImage imageNamed:@"so-solo-button.png"];
    solo.downImage = [UIImage imageNamed:@"so-solo-button-pressed.png"];
    
    mute.upImage = [UIImage imageNamed:@"so-mute-button.png"];
    mute.downImage = [UIImage imageNamed:@"so-mute-button-pressed.png"];
    
    band.upImage = [UIImage imageNamed:@"so-band-button.png"];
    band.downImage = [UIImage imageNamed:@"so-band-button-pressed.png"];
    
    solo.ignoreTouchesOnTransparentRegions = mute.ignoreTouchesOnTransparentRegions = band.ignoreTouchesOnTransparentRegions = NO;
    
    [self addSubview:band];
    [self addSubview:solo];
    [self addSubview:mute];
    
    [solo addTarget:self action:@selector(optionChanged:) forControlEvents:UIControlEventTouchDown];
    [band addTarget:self action:@selector(optionChanged:) forControlEvents:UIControlEventTouchDown];
    [mute addTarget:self action:@selector(optionChanged:) forControlEvents:UIControlEventTouchDown];
    theLabel = [UILabel new];
    theLabel.backgroundColor = [UIColor clearColor];
    theLabel.textAlignment = UITextAlignmentCenter;
    theLabel.font = [UIFont fontWithName:@"Futura-Medium" size:15];
    theLabel.textColor = [UIColor colorWithRed:44.0/255.0 green:33.0/255.0 blue:22.0/255.0 alpha:1];
    theLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    theLabel.adjustsFontSizeToFitWidth = YES;
    theLabel.shadowOffset = CGSizeMake(0,1);
   // theLabel.alpha = 0.85;
    theLabel.numberOfLines = 0;
    [self addSubview:theLabel];
    self.scrollView = [UIScrollView new];
    self.scrollView.backgroundColor = [ChannelView scrollViewColor];
   // self.scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scrollView];
    [theLabel setFrame:CGRectMake(0, 0, self.frame.size.width - 16, self.frame.size.height-16)];
    theLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    //shadowView = [InsetShadowView new];
    //[self addSubview:shadowView];
   // self.scrollView.layer.cornerRadius = 7;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    
    self.image = [UIImage imageNamed:@"so-list-background.png"];
    self.contentMode = UIViewContentModeCenter;
    self.userInteractionEnabled=YES;
    self.scrollView.userInteractionEnabled=NO;
    
    return self;
}

- (NSComparisonResult)compare:(ChannelView *)anotherView {
    return [self.channel compare:anotherView.channel];
}

//- (void)setMuted:(BOOL)muted {
//    self.channel.Active = !muted;
//    if (muted) {
//        [theButton setBackgroundImage:[ChannelView upImage] forState:UIControlStateNormal];
//    } else {
//        [theButton setBackgroundImage:[ChannelView downImage] forState:UIControlStateNormal];
//    }
//    self.channel.Active = !muted;
//    
//    [[AudioPlayer sharedPlayer] setMute:muted forChannel:self.channel.Number];
//}

//- (BOOL)muted {
//    return !self.channel.Active;
//}
- (int)active {
    return self.channel.Active;
}

- (void)setActive:(int)active {
    self.channel.Active = active;
    [[AudioPlayer sharedPlayer] setMute:(active == CH_MUTE) forChannel:self.channel.Number];
    if (active == CH_ACCOMP) {
       // theLabel.textColor = [UIColor whiteColor];
       // theSegControl.selectedSegmentIndex = 1;
        theLabel.textColor = [UIColor colorWithRed:44.0/255.0 green:33.0/255.0 blue:22.0/255.0 alpha:1];
    } else if (active == CH_ACTIVE) {
       // theLabel.textColor = [UIColor yellowColor];
       // theSegControl.selectedSegmentIndex = 0;
        theLabel.textColor = [UIColor colorWithRed:202.0/255.0 green:41.0/255.0 blue:26.0/255.0 alpha:1];
    } else {
       // theLabel.textColor = [UIColor grayColor];
        //theSegControl.selectedSegmentIndex = 2;
        theLabel.textColor = [UIColor colorWithRed:44.0/255.0 green:33.0/255.0 blue:22.0/255.0 alpha:0.45];
        
    }
    
    if (active == CH_ACTIVE) {
        UIColor *color = [UIColor colorWithRed:202.0/255.0 green:41.0/255.0 blue:26.0/255.0 alpha:1];
        for (UIView *view in allViews) {
            [view setBackgroundColor:color];
            view.alpha = 1;
        }
    } else if (active == CH_ACCOMP) {
        UIColor *color = [UIColor colorWithRed:79.0/255.0 green:40.0/255.0 blue:41.0/255.0 alpha:1];
        for (UIView *view in allViews) {
            [view setBackgroundColor:color];
            view.alpha = 1;
        }
    } else {
        UIColor *color = [UIColor colorWithRed:79.0/255.0 green:40.0/255.0 blue:41.0/255.0 alpha:1];
        for (UIView *view in allViews) {
            [view setBackgroundColor:color];
            view.alpha = 0.35;
        }
    }
    mute.selected = active == CH_MUTE;
    band.selected = active == CH_ACCOMP;
    solo.selected = active == CH_ACTIVE;
}
- (void)setChannel:(Channel *)channel {
    theChannel = channel;
    NSInteger theInstrument;
    if (theChannel.Instruments.count > 1) {
        theInstrument = [[theChannel.Instruments objectAtIndex:0] integerValue];
        theLabel.text = [NSString stringWithFormat:@"%@*", [ChannelView nameForProgram:theInstrument channel:channel.Number]];
    } else if (theChannel.Instruments.count > 0) {
        theInstrument = [[theChannel.Instruments objectAtIndex:0] integerValue];
        theLabel.text = [NSString stringWithFormat:@"%@", [ChannelView nameForProgram:theInstrument channel:channel.Number]];
    } else {
        if (channel.Number == 9) {
            theLabel.text = @"Percussion";
        } else {
            theLabel.text = [NSString stringWithFormat:@"Channel %d", channel.Number+1];
        }
    }
    self.active = channel.Active;
}

- (Channel *)channel {
    return theChannel;
}

//- (void) pressed:(id)sender {
//    self.muted = !self.muted;
//}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
 
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.scrollView setFrame:CGRectMake(10, 30, 192, 47)];
    [shadowView setFrame:CGRectMake(0, 25, self.frame.size.width, self.frame.size.height - 55)];
    [theLabel setFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    //[theSegControl setFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
    self.scrollView.contentSize = CGSizeMake(100000, self.scrollView.frame.size.height);
    CGRect frame = CGRectMake(0, 0, solo.upImage.size.width+2, solo.upImage.size.height+2);
    solo.frame = band.frame = mute.frame = frame;
    solo.center = CGPointMake(40,100);
    band.center = CGPointMake(106,solo.center.y);
    mute.center = CGPointMake(172, solo.center.y);
   // theLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
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
