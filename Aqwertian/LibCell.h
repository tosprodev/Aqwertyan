//
//  LibCell.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/18/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibCell : UITableViewCell

@property (nonatomic) BOOL favorite, *jukebox;
@property (nonatomic) IBOutlet UILabel *titleLabel, *dateLabel;
@property (nonatomic) IBOutlet UIImageView *starImageView, *jukeboxImageView;
@property (nonatomic) id item;
 
@end
