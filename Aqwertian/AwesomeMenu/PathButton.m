//
//  PathButton.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/2/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "PathButton.h"
#import "NZEvents.h"


@implementation PathButton {
    UIView *menuView;
    UIView *bgView;
    float radius;
    NSMutableArray *buttons, *internalButtons;
    NSTimer *timer;
    BOOL animating;
}

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
    buttons = [NSMutableArray new];
    internalButtons = [NSMutableArray new];
    [self setTitle:nil forState:UIControlStateNormal];
    [self addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchDown];
    [self setBackgroundImage:[UIImage imageNamed:@"path.png"] forState:UIControlStateNormal];
    self.upImage = [UIImage imageNamed:@"path.png"];
    self.downImage = [UIImage imageNamed:@"path-pressed.png"];
}

/*
 define PERFORMANCE 3
 #define OPTIONS 6
 #define ARRANGEMENT 5
 #define STORE 4
 #define LIBRARY 2
 #define INSTRUMENTS 1
 #define COLLAB 500
 #define USER_GUIDE 0
 
 */
NSString *nameFromScreenIndex(int screenIndex) {
    switch (screenIndex) {
        case PERFORMANCE:
            return @"Performance";
            break;
        case OPTIONS:
            return @"Options";
            break;
        case STORE:
            return @"Store";
            break;
        case LIBRARY:
            return @"Library";
            break;
        case INSTRUMENTS:
            return @"Instruments";
            break;
        case USER_GUIDE:
            return @"User Guide";
            break;

            
        default:
            return @"Unknown";
            break;
    }
}

- (void) buttonTapped:(id)sender {
    int screen = [sender tag];
    UIView *view = buttons[screen];
    [UIView transitionWithView:view duration:0.35 options:UIViewAnimationOptionCurveLinear animations:^(void) {
        view.transform = CGAffineTransformMakeScale(2.5, 2.5);
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if ([self.delegate pathPressed:screen]) {
            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.selected = NO;
            });
            
        } else {
            self.selected = NO;
        }
    }];
    menuView.userInteractionEnabled=NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    for (int i = 0; i < 7; i++) {
        if (i != [sender tag]) {
            [buttons[i] setAlpha:0];
        }
    }
    //bgView.alpha = 0.4;
    [UIView commitAnimations];
   
}

- (void) setupMenuView {
    if (menuView) {
        [self.superview bringSubviewToFront:bgView];
        [self.superview bringSubviewToFront:menuView];
        [self.superview bringSubviewToFront:self];
        return;
    }
    menuView = [UIView new];
    radius = 200;
    menuView.frame = CGRectMake(0,0,radius*4, radius*4);
    menuView.center = self.center;
    menuView.alpha = 0;
   // menuView.backgroundColor = [UIColor blueColor];
    menuView.backgroundColor = [UIColor clearColor];
    
    bgView = [UIView new];
    bgView.frame = self.superview.bounds;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0;
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        
        [menuView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
        
    }
        [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    bgView.userInteractionEnabled = YES;
    [self.superview addSubview:bgView];
    
    for (int i = 0; i < 7; i++) {
        UIView *view = [UIView new];
  
        view.frame = CGRectMake(0,0,100, 75);
        view.userInteractionEnabled=YES;
        view.clipsToBounds=NO;
        UIButton *button = [UIButton new];
        [button setImage:[self imageForScreen:i] forState:UIControlStateNormal];
        [button setImage:[self downImageForScreen:i] forState:UIControlStateHighlighted];
        button.contentMode = UIViewContentModeCenter;
        button.frame = CGRectMake(0,0,50,50);
        button.tag = i;
        [button setCenter:[self centerForScreen:i radius:radius]];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        [internalButtons addObject:button];
        button.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/3);
        
        UILabel *label = [UILabel new];
        label.text = [self titleForScreen:i];
        label.font = [UIFont fontWithName:@"Futura-Medium" size:14];
        label.textColor = [UIColor colorWithRed:231.0/255.0 green:204.0/255.0 blue:124.0/255.0 alpha:1];
        label.backgroundColor = [UIColor clearColor];
        
        label.textAlignment = UITextAlignmentCenter;
        [label sizeToFit];
        label.center = CGPointMake(button.center.x, button.center.y + 34);
        
        [view addSubview:label];
        [menuView addSubview:view];
        view.center = CGPointMake(menuView.frame.size.width/2, menuView.frame.size.height/2);
        [buttons addObject:view];
        view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    }
    menuView.userInteractionEnabled =NO;
    
    [self.superview addSubview:menuView];
    [self.superview bringSubviewToFront:self];
    
}

- (void) tapped:(id)sender {
    self.selected = !self.selected;
    if (self.selected) {
        if ([self.delegate respondsToSelector:@selector(pathOpened)]) {
            [self.delegate pathOpened];
        }
        [NZEvents logEvent:@"Navigation menu opened"];
    } else {
        [NZEvents logEvent:@"Navigation menu closed"];
    }
    
}

- (void)setSelected:(BOOL)selected {
    if (animating) return;
    [super setSelected:selected];
    if (self.selected) {
        [self showMenuView];
    } else {
        [self hideMenuView];
    }
}

- (void) showMenuView {
    [self setupMenuView];
    animating = YES;
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideItemInSequence:) object:nil];
    menuView.userInteractionEnabled=YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    bgView.alpha = 0.8;
    [UIView commitAnimations];
    menuView.alpha = 1;
    //for (int i = 0; i < 8; i++)
    [self showItemInSequence:@(3)];
   // [self showItemInSequence:@(4)];
}

