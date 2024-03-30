//
//  SongUploadCell.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "SongUploadCell.h"
#import "StoreViewController.h"

@implementation SongUploadCell

////
# pragma mark - INIT
//

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

////
# pragma mark - SELECTION
//

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

////
# pragma mark - BUTTON TAP
//

- (void) uploadTapped:(id)sender {
    [[StoreViewController sharedController] uploadSelectedSong];
}

- (void)playTapped:(id)sender {
    [[StoreViewController sharedController] playCurrentSong];
}

- (void)previewTapped:(id)sender {
    [[StoreViewController sharedController] previewCurrentSong];
}


////
# pragma mark - FRAME AND LAYOUT
//

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.frame.size.height < 80) {
        if (self.AccessoryView.alpha == 1) {
            [UIView beginAnimations:nil context:nil];
            self.AccessoryView.alpha = 0;
            [UIView commitAnimations];
        }
    } else {
        if (self.AccessoryView.alpha == 0) {
            [UIView beginAnimations:nil context:nil];
            self.AccessoryView.alpha = 1;
            [UIView commitAnimations];
        }
    }
}

@end
