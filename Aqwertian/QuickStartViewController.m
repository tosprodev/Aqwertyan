//
//  QuickStartViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/9/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "QuickStartViewController.h"
#import "PerformanceViewController.h"
#import "AudioPlayer.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "LibraryManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IntroViewController.h"
@interface QuickStartViewController ()

@property (nonatomic) IBOutlet UIButton *checkMarkButton, *pathButton;

- (IBAction)library:(id)sender;
- (IBAction)checkTapped:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)showVideo:(id)sender;

@end

@implementation QuickStartViewController {
    BOOL stopPathAnimation;
    UIView *helpView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

# pragma mark - path
- (BOOL)pathPressed:(int)screen {
    [_pathButton setImage:[UIImage imageNamed:@"path"] forState:UIControlStateNormal];
    stopPathAnimation = YES;
    _pathButton.layer.shadowOpacity = 0;
    [[AudioPlayer sharedPlayer] stopPlaying];
    [NZEvents logEvent:@"Quick start exited from navigation menu"];
    switch (screen) {
        case PERFORMANCE:
            [[PerformanceViewController sharedController] dismissQuickStart];
            break;
        case OPTIONS:
            [[PerformanceViewController sharedController] dismissQuickStart];
            [[PerformanceViewController sharedController] performSelector:@selector(showOptions) withObject:nil afterDelay:0.75];
            break;
        case ARRANGEMENT:
            [[PerformanceViewController sharedController] dismissQuickStart];
            [[PerformanceViewController sharedController] performSelector:@selector(showSongOptions) withObject:nil afterDelay:0.75];
            break;
        case STORE:
            [[PerformanceViewController sharedController] dismissQuickStart];
            [[PerformanceViewController sharedController] performSelector:@selector(showStore) withObject:nil afterDelay:0.75];
            break;
        case LIBRARY:
            [[PerformanceViewController sharedController] dismissQuickStart];
            [[PerformanceViewController sharedController] performSelector:@selector(showLibrary) withObject:nil afterDelay:0.75];
            break;
        case INSTRUMENTS:
            [[PerformanceViewController sharedController] dismissQuickStart];
            [[PerformanceViewController sharedController] performSelector:@selector(showInstruments) withObject:nil afterDelay:0.75];
            break;
        case COLLAB:
            return NO;
            break;
        case USER_GUIDE:
            [[PerformanceViewController sharedController] dismissQuickStart];
            [[PerformanceViewController sharedController] performSelector:@selector(showGuide) withObject:nil afterDelay:0.75];
            break;
            
        default:
            return nil;
            break;
    }
    return YES;
}

- (void)showVideo:(id)sender {
    [[PerformanceViewController sharedController] showIntro];
    
//    MPMoviePlayerViewController *player =
//    [[MPMoviePlayerViewController alloc] initWithContentURL: [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"UserGuide" ofType:@"m4v" ]]];
//    [player.moviePlayer prepareToPlay];
//    [self presentMoviePlayerViewControllerAnimated:player];
//    [player.moviePlayer play];
}

- (void)pathOpened {
    stopPathAnimation = YES;
   // stopPathAnimation = YES;
    _pathButton.layer.shadowOpacity = 0;
}

- (void)checkTapped:(id)sender {
    _checkMarkButton.selected = !_checkMarkButton.selected;
    if (_checkMarkButton.selected) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:DONT_SHOW_QUICK_START_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DONT_SHOW_QUICK_START_KEY];
    }
}

- (void) presentHelp {
    if (!helpView) {
        
        helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-quick-start.png"]];
        
        [helpView sizeToFit];
        [helpView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHelp)]];
        helpView.userInteractionEnabled = YES;
    }
    [self.view addSubview:helpView];
    helpView.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.01];
    [UIView setAnimationDuration:0.5];
    helpView.alpha = 1;
    [UIView commitAnimations];
 
}

- (void)showHelp:(id)sender {
   [NZEvents logEvent:@"Quick start help opened"];
    [self presentHelp];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void) hideHelp {
    [UIView transitionWithView:helpView duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^(void) {
        helpView.alpha = 0;
    }completion:^(BOOL finished ) {
        [helpView removeFromSuperview];
        helpView = nil;
    }];
}

