//
//  MidiSelectViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "FileSelectViewController.h"
#import "SongOptions.h"
#import "PerformanceViewController.h"
#import "LibraryManager.h"
#import "InsetShadowView.h"
#import "Util.h"
#import "LibCell.h"
#import "AudioPlayer.h"
#import <MessageUI/MessageUI.h>
#import "ScrollPaperTableView.h"
#import <Social/Social.h>
#import "Appirater.h"
#import <AVFoundation/AVFoundation.h>
#import "CreditsManager.h"
#import "KSCustomPopoverBackgroundView.h"

#define SONGS 0
#define ARRANGEMENTS 1
#define JUKEBOX 3
#define FAVORITES 2

#define SPECIAL_OFFER_TIME_KEY @"SpecialOfferTime"
#define SPECIAL_OFFER_COUNT_KEY @"SpecialOfferCount"
#define ALERT_SHOWN @"AlertShown"
#define SPECIAL_OFFER_PURCHASED @"SpecialOfferPurchased"

FileSelectViewController *theFileSelectController;

@interface FileSelectViewController () {
    IBOutlet UISegmentedControl *theSegControl;
    InsetShadowView *theShadowView;
    IBOutlet UISearchBar *theSearchBar;
  //  NSIndexPath *theSelectedPath;
    IBOutlet UIImageView *tab1, *tab2, *tab3, *tab4, *sortTab1, *sortTab2, *sortTab3;
    IBOutlet UIButton *shareButton, *likeButton, *rateButton;
    IBOutlet UILabel *jbLabel1, *jbLabel2;
    IBOutlet UISegmentedControl *sortSegControl;
    UIImageView *helpView;
    UIActionSheet *actionSheet;
    AVAudioPlayer *player;
    IBOutlet UIView *likeView, *rateView, *sortSearchView;
    CFTimeInterval rateTime;
    LibraryItem *lastItemPlayed, *nextJukeboxItem;
    int lastSort;
}

- (IBAction)done:(id)sender;
- (IBAction)switch:(id)sender;

- (IBAction)perform:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)rename:(id)sender;
- (IBAction)email:(id)sender;
- (IBAction)listen:(id)sender;
- (IBAction)showHelp:(id)sender;

- (IBAction)sort:(id)sender;

- (IBAction)like:(id)sender;
- (IBAction)rate:(id)sender;

@end

@implementation FileSelectViewController {
    NSMutableArray *libraryList, *favoritesList, *arrangementsList, *recordingsList, *jukeboxList;
    NSArray *theLibraryFiles, *theFavorites, *theArrangements, *theRecordings;
    NSMutableArray *theJukebox;
    IBOutlet ScrollPaperTableView *theTableView;
    BOOL isSelecting;
    NSArray *defaultList;
    LibraryItem *selectedItem;
}



////
# pragma mark - INIT
//

+ (FileSelectViewController *)sharedController {
    return theFileSelectController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    theFileSelectController = self;
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        theFileSelectController = self;
    }
    return self;
}


