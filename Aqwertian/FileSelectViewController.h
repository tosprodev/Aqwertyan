//
//  MidiSelectViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/23/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//
#import "SongOptionsViewController.h"
#import <UIKit/UIKit.h>
#import "LbraryItem.h"
#import <MessageUI/MessageUI.h>
#import "MIDIPlayerViewController.h"
#import "PathButton.h"
#import "AppiraterDelegate.h"

#define LIB_TAB_KEY @"libTab"
#define RATED_KEY @"Rated7"
#define LIKED_KEY @"FBLike3"

@interface FileSelectViewController : MIDIPlayerViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, PathButtonDelegate, UIActionSheetDelegate, AppiraterDelegate >

+ (FileSelectViewController *) sharedController;

- (void) removeFavorite:(LibraryItem *)favorite;
- (void) addFavorite:(LibraryItem *)favorite;
- (void) addJukebox:(LibraryItem *)item;
- (void) removeJukebox:(LibraryItem *)item;
- (void) selectCurrentItem;
- (void) deleteCurrentItem;
- (void) renameCurrentItem:(NSString *)name;
- (void) emailCurrentItem;
- (void) refresh;
- (void) hideLikeButton;

@end
