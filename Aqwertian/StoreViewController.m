//
//  StoreViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "StoreViewController.h"
#import "Util.h"
//#import "SongUploadCell.h"
#import "LibraryManager.h"
#import "CreditsManager.h"
#import "InsetShadowView.h"
#import "AudioPlayer.h"
#import "SongOptionsViewController.h"
#import "StoreCell.h"
#import "PerformanceViewController.h"
#import "ScrollPaperTableView.h"
#import "FileSelectViewController.h"
#import "Reachability.h"
#define ADD_TO_LIB 0
#define PLAY 1
#define PREVIEW 2

StoreViewController *theStoreController;

@interface StoreViewController () {
    IBOutlet ScrollPaperTableView *theTableView;
    IBOutlet UILabel *theCreditsLabel;
    IBOutlet UIButton *thePlayButton;
    IBOutlet UISlider *theSlider;
    unsigned long totalTicks;
    unsigned short division;
    NSTimer *theTimer;
    IBOutlet InsetShadowView *theControlsView;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UISegmentedControl *segControl;
    NSArray *theSearchResults;
    NSMutableDictionary *downloads, *tempFiles;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UISlider *volumeSlider;
    IBOutlet UIButton *listenButton, *previewButton, *importButton;
    IBOutlet UILabel *currentTimeLabel, *totalTimeLabel;
    int updateLabel;
    IBOutlet UIImageView *tab1, *tab2, *tab3;
    UIImageView *helpView;
    NSString *playingItem;
    UIImageView *comingSoonView;
    NSString *selectedItem;
    LibraryItem *addedItem;
}

- (IBAction)dismiss:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)seek:(id)sender;

- (IBAction)switchTable:(id)sender;
- (IBAction)search:(id)sender;

- (IBAction)playTapped:(id)sender;
- (IBAction)previewTapped:(id)sender;
- (IBAction)importTapped:(id)sender;

- (IBAction)volume:(id)sender;
- (IBAction)buyButtonTapped:(id)sender;
- (IBAction)otherItems:(id)sender;

- (IBAction)showHelp:(id)sender;


@end

@implementation StoreViewController {
    NSMutableArray *filesList;
    NSMutableArray *theFiles;
    InsetShadowView *theShadow;
    Reachability *reach;
}


////
# pragma mark - STATIC CLASS METHODS
//

+ (StoreViewController *)sharedController {
    return theStoreController;
}


