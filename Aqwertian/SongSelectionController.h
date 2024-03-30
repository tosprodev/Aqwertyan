//
//  SongSelectionController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/27/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerformanceViewController.h"

@interface SongSelectionController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property UIPopoverController *Popover;
@property PerformanceViewController *Delegate;

- (void) loadSong:(NSString *)name;

@end
