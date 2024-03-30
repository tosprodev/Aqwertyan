//
//  PathButton.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/2/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "PushButton.h"

#define PERFORMANCE 3
#define OPTIONS 6
#define ARRANGEMENT 5
#define STORE 4
#define LIBRARY 2
#define INSTRUMENTS 1
#define COLLAB 500
#define USER_GUIDE 0

@protocol PathButtonDelegate <NSObject>

- (BOOL) pathPressed:(int)screen;

@optional

- (void) pathOpened;

@end

@interface PathButton : PushButton

@property (nonatomic, weak) IBOutlet id<PathButtonDelegate> delegate;

@end