////
# pragma mark - VIEW CONTROLLER
//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    theTableView.allowsSelectionDuringEditing = YES;
    
   // sortSegControl.selectedSegmentIndex =1;
   
    theTableView.delegate = self;
    theTableView.dataSource = self;
    [theTableView reloadData];
   // [theTableView setContentOffset:CGPointMake(0, 44)];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leatherx"]];
    
    // set up tableview shadow
   // theTableView.layer.cornerRadius = 5;
    theShadowView = [InsetShadowView new];
    [self.view addSubview:theShadowView];
    
    theSearchBar.delegate = self;
    
    [theSegControl setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [theSegControl setDividerImage:[UIImage imageNamed:@"blank.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [sortSegControl setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [sortSegControl setDividerImage:[UIImage imageNamed:@"blank.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *social = [[UIImage imageNamed:@"st-other-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, likeButton.frame.size.width/2, 0, likeButton.frame.size.width/2)];
    UIImage *socialPressed = [[UIImage imageNamed:@"st-other-button-pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, likeButton.frame.size.width/2, 0, likeButton.frame.size.width/2)];
    
    [likeButton setImage:social forState:UIControlStateNormal];
    [likeButton setImage:socialPressed forState:UIControlStateHighlighted];
    [likeButton setImage:socialPressed forState:UIControlStateSelected];
    
    [rateButton setImage:social forState:UIControlStateNormal];
    [rateButton setImage:socialPressed forState:UIControlStateHighlighted];
     [rateButton setImage:socialPressed forState:UIControlStateSelected];
//    theTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"li-paper.png"]];
    theSearchBar.opaque = NO;
    [theSearchBar setBackgroundImage:[UIImage imageNamed:@"st-searchbar-blank.png"]];
    [theSearchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"st-searchbar-blank.png"] resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateNormal];
    [theSearchBar setImage:[UIImage imageNamed:@"li-search-icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [theSearchBar setImage:[UIImage imageNamed:@"li-delete-button.png"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];

    
    NSNumber *index = [[NSUserDefaults standardUserDefaults] objectForKey:LIB_TAB_KEY];
    if (index) {
        theSegControl.selectedSegmentIndex = index.intValue;
    } else {
        theSegControl.selectedSegmentIndex = 1;
    }
    [self switch:nil];
    [self setSortTabImages];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    [theTableView setPrefix:@"li"];
    [self loadAllFiles];
    [self loadSetlist];
    [theTableView reloadData];
   // [theTableView setContentOffset:CGPointMake(0, 44)];
    
    
    NSNumber *count = [[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryCount"];
    int value = [count intValue] + 1;
    value -= 6;
    if (value > 0 && (value-1)%7 == 0) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:LIKED_KEY]) {
            likeView.hidden = NO;
        }
        if (![[NSUserDefaults standardUserDefaults] objectForKey:RATED_KEY]) {
            rateView.hidden = NO;
        }
    }
    
 //   [theShadowView setFrame:theTableView.frame];
  //  [theTableView scrollToRowAtIndexPath:[theTableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveSetlist];
}

- (void) saveSetlist {
    NSMutableArray *setlist = @[].mutableCopy;
    for (LibraryItem *item in theJukebox) {
        [setlist addObject:item.Title];
    }
    [LibraryManager saveSetlist:setlist];
}

#define INTRO_SHOWN_KEY @"lib_intro_shown1"

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [NZEvents startTimedFlurryEvent:@"Library screen opened"];
    
    NSNumber *count = [[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryCount"];
    int value = [count intValue] + 1;
    count = @(value);
    [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"LibraryCount"];
    //[self showSocialButtons:0];
    if (value > 7 && value % 7 != 0) {
        NSTimeInterval time = [[NSUserDefaults.standardUserDefaults objectForKey:SPECIAL_OFFER_TIME_KEY] floatValue];
        int offerCount = [[NSUserDefaults.standardUserDefaults objectForKey:SPECIAL_OFFER_COUNT_KEY] floatValue];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:SPECIAL_OFFER_PURCHASED]) {
        if (offerCount == 0) {
            [self showSpecialOffer];
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:SPECIAL_OFFER_COUNT_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:@([NSDate.date timeIntervalSince1970]) forKey:SPECIAL_OFFER_TIME_KEY];
        } else {
            NSTimeInterval requiredTime = 60*60*24 * offerCount*2;
            int requiredValue = 6 + 7 * offerCount;
            
            if (value > requiredValue && [NSDate.date timeIntervalSince1970] - time > requiredTime) {
                [self showSpecialOffer];
                [[NSUserDefaults standardUserDefaults] setObject:@(offerCount+1) forKey:SPECIAL_OFFER_COUNT_KEY];
                [[NSUserDefaults standardUserDefaults] setObject:@([NSDate.date timeIntervalSince1970]) forKey:SPECIAL_OFFER_TIME_KEY];
            }
        }
        }
    }
    if (value > 5) {
        value = value - 6;
      //  value = 6;
        if (value%7 == 0) {
            BOOL shown = NO;
            if (value%14 == 0) {
                shown = [self showSocialButtons:0];
            } else {
                shown = [self showSocialButtons:1];
            }
             if (shown && value > 0) {
               static NSString *key = @"LikeHUDShown";
                if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key];
                    double delayInSeconds = 2.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self showMessageHUD:@"Get Free Translation Qwertys!" subText:@"Take a moment to rate or like us above." hide:4];
                        self.HUD.userInteractionEnabled = NO;
                        self.HUD.labelFont = [UIFont fontWithName:@"Futura-Medium" size:20];
                        self.HUD.detailsLabelFont = [UIFont fontWithName:@"Futura-Medium" size:15];
                        self.HUD.yOffset = -15;
                    });
                }
               
                
                
            }
        }
        
        if (value > 14 && ![[NSUserDefaults standardUserDefaults] objectForKey:ALERT_SHOWN]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ALERT_SHOWN];
            UIAlertView *alert;
            BOOL liked = [[NSUserDefaults standardUserDefaults] objectForKey:LIKED_KEY] != nil;
            BOOL rated = [[NSUserDefaults standardUserDefaults] objectForKey:RATED_KEY] != nil;
            if (!liked && !rated) {
                alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:@"Do you enjoy using Aqwertyan? If so, please help spread the word by rating us on the App Store or liking us on Facebook. You'll get free Translation Qwertys for doing so!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Rate", @"Like", nil];
            } else if (!liked) {
                alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:@"Do you enjoy using Aqwertyan? If so, please help spread the word by liking us on Facebook. You'll get a free Qwerty for doing so!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Like", @"I don't use Facebook", nil];
            } else {
                alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:@"Do you enjoy using Aqwertyan? If so, please help spread the word by rating us on the App Store. You'll get a free Qwerty for doing so!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Rate", nil];
            }
            alert.tag = 909;
            [alert show];
            
        } 
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:INTRO_SHOWN_KEY]) {
        [self performSegueWithIdentifier:@"SelectSong" sender:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:INTRO_SHOWN_KEY];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectSong"]) {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        UIPopoverController *pc = popoverSegue.popoverController;
        pc.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
    }
}

- (void) showSpecialOffer {
        UIAlertView *alert = [UIAlertView.alloc initWithTitle:@"Special Offer!" message:@"Would you like to buy 12 Translation Qwertys for only $0.99? That's double what you'd normally get for that price!" delegate:self cancelButtonTitle:@"Maybe Later" otherButtonTitles:@"Yes!", @"What's this?", nil];
        alert.tag = 56;
        [alert show];

}

- (void) buySpecialOffer {
    [self showLoadingHUD:@"Processing Purchase.." subText:nil];
    [[CreditsManager sharedManager] buyCredits:12 withCallback:^(BOOL success) {
        [self hideHUD:0];
        if (success) {
            [self showAlertWithTitle:@"Success!" message:@"Your credits have been added."];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SPECIAL_OFFER_PURCHASED];
        }
    }];
}

