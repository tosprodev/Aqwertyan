//
//  StoreViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MidiSearchManager.h"
#import "HUDViewController.h"
#import "PathButton.h"

@interface StoreViewController : HUDViewController <UITableViewDataSource, UITableViewDelegate, MidiSearchDelegate, UIAlertViewDelegate, UISearchBarDelegate, PathButtonDelegate>

+ (StoreViewController *)sharedController;

- (void) refreshSongList;
- (void) uploadSelectedSong;
- (void) updateCredits;
- (void) playCurrentSong;
- (void) previewCurrentSong;
- (void) addNewSong:(NSString *)path;
- (IBAction)importTapped:(id)sender;
- (void) newSongDidStart;
- (void) songDidStop;

@end
