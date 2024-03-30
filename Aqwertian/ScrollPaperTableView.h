//
//  ScrollPaperTableView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/23/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollPaperTableView : UITableView

@property (nonatomic) NSString *prefix;

- (void) didScroll;

@end