- (BOOL) showSocialButtons:(int)soundType {
    BOOL shown = NO;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:LIKED_KEY]) {
        [self showLikeButton];
        shown=YES;
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:RATED_KEY]) {
        [self showRateButton];
        shown=YES;
    }
    if (shown && soundType > -1) {
        NSString *soundFilePath;
        if (soundType == 0) {
         soundFilePath =
        [[NSBundle mainBundle] pathForResource: @"Swoosh"
                                        ofType: @"mp3"];
        } else {
            soundFilePath = [[NSBundle mainBundle] pathForResource: @"Whoosh 6"
                                            ofType: @"mp3"];
        }
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        player =
        [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                               error: nil];

        Float32 volume;
        UInt32 dataSize = sizeof(Float32);
        
        AudioSessionGetProperty (
                                 kAudioSessionProperty_CurrentHardwareOutputVolume,
                                 &dataSize,
                                 &volume
                                 );
        if (volume >= 0.9) {
            volume = 0.25;
        } else {
            volume = 0.25/volume;
        }
        if (volume > 1) volume = 1;

        player.volume = volume;
        [player play];
        
        
    }
    return shown;
}

- (void) showLikeButton {
    CGFloat y = likeView.center.y;
    likeView.center = CGPointMake(likeView.center.x, likeView.center.y - 200);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    likeView.center = CGPointMake(likeView.center.x, y);
    likeView.hidden = NO;
    [UIView commitAnimations];
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIButton *button;
        for (UIView *subview in likeView.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                button = (UIButton *)subview;
                break;
            }
            
        }
        button.layer.shadowColor = [UIColor colorWithRed:1 green:0.55 blue:0 alpha:1].CGColor;
        button.layer.shadowOffset = CGSizeZero;
        button.layer.shadowRadius = 20;
        button.layer.shadowOpacity = 1;
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        theAnimation.autoreverses = NO;
        theAnimation.duration = 0.75;
        theAnimation.fromValue = @(0);
        theAnimation.toValue = [NSNumber numberWithDouble:1];
        [button.layer addAnimation:theAnimation forKey:@"shadowOpacity"];
        button.layer.shadowOpacity = 1;
    });
}

- (void)hideLikeButton {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    likeView.alpha = 0;
    [UIView commitAnimations];
}

- (void) hideRateButton {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    rateView.alpha = 0;
    [UIView commitAnimations];
}

- (void) showRateButton {
    CGFloat y = rateView.center.y;
    rateView.center = CGPointMake(rateView.center.x, rateView.center.y - 200);
    rateView.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    rateView.center = CGPointMake(rateView.center.x, y);
    [UIView commitAnimations];
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIButton *button;
        for (UIView *subview in rateView.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                button = (UIButton *)subview;
                break;
            }
            
        }
        button.layer.shadowColor = [UIColor colorWithRed:1 green:0.55 blue:0 alpha:1].CGColor;
        button.layer.shadowOffset = CGSizeZero;
        button.layer.shadowRadius = 20;
        button.layer.shadowOpacity = 1;
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        theAnimation.autoreverses = NO;
        theAnimation.duration = 0.75;
        theAnimation.fromValue = @(0);
        theAnimation.toValue = [NSNumber numberWithDouble:1];
        [button.layer addAnimation:theAnimation forKey:@"shadowOpacity"];
        button.layer.shadowOpacity = 1;
    });
}

- (void)like:(id)sender {
    [self showLikeView];
  
    [NZEvents logEvent:@"Like button tapped"];
}

- (void) showLikeView {
      [self performSegueWithIdentifier:@"Like" sender:nil];
}

- (void)rate:(id)sender {
   // [[NSUserDefaults standardUserDefaults] setObject:@"Rated" forKey:@"Rated1"];
   // [self hideRateButton];
     [NZEvents logEvent:@"Rate button tapped"];
    [self showAppStoreRateView];
    
}

- (void) showAppStoreRateView {
    [Appirater setDelegate:self];
    [Appirater rateApp];
   
    rateTime = CACurrentMediaTime();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NZEvents stopTimedFlurryEvent:@"Library screen opened"];
}

//- (void)appiraterDidOptToRemindLater:(Appirater *)appirater {
//    [NZEvents logEvent:@"Rating prompt shown" args:@{@"Result" : @"Remind me later"}];
//}
//
//- (void)appiraterDidOptToRate:(Appirater *)appirater {
//    [NZEvents logEvent:@"Rating prompt shown" args:@{@"Result" : @"Rate"}];
//}
//
//- (void)appiraterDidDeclineToRate:(Appirater *)appirater {
//     [NZEvents logEvent:@"Rating prompt shown" args:@{@"Result" : @"No thanks"}];
//}


