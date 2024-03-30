//
//  StoreCell.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/17/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "StoreCell.h"

@implementation StoreCell {
    BOOL setup;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void) setup {
    if (setup) return; setup = YES;
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"st-list-row.png"]];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"st-list-row-pressed.png"]];
    self.backgroundView.contentMode = self.selectedBackgroundView.contentMode = UIViewContentModeCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