- (void) reachabilityChanged:(id)not {
    if (![reach isReachable]) {
    [[[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You don't appear to be connected to the internet. You will need a connection to search for songs and purchase qwertys." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


////
# pragma mark - INIT
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        theStoreController = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    
    theStoreController = self;
    reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [reach startNotifier];
//    if (![reach isReachable]) {
//        [[[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You don't appear to be connected to the internet. You will need a connection to search for songs and purchase qwertys" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }
    return self;
}


////
# pragma mark - VIEW CONTROLLER
//

- (void)newSongDidStart {
    [[AudioPlayer sharedPlayer] getInfo:&totalTicks dvision:&division];
    [theSlider setMaximumValue:(double)totalTicks * 24.0 / (double)division];
    [theSlider setValue:0];
    NSString *time = [NSString stringWithFormat:@"%ld:%02ld", [AudioPlayer sharedPlayer].totalTime/60,[AudioPlayer sharedPlayer].totalTime%60];
    totalTimeLabel.text = time;
    [self startTimer];
    listenButton.selected = YES;

}

- (void)songDidStop {
    [self finish];
}

- (void)viewDidAppear:(BOOL)animated {
    
    static NSString *key = @"storeShownOnce1";
    [NZEvents startTimedFlurryEvent:@"Store screen opened"];
     
    if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
      //  [self showHelp:nil];
//       [[[UIAlertView alloc] initWithTitle:@"Welcome to the Store!" message:@"Here, you can search for songs to perform! Use the Search tab for a limited quick search, or try the Web tab to search across the entire internet for midi or karaoke files. You can find everything from video game music to pop songs!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
     [NZEvents stopTimedFlurryEvent:@"Store screen opened"];
}

- (void)refreshSongList {
    [self loadFilesFromDocumentsDirectory];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MidiSearchManager setDelegate:self];
    
    theSlider.userInteractionEnabled = NO;
    [thePlayButton setTitle:@"" forState:UIControlStateNormal];
    [thePlayButton setTitle:@"" forState:UIControlStateHighlighted];
    
    tempFiles = [NSMutableDictionary new];
    downloads = [NSMutableDictionary new];
    
    theControlsView.userInteractionEnabled = YES;
    theControlsView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
    
    theTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"st-paper.png"]];
    
    UIImage *thumb = [UIImage imageNamed:@"st-slider-handle-centered.png"];
    [theSlider setThumbImage:thumb forState:UIControlStateNormal];
    [theSlider setMinimumTrackImage:[UIImage imageNamed:@"st-slider-fill-horizontal.png"] forState:UIControlStateNormal];
    [theSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    
    [volumeSlider setThumbImage:thumb forState:UIControlStateNormal];
    [volumeSlider setMinimumTrackImage:[UIImage imageNamed:@"st-slider-fill-horizontal.png"] forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    volumeSlider.minimumValue = [AudioPlayer sharedPlayer].minVolume;
    volumeSlider.maximumValue = [AudioPlayer sharedPlayer].maxVolume;
    
    [searchBar setBackgroundImage:[UIImage imageNamed:@"st-searchbar-blank.png"]];
    [searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"st-searchbar-blank.png"] resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateNormal];
    [searchBar setImage:[UIImage imageNamed:@"st-search-icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [searchBar setImage:[UIImage imageNamed:@"st-delete-button.png"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [segControl setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segControl setDividerImage:[UIImage imageNamed:@"blank.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    segControl.selectedSegmentIndex = 1;
    [self switchTable:nil];
//    CGPoint center = tab1.center;
//    center.y -= 0.25;
//    tab1.center = center;
//    center = tab2.center;
//    center.y -= 0.5;
//    tab2.center = center;
//    center = tab3.center;
//    center.y -= 0.5;
//    tab3.center = center;
//    
//    for(UIView *subView in searchBar.subviews) {
//        if ([subView isKindOfClass:[UITextField class]]) {
//            UITextField *searchField = (UITextField *)subView;
//            searchField.font = [UIFont fontWithName:@"Futura-Medium" size:17];
//            searchField.textColor = [UIColor colorWithRed:93.f/255.f green:55.f/255.f blue:33.f/255.f alpha:1];
//            searchField.layer.shadowOpacity = 1.0;
//            searchField.layer.shadowRadius = 0.0;
//            searchField.layer.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75].CGColor;
//            searchField.layer.shadowOffset = CGSizeMake(0.0, 1.0);
//            [[searchField performSelector:@selector(textInputTraits)] setValue:searchField.textColor forKey:@"insertionPointColor"];
//
//        }
//    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    theTableView.prefix = @"st";
    [self updateCredits];
    [self loadFilesFromDocumentsDirectory];
   // [theShadow setFrame:theTableView.frame];
    theSlider.userInteractionEnabled = NO;
    [thePlayButton setTitle:@"" forState:UIControlStateNormal];
    [thePlayButton setTitle:@"" forState:UIControlStateHighlighted];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[AudioPlayer sharedPlayer] setVolume:volumeSlider.value];
    });
    

    volumeSlider.value = [SongOptions volume];
    //[self enableButtons:NO];
    
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    BOOL wasPreviewing = [self.presentedViewController isKindOfClass:[SongOptionsViewController class]];
    [super dismissViewControllerAnimated:flag completion:completion];
   
    if (wasPreviewing) {
       
    } else {
         [self loadFilesFromDocumentsDirectory];
    }
   
}

- (void)otherItems:(id)sender {
    [self showComingSoon];
}

- (void) showComingSoon {
    if (!comingSoonView) {
        comingSoonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ComingSoon"]];
    }
    comingSoonView.alpha = 0;
    [self.view addSubview:comingSoonView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    comingSoonView.alpha = 1;
    [UIView commitAnimations];
    comingSoonView.userInteractionEnabled = YES;
    [comingSoonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideComingSoon)]];
}