- (void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated {
    float diff = CACurrentMediaTime() - rateTime;
    if (diff > 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Were you able to rate us or write a review?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes, I did", @"Not now", nil];
        alert.tag = 1056;
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}


- (void)perform:(id)sender {
    [self selectCurrentItem];
}

- (void)delete:(id)sender {
    NSIndexPath *path = theTableView.indexPathForSelectedRow;
    if (!path) return;
    LibraryItem *item = [self currentItems][path.row];
        [[[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", item.Title] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show ];
}

- (void)email:(id)sender {
    NSIndexPath *theSelectedPath = [theTableView indexPathForSelectedRow];
    if (!theSelectedPath) {
        [self showMessageHUD:@"Select a song to share" subText:nil hide:2];
        self.HUD.yOffset = -50;
        self.HUD.userInteractionEnabled = NO;
        return;
    }
    
    if (NSClassFromString(@"SLComposeViewController")) {
        [self showActionSheet];
    } else {
        [self emailCurrentItem];
    }
}

- (void)rename:(id)sender {
    NSIndexPath *path = theTableView.indexPathForSelectedRow;
    if (!path) return;
    LibraryItem *item = [self currentItems][path.row];
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Rename" message:[NSString stringWithFormat:@"Enter a new name for %@", item.Title] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    theAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
   
    [theAlert show];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1056) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] hasPrefix:@"Yes"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"Rated" forKey:RATED_KEY];
            [self hideRateButton];
            [[CreditsManager sharedManager] addCredits:1];
            [self showAlertWithTitle:@"Thanks!" message:[NSString stringWithFormat:@"You now have %d Qwerty%@!",
                                                         [CreditsManager sharedManager].numberOfCredits,
                                                         ([CreditsManager sharedManager].numberOfCredits == 1 ? @"" : @"s")]];
            
        } else {
            
        }
        return;
    } else if (alertView.tag == 909) {
        NSString *text = [alertView buttonTitleAtIndex:buttonIndex];
        if ([text hasPrefix:@"I don"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:LIKED_KEY];
            [self hideLikeButton];
            [NZEvents logEvent:@"Rate/Like prompt shown" args:@{@"Result" : @"I don't use facebook"}];
        } else if ([text hasPrefix:@"Rate"]) {
            [self showAppStoreRateView];
            [NZEvents logEvent:@"Rate/Like prompt shown" args:@{@"Result" : @"Rate"}];
        } else if ([text hasPrefix:@"Like"]) {
            [self showLikeView];
            [NZEvents logEvent:@"Rate/Like prompt shown" args:@{@"Result" : @"Like"}];
        } else {
            [NZEvents logEvent:@"Rate/Like prompt shown" args:@{@"Result" : @"Later"}];
        }
        return;
    } else if (alertView.tag == 56) {
         NSString *text = [alertView buttonTitleAtIndex:buttonIndex];
        if ([text hasPrefix:@"Yes"]) {
            [self buySpecialOffer];
            [NZEvents logEvent:@"Special offer shown" args:@{@"Result" : @"Buy"}];
        } else if ([text hasPrefix:@"Maybe"]) {
            [NZEvents logEvent:@"Special offer shown" args:@{@"Result" : @"Maybe Later"}];
        } else if ([text hasPrefix:@"What"]) {
            [self explainSpecialOffer];
            [NZEvents logEvent:@"Special offer explain button tapped"];
        }
    } else if (alertView.tag == 22) {
        [self showSpecialOffer];
    } else {
        NSIndexPath *path = theTableView.indexPathForSelectedRow;
        if (!path) return;
        LibraryItem *item = [self currentItems][path.row];
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save"]) {
            [LibraryManager setNewTitle:[alertView textFieldAtIndex:0].text forItem:item];
            [theTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            [theTableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
            [self deleteCurrentItem];
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete All"]) {
            [self _deleteItem];
        }
    }
    
}

- (void) explainSpecialOffer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Translation Qwerty" message:@"A Translation Qwerty is the unit of currency used by Aqwertyan. One Qwerty allows you to translate any MIDI or KAR song, and perform it in the app. You can find songs online or by searching in the store." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alert.tag = 22;
    [alert show];
}

- (NSString *)songToPlay {
    if (nextJukeboxItem) {
       lastItemPlayed = selectedItem = nextJukeboxItem;
        NSString *song = [[Util uploadedSongsDirectory] stringByAppendingPathComponent:nextJukeboxItem.Arrangement.MidiFile];
         nextJukeboxItem = nil;
        
        return song;
    } else {
        NSIndexPath *path = theTableView.indexPathForSelectedRow;
        if (!path) return nil;
        LibraryItem *item = [self currentItems][path.row];
        lastItemPlayed = item;
        return [[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile];
    }
}

- (void)finish {
    [super finish];
    
    nextJukeboxItem = nil;
    
    if ([theJukebox containsObject:lastItemPlayed]) {
        int index = [theJukebox indexOfObject:lastItemPlayed];
        if (index < theJukebox.count-1) {
            index++;
            nextJukeboxItem = theJukebox[index];
            selectedItem = nextJukeboxItem;
            if (self.currentItems == theJukebox) {
                [theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewRowAnimationMiddle];
            }
            [self playTapped:nil];
        }
    }
}

- (void) showActionSheet {
    

        actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                  delegate: self
                                         cancelButtonTitle: nil
                                    destructiveButtonTitle: nil
                                         otherButtonTitles: @"Send via Email",@"Twitter", @"Facebook", nil];
    
    
    
    
    [actionSheet showFromRect: shareButton.frame inView:shareButton.superview animated: YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == -1) return;
    if (buttonIndex == 0) { // email
        [self emailCurrentItem];
    } else {
        NSIndexPath *theSelectedPath = [theTableView indexPathForSelectedRow];
        if (!theSelectedPath) return;
        LibraryItem *item = [[self currentItems] objectAtIndex:theSelectedPath.row];
        
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:buttonIndex == 1 ? SLServiceTypeTwitter : SLServiceTypeFacebook];
        // Configure Compose View Controller
        NSString *title = item.Title; //componentsSeparatedByString:@" ("][0];
    
        [vc setInitialText:[NSString stringWithFormat:@"I'm playing %@ on Aqwertyan for iPad!", title]];
        [vc addURL:[NSURL URLWithString:@"http://www.aqwertyan.com"]];

        // Present Compose View Controller
        [self presentViewController:vc animated:YES completion:nil];
    }
}

# pragma mark - Path

