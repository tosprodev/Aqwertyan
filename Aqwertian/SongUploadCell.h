//
//  SongUploadCell.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NZTileCell.h"
@interface SongUploadCell : NZTileCell

@property IBOutlet UILabel *TitleLabel;
@property IBOutlet UIView *AccessoryView;
@property IBOutlet UIActivityIndicatorView *ActivityIndicator;
@property IBOutlet UIView *ButtonsView;

- (IBAction)uploadTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)previewTapped:(id)sender;

@end