- (void)library:(id)sender {
    NSArray *items = [LibraryManager getAllItems];
    for (LibraryItem *item in items) {
        if ([item.Title hasPrefix:@"Jingle"] && item.Type == LibraryItemTypeArrangement) {
            [SongOptions setCurrentItem:item isSameItem:NO];
        }
    }
    [self pathPressed:PERFORMANCE];
    [[PerformanceViewController sharedController] performSelector:@selector(loadIntroSong) withObject:nil afterDelay:1];
    [NZEvents logEvent:@"Quick start chose to play easy song"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(animatePath) withObject:nil afterDelay:1];
    [[AudioPlayer sharedPlayer] setMidiFile:[[NSBundle mainBundle] pathForResource:@"boogie" ofType:@"mid"]];
    [[AudioPlayer sharedPlayer] seek:480];
    [[AudioPlayer sharedPlayer] startPlaying];
     //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:DONT_SHOW_QUICK_START_KEY];
	// Do any additional setup after loading the view.
}

- (void) animatePath {
    _pathButton.layer.shadowColor = [UIColor colorWithRed:1 green:0.55 blue:0 alpha:1].CGColor;
    _pathButton.layer.shadowOffset = CGSizeZero;
    _pathButton.layer.shadowRadius = 20;
    _pathButton.layer.shadowOpacity = 1;

    
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    theAnimation.autoreverses = NO;
    theAnimation.duration = 0.75;
    theAnimation.fromValue = @(0);
    theAnimation.toValue = [NSNumber numberWithDouble:1];
    [_pathButton.layer addAnimation:theAnimation forKey:@"shadowOpacity"];
    return;

    if (stopPathAnimation) return;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    theAnimation.autoreverses = NO;
    theAnimation.duration = 0.75;
    theAnimation.fromValue = @(0.3);
    theAnimation.toValue = [NSNumber numberWithDouble:1];
    [_pathButton.layer addAnimation:theAnimation forKey:@"shadowOpacity"];
    _pathButton.layer.shadowOpacity = 1;
    [self performSelector:@selector(animateBack) withObject:nil afterDelay:1];
//    [UIView transitionWithView:_pathButton duration:0.55 options:UIViewAnimationOptionTransitionNone animations:^(void) {
//       // [_pathButton setImage:[UIImage imageNamed:@"path-pressed"] forState:UIControlStateNormal];
////        _pathButton.layer.shadowColor = [UIColor redColor].CGColor;
////        _pathButton.layer.shadowRadius = 10;
////        _pathButton.layer.shadowOffset = CGSizeZero;
////        _pathButton.layer.shadowOpacity = 1;
//
//    } completion:^(BOOL finished) {
//        [self performSelector:@selector(animateBack) withObject:nil afterDelay:0.4];
//            
//                    
//        
//    }];
}

- (void) animateBack {
    if (stopPathAnimation) return;
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    theAnimation.autoreverses = NO;
    theAnimation.duration = 0.75;
    theAnimation.fromValue = @(1);
    theAnimation.toValue = [NSNumber numberWithDouble:0.3];
    [_pathButton.layer addAnimation:theAnimation forKey:@"shadowOpacity"];
    _pathButton.layer.shadowOpacity = 0.3;
    [self performSelector:@selector(animatePath) withObject:nil afterDelay:1];
//    [UIView transitionWithView:_pathButton duration:0.35 options:UIViewAnimationOptionTransitionNone animations:^(void) {
//        //[_pathButton setImage:[UIImage imageNamed:@"path"] forState:UIControlStateNormal];
//        _pathButton.layer.shadowColor = [UIColor redColor].CGColor;
//        _pathButton.layer.shadowRadius = 10;
//        _pathButton.layer.shadowOffset = CGSizeZero;
//        _pathButton.layer.shadowOpacity = 0;
//    } completion:^(BOOL finished) {
//        [self performSelector:@selector(animatePath) withObject:nil afterDelay:0.5];
//    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