- (void) hideComingSoon {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    comingSoonView.alpha = 0;
    [UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AudioPlayer sharedPlayer] stopPlaying];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[AudioPlayer sharedPlayer] setPlayerVolume:[AudioPlayer sharedPlayer].maxVolume];
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

# pragma mark - path
- (BOOL)pathPressed:(int)screen {
    switch (screen) {
        case PERFORMANCE:
            [[PerformanceViewController sharedController] dismissStore:YES];
            break;
        case OPTIONS:
            [[PerformanceViewController sharedController] dismissStore:YES];
            [[PerformanceViewController sharedController] performSelector:@selector(showOptions) withObject:nil afterDelay:0.75];
            break;
        case ARRANGEMENT:
            [[PerformanceViewController sharedController] dismissStore:YES];
            [[PerformanceViewController sharedController] performSelector:@selector(showSongOptions) withObject:nil afterDelay:0.75];
            break;
        case STORE:
            return NO;
            break;
        case LIBRARY:
            [[PerformanceViewController sharedController] dismissStore:YES];
            [[PerformanceViewController sharedController] performSelector:@selector(showLibrary) withObject:nil afterDelay:0.75];
            break;
        case INSTRUMENTS:
            [[PerformanceViewController sharedController] dismissStore:YES];
            [[PerformanceViewController sharedController] performSelector:@selector(showInstruments) withObject:nil afterDelay:0.75];
            break;
        case COLLAB:
            return NO;
            break;
        case USER_GUIDE:
            [[PerformanceViewController sharedController] dismissStore:YES];
            [[PerformanceViewController sharedController] performSelector:@selector(showGuide) withObject:nil afterDelay:0.75];
            break;
            
        default:
            return nil;
            break;
    }
    return YES;
}


////
# pragma mark - CREDITS
//

- (void) updateCredits {
    theCreditsLabel.text = [NSString stringWithFormat:@"%d", [[CreditsManager sharedManager] numberOfCredits]];
}

- (NSArray *) loadFiles {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [searchPaths objectAtIndex: 0];
    
    NSError* error = nil;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    NSArray *filteredArray = [filesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mid' OR self ENDSWITH '.kar'"]];
    
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filteredArray count]];
    for(NSString* file in filteredArray) {
        NSString* filePath = [[Util documentsDirectory] stringByAppendingPathComponent:file];
        NSDictionary* properties = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:filePath
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        
        if(error == nil)
        {
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
        }
    }
    
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;
                            }];
    return sortedFiles;
}


