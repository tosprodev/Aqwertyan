//
//  LibCell.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/18/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "LibCell.h"
#import "FileSelectViewController.h"

@implementation LibCell {
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

- (void)setFavorite:(BOOL)favorite {
    _favorite = favorite;
    if (_favorite) {
        _starImageView.image = [UIImage imageNamed:@"li-star-pressed.png"];
    } else {
        _starImageView.image = [UIImage imageNamed:@"li-star.png"];
    }
}

- (void)setJukebox:(BOOL *)jukebox  {
    _jukebox = jukebox;
    if (jukebox) {
        _jukeboxImageView.image = [UIImage imageNamed:@"li-setlist-pressed.png"];
    } else {
        _jukeboxImageView.image = [UIImage imageNamed:@"li-setlist.png"];
    }
}

- (void) setup {
    if (setup) return; setup = YES;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"li-list-row.png"]];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"li-list-row-pressed.png"]];
    self.backgroundView.contentMode = self.selectedBackgroundView.contentMode = UIViewContentModeCenter;
    
    _starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(735, 6, 37, 32)];
    _starImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_starImageView];
    
    
    _jukeboxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(697, 6, 37, 32)];
    _jukeboxImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_jukeboxImageView];
    
    _starImageView.userInteractionEnabled=YES;
    [_starImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)]];
    _jukeboxImageView.userInteractionEnabled=YES;
    [_jukeboxImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jukeboxTapped:)]];
}

- (void) jukeboxTapped:(id)sender {
    if (self.jukebox) {
        self.jukebox = NO;
        [[FileSelectViewController sharedController] removeJukebox:self.item];
    } else {
        self.jukebox = YES;
        [[FileSelectViewController sharedController] addJukebox:self.item];
    }
}

- (void) buttonTapped:(id)sender {
    if (self.favorite) {
        self.favorite = NO;
        [[FileSelectViewController sharedController] removeFavorite:self.item];
    } else {
        self.Favorite = YES;
        [[FileSelectViewController sharedController] addFavorite:self.item];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