- (BOOL)pathPressed:(int)screen {
    switch (screen) {
        case PERFORMANCE:
            [[PerformanceViewController sharedController] dismissLibraryController:NO newFile:NO];
            break;
        case OPTIONS:
            [[PerformanceViewController sharedController] dismissLibraryController:NO newFile:NO];
            [[PerformanceViewController sharedController] performSelector:@selector(showOptions) withObject:nil afterDelay:0.75];
            break;
        case ARRANGEMENT:
            [[PerformanceViewController sharedController] dismissLibraryController:NO newFile:NO];
            [[PerformanceViewController sharedController] performSelector:@selector(showSongOptions) withObject:nil afterDelay:0.75];
            break;
        case STORE:
            [[PerformanceViewController sharedController] dismissLibraryController:NO newFile:NO];
            [[PerformanceViewController sharedController] performSelector:@selector(showStore) withObject:nil afterDelay:0.75];
            break;
        case LIBRARY:
            return NO;
            break;
        case INSTRUMENTS:
            [[PerformanceViewController sharedController] dismissLibraryController:NO newFile:NO];
            [[PerformanceViewController sharedController] performSelector:@selector(showInstruments) withObject:nil afterDelay:0.75];
            break;
        case COLLAB:
            return NO;
            break;
        case USER_GUIDE:
            [[PerformanceViewController sharedController] dismissLibraryController:NO newFile:NO];
            [[PerformanceViewController sharedController] performSelector:@selector(showGuide) withObject:nil afterDelay:0.75];
            break;
            
        default:
            return nil;
            break;
    }
    return YES;
}

////
# pragma mark - FINDING FILES
//

//- (void)loadFilesFromResources {
//    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
//    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mid' or self ENDSWITH '.mus'"];
//    defaultList = [[dirContents filteredArrayUsingPredicate:fltr] sortedArrayUsingSelector:@selector(compare:)];
//    theDefaultFiles = [NSArray arrayWithArray:defaultList];
//}

- (void) loadSetlist {
    NSArray *setlist = [LibraryManager setlist];
    if (setlist) {
        NSMutableArray *newJukebox = @[].mutableCopy;
        for (NSString *title in setlist) {
            for (int i = 0 ; i < theJukebox.count; i++) {
                LibraryItem *item = theJukebox[i];
                if ([item.Title isEqualToString:title]) {
                    [newJukebox addObject:item];
                    [theJukebox removeObjectAtIndex:i];
                    continue;
                }
            }
        }
        [newJukebox addObjectsFromArray:theJukebox];
        theJukebox = newJukebox;
    }
}

- (void) loadAllFiles {
    NSArray *items = [LibraryManager getAllItems].reverseObjectEnumerator.allObjects;
    [self loadLibraryFiles:items];
    [self loadFavorites:items];
    [self loadArrangements:items];
    [self loadJukebox:items];
}

- (void) loadLibraryFiles:(NSArray *)list {
    NSArray *items = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Type == %d", LibraryItemTypeFile]];
    libraryList = [NSMutableArray arrayWithArray:items];
    theLibraryFiles = [NSArray arrayWithArray:libraryList];
}

- (void) loadLibraryFiles {
    [self loadLibraryFiles:[LibraryManager getAllItems].reverseObjectEnumerator.allObjects];
}

- (void) loadArrangements:(NSArray *)list {
    NSArray *items = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Type == %d", LibraryItemTypeArrangement]];
    arrangementsList = [NSMutableArray arrayWithArray:items];
    theArrangements = [NSArray arrayWithArray:arrangementsList];
}

- (void) loadArrangements {
    [self loadArrangements:[LibraryManager getAllItems].reverseObjectEnumerator.allObjects];
}

- (void) loadFavorites:(NSArray *)list {
    NSArray *items = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Favorite == %d", YES]];
    favoritesList = [NSMutableArray arrayWithArray:items];
    theFavorites = [NSArray arrayWithArray:favoritesList];
}

- (void) loadFavorites {
    [self loadFavorites:[LibraryManager getAllItems].reverseObjectEnumerator.allObjects];
}

//- (void) loadRecordings {
//    NSArray *items = [[LibraryManager getAllItems] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Type == %d", LibraryItemTypeRecording]];
//    items = [[items reverseObjectEnumerator] allObjects];
//    recordingsList = [NSMutableArray arrayWithArray:items];
//    theRecordings = [NSArray arrayWithArray:recordingsList];
//}

- (void) loadJukebox:(NSArray *)list {
    NSArray *items = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Jukebox == %d && self.Type == %d", YES, LibraryItemTypeArrangement]];
    jukeboxList = items.mutableCopy;
    theJukebox = jukeboxList.mutableCopy;
}

- (void) loadJukebox {
    [self loadJukebox:[LibraryManager getAllItems].reverseObjectEnumerator.allObjects];
}


////
# pragma mark - SEGUES
//

- (void)done:(id)sender {
    [[PerformanceViewController sharedController] dismissLibraryController:NO newFile:NO];
   // [self performSegueWithIdentifier:@"Performance" sender:nil];
}

////
# pragma mark - SEGMENTED CONTROL
//