////
# pragma mark - HANDLING FILES
//
#define DELETE_SONGS_TIP_SHOWN_KEY @"deleteSongsTipShown"
- (void) loadFilesFromDocumentsDirectory {
    
    
    NSArray *list = [self loadFiles]; //[Util allFilesAtPath:[Util documentsDirectory] withPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mid' OR self ENDSWITH '.kar'"] sorted:YES];
    
    
    
    
    filesList = [NSMutableArray new];
//    NSArray *libraryItems = [LibraryManager getAllItems];
//    NSMutableArray *librarySongs = [NSMutableArray new];
//    for (LibraryItem *item in libraryItems) {
//        if (item.Type == LibraryItemTypeFile) {
//            [librarySongs addObject:item.Title];
//        }
//    }
    for (NSDictionary *path in list) {
        //if (![librarySongs containsObject:path]) {
            [filesList addObject:[path[@"path"] lastPathComponent]];
       // }
    }
    theFiles = [NSMutableArray arrayWithArray:filesList];
    NSIndexPath *path = theTableView.indexPathForSelectedRow;
    if (segControl.selectedSegmentIndex == 0) {
        NSString *fileName;
        if (path) {
            fileName = [theFiles objectAtIndex:path.row];
        }
        [theTableView reloadData];
        if (fileName && [theFiles containsObject:fileName]) {
            [theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[theFiles indexOfObject:fileName] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    if (theFiles.count > 15 && ![[NSUserDefaults standardUserDefaults] objectForKey:DELETE_SONGS_TIP_SHOWN_KEY]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DELETE_SONGS_TIP_SHOWN_KEY];
        
        [[[UIAlertView alloc] initWithTitle:@"Too many songs?" message:@"You can delete songs from the My iPad list by swiping them." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}


- (void)addNewSong:(NSString *)path {
    [filesList addObject:[path lastPathComponent]];
    [theFiles addObject:[path lastPathComponent]];
    [theTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:theFiles.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)uploadSelectedSong {
    if ([CreditsManager sharedManager].numberOfCredits < 1) {
        [self showAlertWithTitle:@"Oops!" description:@"You don't have any qwertys."];
        return;
    }
    NSIndexPath *theSelectedPath = theTableView.indexPathForSelectedRow;
    if (!theSelectedPath) return;
    if (segControl.selectedSegmentIndex == 0) {
        NSString *songPath = [[Util documentsDirectory] stringByAppendingPathComponent:[theFiles objectAtIndex:theSelectedPath.row]];
        addedItem = [LibraryManager addSong:songPath];
        if (addedItem) {
            [[CreditsManager sharedManager] subtractCredit];
        }
        [filesList removeObject:[theFiles objectAtIndex:theSelectedPath.row]];
        [theFiles removeObjectAtIndex:theSelectedPath.row];
        [theTableView beginUpdates];
        NSIndexPath *copy = [NSIndexPath indexPathForRow:theSelectedPath.row inSection:theSelectedPath.section];
        theSelectedPath = nil;
        [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:copy] withRowAnimation:UITableViewRowAnimationFade];
        [theTableView endUpdates];
        if (addedItem) {
            [[[UIAlertView alloc] initWithTitle:@"Song Added!" message:[NSString stringWithFormat:@"%@ has been added to your library.", [[[songPath lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"_" withString:@" "]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Perform Now",nil] show];
            
            [self updateCredits];
        }
    } else {
        NSString *songName = [theSearchResults objectAtIndex:theSelectedPath.row];
        NSString *fileName = [tempFiles objectForKey:songName];
        if (fileName && [Util fileExists:fileName]) {
            [self uploadDownloadedSong:songName];
        } else {
            [MidiSearchManager downloadSong:theSelectedPath.row toDirectory:[Util tempFilesDirectory]];
            [downloads setObject:[NSNumber numberWithInt:ADD_TO_LIB] forKey:songName];
            [activityIndicator startAnimating];
//            [theTableView reloadRowsAtIndexPaths:@[theSelectedPath] withRowAnimation:UITableViewRowAnimationNone];
//            [theTableView selectRowAtIndexPath:theSelectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void) setTabImages {
    tab1.image = [UIImage imageNamed:segControl.selectedSegmentIndex == 0 ? @"st-tab-1-pressed.png" : @"st-tab-1.png"];
    tab2.image = [UIImage imageNamed:segControl.selectedSegmentIndex == 1 ? @"st-tab-2-pressed.png" : @"st-tab-2.png"];
    tab3.image = [UIImage imageNamed:segControl.selectedSegmentIndex == 2 ? @"st-tab-3-pressed.png" : @"st-tab-3.png"];
}

- (void) enableButtons:(BOOL)enable {
    previewButton.enabled = enable;
    listenButton.enabled = enable;
    importButton.enabled = enable;
    
}

////
# pragma mark - MIDI SEARCH
//

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    if (segControl.selectedSegmentIndex == 1) {
        if (aSearchBar.text.length > 0) {
            [MidiSearchManager searchFor:aSearchBar.text];
            [activityIndicator startAnimating];
        } else {
            theSearchResults = nil;
            [theTableView reloadData];
        }
    }
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (segControl.selectedSegmentIndex == 0) {
        theFiles = [NSMutableArray new];
        for (NSString *file in filesList) {
            if (searchText.length == 0 || [[file lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) {
                [theFiles addObject:file];
            }
        }
        [theTableView reloadData];
    } else {
        if (searchBar.text.length > 0) {
            [MidiSearchManager searchFor:searchBar.text];
            [activityIndicator startAnimating];
        } else {
            theSearchResults = nil;
            [theTableView reloadData];
        }
    }
}

- (void)searchFinished:(NSArray *)results {
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(logSearchFinished) object:nil];
    [self performSelector:@selector(logSearchFinished) withObject:nil afterDelay:3];
    theSearchResults = results;
    if (segControl.selectedSegmentIndex == 1) {
        [theTableView reloadData];
    }
    if (![MidiSearchManager isSearching]) {
    [activityIndicator stopAnimating];
    }
}

- (void) logSearchFinished {
    [NZEvents logEvent:@"Store quick search"];
}

- (void)searchFailed:(NSString *)reason {
    [self showAlertWithTitle:@"Search Failed" description:reason];
    [activityIndicator stopAnimating];
}

- (void) uploadDownloadedSong:(NSString *)songName {
    if ([CreditsManager sharedManager].numberOfCredits < 1) {
        [self showAlertWithTitle:@"Sorry!" description:@"You don't have any song credits."];
        return;
    }
    NSString *path = [tempFiles objectForKey:songName];
    if (path) {
        int index = [theSearchResults indexOfObject:songName];
        if (index > -1 && index < theSearchResults.count) {
            theSearchResults = [NSMutableArray arrayWithArray:theSearchResults];
            [(NSMutableArray *)theSearchResults removeObjectAtIndex:index];
            if (segControl.selectedSegmentIndex == 1) {
                [theTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
           // theSelectedPath = [theTableView indexPathForSelectedRow];
        }
    }
    addedItem = [LibraryManager addSong:path];
    if (addedItem) {
        [[CreditsManager sharedManager] subtractCredit];
        [[[UIAlertView alloc] initWithTitle:@"Song Added!" message:[NSString stringWithFormat:@"%@ has been added to your library.", [[[path lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"_" withString:@" "]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Perform Now",nil] show];
    }
    [self updateCredits];
    

}

- (void)downloadFinished:(NSString *)path forSong:(NSString *)songName {
    [tempFiles setObject:path forKey:songName];
    
    if ([[downloads objectForKey:songName] integerValue] == ADD_TO_LIB) {
        [self uploadDownloadedSong:songName];
    } else if ([[downloads objectForKey:songName] integerValue] == PLAY) {
        if ([AudioPlayer sharedPlayer].isPlaying) {
            [[AudioPlayer sharedPlayer] stopPlaying];
            [self performSelector:@selector(playSong:) withObject:path afterDelay:1];
        } else {
            [self playSong:path];
        }
    } else {
        [self previewSong:path];
    }
    [activityIndicator stopAnimating];
    if ([segControl selectedSegmentIndex] == 1) {
        if ([theSearchResults containsObject:songName]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:[theSearchResults indexOfObject:songName] inSection:0];
            [theTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            [theTableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)downloadFailed:(NSString *)reason {
    [self showAlertWithTitle:@"Download Failed" description:reason];
    [activityIndicator stopAnimating];
}

- (void)switchTable:(id)sender {
    if (segControl.selectedSegmentIndex == 0) {
        searchBar.placeholder = @"";
    } else if (segControl.selectedSegmentIndex == 1) {
        searchBar.placeholder = @"Use full names for best results";
    } else {
        [searchBar resignFirstResponder];
        [[PerformanceViewController sharedController] performSegueWithIdentifier:@"Web" sender:nil];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [segControl setSelectedSegmentIndex:0];
            [self switchTable:nil];
        });
        
    }
    [theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self setTabImages];
    
}

- (void) showAlertWithTitle:(NSString *)title description:(NSString *)description {
    [[[UIAlertView alloc] initWithTitle:title message:description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Perform Now"]) {
      //  [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:LIB_TAB_KEY];
      //  [self pathPressed:LIBRARY];
        [SongOptions setCurrentItem:addedItem isSameItem:NO];
        [[PerformanceViewController sharedController] dismissStoreAndPerformCurrentSong];
    }
}

////
# pragma mark - TABLE VIEW DELEGATE & DATA
//

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [theTableView didScroll];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return segControl.selectedSegmentIndex == 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (segControl.selectedSegmentIndex == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:[[Util documentsDirectory] stringByAppendingPathComponent:theFiles[indexPath.row]] error:nil];
        [theFiles removeObjectAtIndex:indexPath.row];
        [theTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreCell *theCell = [tableView dequeueReusableCellWithIdentifier:@"Upload"];
    int count;
    if (segControl.selectedSegmentIndex == 0) {
        count = theFiles.count;
        theCell.textLabel.text = [[[theFiles objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    } else {
        count = theSearchResults.count;
        theCell.textLabel.text = [theSearchResults objectAtIndex:indexPath.row];
        NSString *downloadingSong = [MidiSearchManager downloadingSong];
        if (downloadingSong && [downloadingSong isEqualToString:[theSearchResults objectAtIndex:indexPath.row]]) {
        
         //   theCell.ButtonsView.hidden = YES;
        } else {
            
         //   theCell.ButtonsView.hidden = NO;
        }
    }

//    if (indexPath.row == count - 1) {
//        if (indexPath.row == 0) {
//            theCell.Position = NZTileCellPositionBoth;
//        } else {
//            theCell.Position = NZTileCellPositionLast;
//        }
//    } else if (indexPath.row == 0) {
//        theCell.Position = NZTileCellPositionFirst;
//    } else {
//        theCell.Position = NZTileCellPositionMiddle;
//    }
    
    return theCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    theSelectedPath = indexPath;
//    [theTableView beginUpdates];
//    [theTableView endUpdates];
    NSArray *items = segControl.selectedSegmentIndex == 0 ? theFiles : theSearchResults;
    NSString *item = [items objectAtIndex:indexPath.row];
    if (item != selectedItem) {
        selectedItem = item;
        if (listenButton.selected) {
            [self playTapped:nil];
            [self playTapped:nil];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([indexPath isEqual:theSelectedPath]) {
//        return 105;
//    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return segControl.selectedSegmentIndex == 0 ? theFiles.count : theSearchResults.count;
}

////
# pragma mark - IBACTIONS
//

- (void)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [[PerformanceViewController sharedController] dismissStore:YES];
}



////
# pragma mark - PLAYING SONGS
//

- (void)playCurrentSong {
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSong:) object:nil];
    NSIndexPath *theSelectedPath = theTableView.indexPathForSelectedRow;
    if (!theSelectedPath) return;
    if (segControl.selectedSegmentIndex == 0) {
        NSString *songPath = [[Util documentsDirectory] stringByAppendingPathComponent:[theFiles objectAtIndex:theSelectedPath.row]];
        if ([AudioPlayer sharedPlayer].isPlaying) {
            [[AudioPlayer sharedPlayer] stopPlaying];
            [self performSelector:@selector(playSong:) withObject:songPath afterDelay:1];
        } else {
            [self playSong:songPath];
        }
    } else {
        NSString *songName = [theSearchResults objectAtIndex:theSelectedPath.row];
        NSString *fileName = [tempFiles objectForKey:songName];
        if (fileName && [Util fileExists:fileName]) {
            if ([AudioPlayer sharedPlayer].isPlaying) {
                [[AudioPlayer sharedPlayer] stopPlaying];
                [self performSelector:@selector(playSong:) withObject:fileName afterDelay:1];
            } else {
                [self playSong:fileName];
            }
        } else {
            [MidiSearchManager downloadSong:theSelectedPath.row toDirectory:[Util tempFilesDirectory]];
            [downloads setObject:[NSNumber numberWithInt:PLAY] forKey:songName];
            [activityIndicator startAnimating];
           // [theTableView reloadRowsAtIndexPaths:@[theSelectedPath] withRowAnimation:UITableViewRowAnimationNone];
           // [theTableView selectRowAtIndexPath:theSelectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void) playSong:(NSString *)songPath {
    if ([[AudioPlayer sharedPlayer].midiFile isEqualToString:songPath]) {
        
    } else {
        [[AudioPlayer sharedPlayer] setMidiFile:songPath];
        [NZEvents logEvent:@"New song played in store"];
    }
    [[AudioPlayer sharedPlayer] getInfo:&totalTicks dvision:&division];
    NSString *time = [NSString stringWithFormat:@"%ld:%02ld", [AudioPlayer sharedPlayer].totalTime/60,[AudioPlayer sharedPlayer].totalTime%60];
    totalTimeLabel.text = time;
    if (totalTicks == 0 || division == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"This midi file is invalid" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        listenButton.selected = NO;
        
    } else {
        [theSlider setMaximumValue:(double)totalTicks * 24.0 / (double)division];
        [theSlider setValue:0];
        theSlider.userInteractionEnabled = YES;
        
        [self startTimer];
        [[AudioPlayer sharedPlayer] startPlaying];
        
        listenButton.selected = YES;
    }
}

- (void) startTimer {
    if (theTimer) {
        [theTimer invalidate];
    }
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            theTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            updateLabel = 0;
        });
        
    
}

- (void) updateSlider {
    if (++updateLabel%5 == 0) {
        NSString *time = [NSString stringWithFormat:@"%d:%02d", (int)[AudioPlayer sharedPlayer].currentTime/60,(int)[AudioPlayer sharedPlayer].currentTime%60];
        currentTimeLabel.text = time;
    }
    if (theSlider.touchInside) {
        return;
    }
    [theSlider setValue:[AudioPlayer sharedPlayer].clocks];
    if (theSlider.value == theSlider.maximumValue) {
        [theTimer invalidate];
        [self performSelector:@selector(finish) withObject:nil afterDelay:2];
    }

}

- (void) finish {
    NSLog(@"done");
    [[AudioPlayer sharedPlayer] stopPlaying];
    [[AudioPlayer sharedPlayer] seek:0];
    [theSlider setValue:0];
    [theTimer invalidate];
    currentTimeLabel.text = @"0:00";
}

- (void)seek:(id)sender {
	unsigned long tick = theSlider.value * division / 24;
	NSLog (@"seek %lu tick = %.0f MIDI clocks", tick, theSlider.value);
    [[AudioPlayer sharedPlayer] seek:tick];
    if (theTimer) {
        [self startTimer];
    }
}

- (void)play:(id)sender {
    if ([[thePlayButton titleForState:UIControlStateNormal] isEqualToString:@"Play"]) {
        [thePlayButton setTitle:@"Pause" forState:UIControlStateNormal];
        [thePlayButton setTitle:@"Pause" forState:UIControlStateHighlighted];
        [[AudioPlayer sharedPlayer] startPlaying];
    } else if ([[thePlayButton titleForState:UIControlStateNormal] isEqualToString:@"Pause"]) {
        [thePlayButton setTitle:@"Play" forState:UIControlStateNormal];
        [thePlayButton setTitle:@"Play" forState:UIControlStateHighlighted];
        [[AudioPlayer sharedPlayer] stopPlaying];
        [theTimer invalidate];
    }
}

- (void)previewCurrentSong {
    NSIndexPath *theSelectedPath = theTableView.indexPathForSelectedRow;
    if (!theSelectedPath) return;
    if (segControl.selectedSegmentIndex == 0) {
        NSString *songPath = [[Util documentsDirectory] stringByAppendingPathComponent:[theFiles objectAtIndex:theSelectedPath.row]];
        [self previewSong:songPath];
    } else {
        NSString *songName = [theSearchResults objectAtIndex:theSelectedPath.row];
        NSString *fileName = [tempFiles objectForKey:songName];
        if (fileName && [Util fileExists:fileName]) {
            [self previewSong:fileName];
        } else {
            [MidiSearchManager downloadSong:[theSearchResults objectAtIndex:theSelectedPath.row] toDirectory:[Util tempFilesDirectory]];
            [downloads setObject:[NSNumber numberWithInt:PREVIEW] forKey:songName];
            [activityIndicator startAnimating];
//            [theTableView reloadRowsAtIndexPaths:@[theSelectedPath] withRowAnimation:UITableViewRowAnimationFade];
//            [theTableView selectRowAtIndexPath:theSelectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void) previewSong:(NSString *)songPath {
    if (listenButton.selected) {
        [[AudioPlayer sharedPlayer] stopPlaying];
        self.view.userInteractionEnabled = NO;
        double delayInSeconds = 1.0;
        listenButton.selected = NO;
        previewButton.selected=YES;
    
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             [[PerformanceViewController sharedController] showPreviewForStore:songPath];
            self.view.userInteractionEnabled=YES;
            previewButton.selected=NO;
        });
       
    } else {
        [[PerformanceViewController sharedController] showPreviewForStore:songPath];
    }

}

- (void)previewTapped:(id)sender {
    [self previewCurrentSong];
    [NZEvents logEvent:@"Store preview tapped"];
}

- (void)importTapped:(id)sender {
    [self uploadSelectedSong];
}

- (void)playTapped:(id)sender {
    if (listenButton.selected) {
        listenButton.selected = NO;
        [[AudioPlayer sharedPlayer] stopPlaying];
        [theTimer invalidate];
    } else {
        listenButton.selected = YES;
        [self playCurrentSong];
    }
}

- (void)buyButtonTapped:(id)sender {
    if (![reach isReachable]) {
        [self showAlertWithTitle:@"No Connection" description:@"You must be connected to the internet to make a purchase."];
        return;
    }
    UIButton *theButton = (UIButton *)sender;
    
    [NZEvents logEvent:@"Buy button tapped" args:@{@"Number of Credits" : @(theButton.tag)}];
    [self showLoadingHUD:@"Processing your purchase" subText:nil];
    
    __weak id weakSelf = self;
    [[CreditsManager sharedManager] buyCredits:theButton.tag withCallback:^(BOOL success) {
        [weakSelf hideHUD:0];
        if (success) {
            [weakSelf showAlertWithTitle:@"Success!" message:@"Your credits have been added."];
            [weakSelf updateCredits];
        }
    }];
}

- (void)volume:(id)sender {
    [[AudioPlayer sharedPlayer] setPlayerVolume:volumeSlider.value];
    [SongOptions setVolume:volumeSlider.value];
}

- (void)showHelp:(id)sender {
    [NZEvents startTimedFlurryEvent:@"Store help shown"];
    [self presentHelp];
    
}

- (void) presentHelp {
    if (!helpView) {
        
        helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-store.png"]];
        
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
     [NZEvents stopTimedFlurryEvent:@"Store help shown"];
    [UIView transitionWithView:helpView duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^(void) {
        helpView.alpha = 0;
    }completion:^(BOOL finished ) {
        [helpView removeFromSuperview];
        helpView = nil;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

////
# pragma mark - SEGUES
//

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"BuyCredits"]) {
        
    } else if ([segue.identifier isEqualToString:@"Preview"]) {
        SongOptionsViewController *svc = [segue destinationViewController];
        svc.isForStore = YES;
        svc.songPath = sender;
    }
}




@end
