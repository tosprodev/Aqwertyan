//
//  TitleCell.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/9/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "TitleCell.h"

@implementation TitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self= [super initWithCoder:aDecoder];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ug-title.png"]];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ug-title-pressed.png"]];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