- (void)switch:(id)sender {
    if (sortSegControl.selectedSegmentIndex == 0) {
        theFavorites = [NSArray arrayWithArray:favoritesList];
        theLibraryFiles = [NSArray arrayWithArray:libraryList];
        theArrangements = [NSArray arrayWithArray:arrangementsList];
        lastSort = 0;
        // theRecordings = [NSArray arrayWithArray:recordingsList];
       // theJukebox = [NSMutableArray arrayWithArray:jukeboxList];
    } else {
        if (lastSort == 0) {
            theFavorites = [favoritesList sortedArrayUsingSelector:@selector(compareName:)];
            theLibraryFiles = [libraryList sortedArrayUsingSelector:@selector(compareName:)];
            theArrangements = [arrangementsList sortedArrayUsingSelector:@selector(compareName:)];
            lastSort = 1;
        } else {
            theFavorites = [favoritesList sortedArrayUsingSelector:@selector(compareNameReverse:)];
            theLibraryFiles = [libraryList sortedArrayUsingSelector:@selector(compareNameReverse:)];
            theArrangements = [arrangementsList sortedArrayUsingSelector:@selector(compareNameReverse:)];
            lastSort = 0;
        }
       // theJukebox = [jukeboxList sortedArrayUsingSelector:@selector(compareName:)].mutableCopy;
    }
    
    theTableView.editing = [self currentItems] == theJukebox;
    
    if (theSearchBar.text && theSearchBar.text.length > 0) {
        [self searchBar:theSearchBar textDidChange:theSearchBar.text];
    } else {
        [theTableView reloadData];
        if ([[self currentItems] containsObject:selectedItem]) {
            [theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[self.currentItems indexOfObject:selectedItem] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
        // [theTableView setContentOffset:CGPointMake(0, 44)];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(theSegControl.selectedSegmentIndex) forKey:LIB_TAB_KEY];
    [self setTabImages];
    
    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.2];
    if ([self currentItems] == theJukebox) {
        sortSearchView.alpha = 0;
        jbLabel1.alpha = jbLabel2.alpha = 1;
//        if (self.playButton.selected && [theJukebox containsObject:lastItemPlayed]) {
//            int index = [theJukebox indexOfObject:lastItemPlayed];
//            [theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
//        }
    } else {
        sortSearchView.alpha = 1;
        jbLabel1.alpha = jbLabel2.alpha = 0;
    }
  //  [UIView commitAnimations];
}

- (void)sort:(id)sender {
    if (sortSegControl.selectedSegmentIndex == 0) {
    
        if (theSearchBar.text.length) {
            [self setCurrentFiles:[[self currentList] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Title CONTAINS %@", theSearchBar.text]]];
        } else {
            [self setCurrentFiles:[NSArray arrayWithArray:[self currentList]]];
        }
        lastSort = 0;
    } else if (sortSegControl.selectedSegmentIndex == 1) {
        if (lastSort == 0) {
            [self setCurrentFiles:[[self currentItems] sortedArrayUsingSelector:@selector(compareName:)]];
            lastSort = 1;
        } else {
            [self setCurrentFiles:[[self currentItems] sortedArrayUsingSelector:@selector(compareNameReverse:)]];
            lastSort = 0;
        }
    } else {
         [self setCurrentFiles:[[self currentItems] sortedArrayUsingSelector:@selector(compareLastTimePlayed:)]];
        lastSort = 0;
    }
    [self setSortTabImages];
    [theTableView reloadData];
}

- (void) setSortTabImages {
    sortTab1.image = sortSegControl.selectedSegmentIndex == 0 ? [UIImage imageNamed:@"li-sort-left-pressed"] :  [UIImage imageNamed:@"li-sort-left"];
    sortTab2.image = sortSegControl.selectedSegmentIndex == 1 ? [UIImage imageNamed:@"li-sort-center-pressed"] : [UIImage imageNamed:@"li-sort-center"];
    sortTab3.image = sortSegControl.selectedSegmentIndex == 2 ? [UIImage imageNamed:@"li-sort-right-pressed"] : [UIImage imageNamed:@"li-sort-right"];
}

- (void) setTabImages {
    tab1.image = [UIImage imageNamed:theSegControl.selectedSegmentIndex == 0 ? @"li-tab-1.png" : @"li-tab-1-pressed.png"];
    tab2.image = [UIImage imageNamed:theSegControl.selectedSegmentIndex == 1 ? @"li-tab-2.png" : @"li-tab-2-pressed.png"];
    tab3.image = [UIImage imageNamed:theSegControl.selectedSegmentIndex == 2 ? @"li-tab-3.png" : @"li-tab-3-pressed.png"];
    tab4.image = [UIImage imageNamed:theSegControl.selectedSegmentIndex == 3 ? @"li-tab-3.png" : @"li-tab-3-pressed.png"];
}

- (NSArray *)currentItems {
    if (theSegControl.selectedSegmentIndex == SONGS) {
        return theLibraryFiles;
    } else if (theSegControl.selectedSegmentIndex == ARRANGEMENTS) {
        return theArrangements;
    } else if (theSegControl.selectedSegmentIndex == JUKEBOX) {
        return theJukebox;
    } else {
        return theFavorites;
    }
}

- (void) setCurrentFiles:(NSArray *)anArray {
    if (theSegControl.selectedSegmentIndex == SONGS) {
        theLibraryFiles = anArray;
    } else if (theSegControl.selectedSegmentIndex == ARRANGEMENTS) {
        theArrangements = anArray;
    } else if (theSegControl.selectedSegmentIndex == JUKEBOX) {
        theJukebox = anArray.mutableCopy;
    } else {
        theFavorites = anArray;
    }
}

- (NSArray *)currentList {
    if (theSegControl.selectedSegmentIndex == SONGS) {
        return libraryList;
    } else if (theSegControl.selectedSegmentIndex == ARRANGEMENTS) {
        return arrangementsList;
    } else if (theSegControl.selectedSegmentIndex == JUKEBOX) {
        return jukeboxList;
    } else {
        return favoritesList;
    }
}

////
# pragma mark - FAVORITES
//

- (void)addFavorite:(LibraryItem *)favorite {
   // if ([self currentItems] == theArrangements) {
        favorite.Favorite = YES;
        [LibraryManager setItemAsFavorite:favorite];
        [self loadFavorites];
   // }
}

- (void)removeFavorite:(LibraryItem *)favorite {
    favorite.Favorite = NO;
    [LibraryManager removeItemFromFavorites:favorite];
    
    if ([self currentItems] == theFavorites) {
        int index = [theFavorites indexOfObject:favorite];
        [self loadFavorites];
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [theTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self loadFavorites];
    }
}

- (void)addJukebox:(LibraryItem *)item {
    item.Jukebox = YES;
    [LibraryManager setItemAsJukebox:item];
    [jukeboxList addObject:item];
    [theJukebox addObject:item];
}

- (void)removeJukebox:(LibraryItem *)item {
    item.Jukebox = NO;
    [LibraryManager removeItemFromJukebox:item];
    
    if ([self currentItems] == theJukebox) {
        int index = [theJukebox indexOfObject:item];
        [theJukebox removeObjectAtIndex:index];
        [jukeboxList removeObject:item];
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [theTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [theJukebox removeObject:item];
        [jukeboxList removeObject:item];
    }
}



////
# pragma mark - SEARCH
//

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //searchText = searchText.lowercaseString;
    if (searchBar.text.length > 0) {
        if (sortSegControl.selectedSegmentIndex == 0) {
           [self setCurrentFiles:[[self currentList] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Title CONTAINS[cd] %@", searchText]]]; 
        } else {
            [self setCurrentFiles:[[[self currentList] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.Title CONTAINS[cd] %@", searchText]] sortedArrayUsingSelector:@selector(compareName:)]];
        }
        
    } else {
        if (sortSegControl.selectedSegmentIndex == 0) {
            [self setCurrentFiles:[NSArray arrayWithArray:[self currentList]]];
        } else {
            [self setCurrentFiles:[[self currentList] sortedArrayUsingSelector:@selector(compareName:)]];
        }
        
    }
    [theTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchBar:searchBar textDidChange:searchBar.text];
}


////
# pragma mark - TABLE VIEW
//

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [theTableView didScroll];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self currentItems].count;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LibCell *theCell = [tableView dequeueReusableCellWithIdentifier:@"Standard"];
    LibraryItem *item = [[self currentItems] objectAtIndex:indexPath.row];
    theCell.titleLabel.text = [item Title];
    theCell.item = item;
    theCell.dateLabel.text = item.Date;
    
//    if (indexPath.row == [self currentItems].count - 1) {
//        theCell.Position = NZTileCellPositionLast;
//        if (indexPath.row == 0) {
//            theCell.Position = NZTileCellPositionBoth;
//        }
//    } else if (indexPath.row == 0) {
//        theCell.Position = NZTileCellPositionFirst;
//    } else {
//        theCell.Position = NZTileCellPositionMiddle;
//    }
    
//    if ([self currentItems] == theRecordings) {
//        theCell.emailButton.alpha = 1;
//        
//    } else {
//        theCell.emailButton.alpha = 0;
//    }
    
//    if ([self currentItems] == theArrangements || [self currentItems] == theFavorites) {
//        theCell.FavoritesImage.hidden = theCell.favLabel.hidden = NO;
//    } else {
//        theCell.FavoritesImage.hidden = theCell.favLabel.hidden = YES;
//    }
    theCell.favorite = [favoritesList containsObject:item];
    theCell.jukebox = [jukeboxList containsObject:item];
    theCell.starImageView.hidden = [self currentItems] == theJukebox;
    theCell.jukeboxImageView.hidden = item.Type != LibraryItemTypeArrangement;
    
//    if (self.currentItems == theJukebox) {
//        theCell.showsReorderControl = YES;
//    } else {
//        theCell.showsReorderControl = NO;
//    }
    
    return theCell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath    {
    return UITableViewCellAccessoryNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    LibraryItem *item = theJukebox[sourceIndexPath.row];
    if (self.currentItems == theJukebox) {
        [theJukebox removeObjectAtIndex:sourceIndexPath.row];
        [theJukebox insertObject:item atIndex:destinationIndexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([indexPath isEqual:theSelectedPath]) {
//        return 105;
//    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    theSelectedPath = indexPath;
//    [theTableView beginUpdates];
//    [theTableView endUpdates];
    LibraryItem *item = [[self currentItems] objectAtIndex:indexPath.row];
    if (item != selectedItem) {
        selectedItem = item;
        if (self.playButton.selected) {
            [self playTapped:nil];
            [self playTapped:nil];
        }
    }
}

- (void)selectCurrentItem {
    NSIndexPath *theSelectedPath = [theTableView indexPathForSelectedRow];
    if (!theSelectedPath) return;
    LibraryItem *theItem = [[self currentItems] objectAtIndex:theSelectedPath.row];
    [SongOptions setCurrentItem:theItem isSameItem:NO setList:(theSegControl.selectedSegmentIndex == JUKEBOX)];
     [NZEvents logEvent:@"New song selected" args:@{@"Song": [SongOptions CurrentItem].Title, @"Exmatch" : @([SongOptions isExmatch]), @"Chorded" : @([SongOptions isChorded]), @"Keyboard" : @([SongOptions keyboardType]), @"TwoRow": @([SongOptions isTwoRow])}];
    [[PerformanceViewController sharedController] dismissLibraryController:![theItem.Arrangement isInitialized] newFile:YES];
    [[PerformanceViewController sharedController] willReappear];
}

- (void)deleteCurrentItem {
    NSIndexPath *theSelectedPath = [theTableView indexPathForSelectedRow];
    if (!theSelectedPath) return;
    LibraryItem *item = [[self currentItems] objectAtIndex:theSelectedPath.row];
    if ([LibraryManager fileItemHasDependenciesThatWillBeDeleted:item]) {
        [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"This song has arrangements that will also be deleted." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete All", nil] show];
        return;
    }
    [self _deleteItem];
}

- (void) _deleteItem {
    NSIndexPath *theSelectedPath = [theTableView indexPathForSelectedRow];
    if (!theSelectedPath) return;
    LibraryItem *item = [[self currentItems] objectAtIndex:theSelectedPath.row];
    if ([[AudioPlayer sharedPlayer].midiFile rangeOfString:item.Arrangement.MidiFile].location != NSNotFound) {
        if (self.playButton.selected) {
            [self playTapped:nil];
        }
    }
    [LibraryManager deleteItem:item];
    [self removeItemFromAllLists:item];
    NSIndexPath *copy = [NSIndexPath indexPathForRow:theSelectedPath.row inSection:theSelectedPath.section];
    theSelectedPath = nil;
    [theTableView deleteRowsAtIndexPaths:@[copy] withRowAnimation:UITableViewRowAnimationFade];
    if ([[SongOptions CurrentItem] isEqual:item] || [[SongOptions CurrentItem].Arrangement.MidiFile isEqualToString:item.Arrangement.MidiFile]) {
        [SongOptions setCurrentItem:nil isSameItem:NO];
        [[PerformanceViewController sharedController] clear];
    }
//    if (andReloadArrangements) {
//        [self loadArrangements];
//        if (theSegControl.selectedSegmentIndex == ARRANGEMENTS) {
//            [theTableView reloadData];
//        }
//    }
}

- (void)emailCurrentItem {
    NSIndexPath *theSelectedPath = [theTableView indexPathForSelectedRow];
    if (!theSelectedPath) return;
    LibraryItem *item = [[self currentItems] objectAtIndex:theSelectedPath.row];
    NSData *data;
    NSString *fileName;
    if ([self currentItems] == theLibraryFiles) {
        data = [NSData dataWithContentsOfFile:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile]];
        fileName = [item.Title stringByAppendingString:@".mid"];
    } else {
        item.Arrangement.fileData = [NSData dataWithContentsOfFile:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile]];
        NSMutableDictionary *dict = [item toDictionary].mutableCopy;
        dict[@"Jukebox"] = @(NO);
        dict[@"Favorite"] = @(NO);
        dict[@"Arrangement"][@"statsHistory"] = @[];
        data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        fileName = [item.Title stringByAppendingString:@".aqw"];
        
    }
    if (!data) {
        return;
    }
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"Check out %@ for Aqwertyan!", item.Title]];
//        NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@example.com", @"secondMail@example.com", nil];
//        [mailer setToRecipients:toRecipients];
     //   UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
      //  NSData *imageData = UIImagePNGRepresentation(myImage);
        [mailer addAttachmentData:data mimeType:@"application/octet-stream" fileName:fileName];
        NSString *emailBody = @"Tap on the file to open it in Aqwertyan. Don't have Aqwertyan? Download it <a href=\"http://itunes.apple.com/app/id584106288\">HERE</a>";
        [mailer setMessageBody:emailBody isHTML:YES];
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Your device doesn't support sending email from within the app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}



- (void)renameCurrentItem:(NSString *)name {
    NSIndexPath *theSelectedPath = [theTableView indexPathForSelectedRow];
    if (!theSelectedPath) return;
    LibraryItem *item = [[self currentItems] objectAtIndex:theSelectedPath.row];
    [LibraryManager setNewTitle:name forItem:item];
    if (item.Type == LibraryItemTypeFile) {
        if ([self currentItems] == theLibraryFiles) {
            [self loadLibraryFiles];
        } else {
            [self loadFavorites];
        }
    }
}

- (void)refresh {
    [self loadLibraryFiles];
    [self loadArrangements];
    [theTableView reloadData];
    [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void) removeItemFromAllLists:(LibraryItem *)item {
    [favoritesList removeObject:item];
    [arrangementsList removeObject:item];
    [libraryList removeObject:item];
    [jukeboxList removeObject:item];
    
    if (item.Type == LibraryItemTypeFile) {
        for (int i = arrangementsList.count - 1; i > -1; i--) {
            if ([[[arrangementsList[i] Arrangement] MidiFile] isEqualToString:item.Arrangement.MidiFile]) {
                [arrangementsList removeObjectAtIndex:i];
            }
        }
        for (int i = favoritesList.count - 1; i > -1; i--) {
            if ([[[favoritesList[i] Arrangement] MidiFile] isEqualToString:item.Arrangement.MidiFile]) {
                [favoritesList removeObjectAtIndex:i];
            }
        }
        for (int i = jukeboxList.count - 1; i > -1; i--) {
            if ([[[jukeboxList[i] Arrangement] MidiFile] isEqualToString:item.Arrangement.MidiFile]) {
                [jukeboxList removeObjectAtIndex:i];
            }
        }
    }
    
    [self setCurrentFiles:[NSArray arrayWithArray:[self currentList]]];
}


- (void)showHelp:(id)sender {
    [self presentHelp];
    [NZEvents startTimedFlurryEvent:@"Library help shown"];
}

- (void) presentHelp {
    if (!helpView) {
        
        helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-library.png"]];
        
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

- (void) hideHelp {
    [NZEvents stopTimedFlurryEvent:@"Library help shown"];
    [UIView transitionWithView:helpView duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^(void) {
        helpView.alpha = 0;
    }completion:^(BOOL finished ) {
        [helpView removeFromSuperview];
        helpView = nil;
    }];
}

@end


