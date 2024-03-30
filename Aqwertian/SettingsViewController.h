//
//  SettingsViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 1/20/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathButton.h"

@interface SettingsViewController : UIViewController

+ (void) loadSavedSettings;
//+ (void) loadSettings:(NSDictionary *)settings;
+ (void) loadArrangementSettings:(NSDictionary *)settings;
+ (NSDictionary *) getSettings;

@end