- (void) showItemInSequence:(NSNumber *)item {
    UIView *view = buttons[item.intValue];
    //view.userInteractionEnabled=YES;
   // [[internalButtons objectAtIndex:item.intValue] setUserInteractionEnabled:YES];
    [UIView transitionWithView:view duration:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        CGPoint center = [self centerForScreen:item.intValue radius:radius+15];
        view.center = center;
        view.alpha = 1;
        view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView transitionWithView:view duration:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
            CGPoint center = [self centerForScreen:item.intValue radius:radius];
            view.center = center;
            view.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            if (item.intValue == 6) {
                animating = NO;
            }
        }];

    }];
    if (item.intValue == 3) {
        [self performSelector:@selector(showItemInSequence:) withObject:@(item.intValue+1) afterDelay:0.1];
        [self performSelector:@selector(showItemInSequence:) withObject:@(item.intValue-1) afterDelay:0.1];
    } else if (item.intValue <= 2 && item.intValue > 0) {
        [self performSelector:@selector(showItemInSequence:) withObject:@(item.intValue-1) afterDelay:0.1];
    } else if (item.intValue < 6 && item.intValue >= 4) {
        [self performSelector:@selector(showItemInSequence:) withObject:@(item.intValue+1) afterDelay:0.1];
    }
}

- (void) hideItemInSequence:(NSNumber *)item {
    [self hideItem:item.intValue];
    
    if (item.intValue > 0) {
        [self performSelector:@selector(hideItemInSequence:) withObject:@(item.intValue-1) afterDelay:0.04];
    }
}

- (void) hideItem:(int)item {
    UIView *view = buttons[item];
    UIButton *button = internalButtons[item];
    [UIView transitionWithView:button duration:0.35 options:UIViewAnimationOptionCurveLinear animations:^(void) {
        button.transform = CGAffineTransformMakeScale(2.3, 2.3);
    } completion:nil];
    [UIView transitionWithView:view duration:0.35 options:UIViewAnimationOptionCurveLinear animations:^(void) {
        //view.center = [self centerForScreen:item.intValue radius:radius];
        
        view.alpha = 0;
    } completion:^(BOOL finished) {
        view.center = CGPointMake(menuView.frame.size.width/2, menuView.frame.size.height/2);
      //  view.alpha = 1;
        button.transform = CGAffineTransformMakeScale(1, 1);
        view.transform = CGAffineTransformMakeScale(.5, .5);
        if (item == 0) animating = NO;
    }];
}

- (void) hideMenuView {
    animating = YES;
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(showItemInSequence:) object:nil];
    menuView.userInteractionEnabled =NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    bgView.alpha = 0;
    [UIView commitAnimations];
    //for (int i = 0; i < 8; i++)
        [self hideItemInSequence:@(6)];
    //[self hideItem:@(4)];

    
}

- (NSString *) titleForScreen:(int)screen {
    switch (screen) {
        case PERFORMANCE:
            return @"PERFORMANCE";
            break;
        case OPTIONS:
            return @"OPTIONS";
            break;
        case ARRANGEMENT:
            return @"ARRANGEMENT";
            break;
        case STORE:
            return @"STORE";
            break;
        case LIBRARY:
            return @"LIBRARY";
            break;
        case INSTRUMENTS:
            return @"INSTRUMENTS";
            break;
        case COLLAB:
            return @"COLLABORATION";
            break;
        case USER_GUIDE:
            return @"USER GUIDE";
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *) imageForScreen:(int)screen {
    switch (screen) {
        case PERFORMANCE:
            return [UIImage imageNamed:@"path-performance.png"];
            break;
        case OPTIONS:
            return [UIImage imageNamed:@"path-options.png"];
            break;
        case ARRANGEMENT:
            return [UIImage imageNamed:@"path-arrangement.png"];
            break;
        case STORE:
            return [UIImage imageNamed:@"path-store.png"];
            break;
        case LIBRARY:
            return [UIImage imageNamed:@"path-library.png"];
            break;
        case INSTRUMENTS:
            return [UIImage imageNamed:@"path-instruments.png"];
            break;
        case COLLAB:
            return [UIImage imageNamed:@"path-collaboration.png"];
            break;
        case USER_GUIDE:
            return [UIImage imageNamed:@"path-guide.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *) downImageForScreen:(int)screen {
    switch (screen) {
        case PERFORMANCE:
            return [UIImage imageNamed:@"path-performance-pressed.png"];
            break;
        case OPTIONS:
            return [UIImage imageNamed:@"path-options-pressed.png"];
            break;
        case ARRANGEMENT:
            return [UIImage imageNamed:@"path-arrangement-pressed.png"];
            break;
        case STORE:
            return [UIImage imageNamed:@"path-store-pressed.png"];
            break;
        case LIBRARY:
            return [UIImage imageNamed:@"path-library-pressed.png"];
            break;
        case INSTRUMENTS:
            return [UIImage imageNamed:@"path-instruments-pressed.png"];
            break;
        case COLLAB:
            return [UIImage imageNamed:@"path-collaboration-pressed.png"];
            break;
        case USER_GUIDE:
            return [UIImage imageNamed:@"path-guide-pressed.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (CGPoint) centerForScreen:(int)screen radius:(float)aRadius {
    float x = 2*radius + aRadius * cos(M_PI * screen/6);
    float y = 2*radius - aRadius * sin(M_PI * screen/6);
    return CGPointMake((int)x, (int)y);
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
