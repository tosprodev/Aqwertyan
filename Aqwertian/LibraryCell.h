//
//  LibraryCell.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/4/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "NZTileCell.h"
#import "FileSelectViewController.h"
#import "LbraryItem.h"
#import "LibraryManager.h"

@interface LibraryCell : NZTileCell <UIAlertViewDelegate> {
    IBOutlet UIButton *selectButton, *deleteButton, *renameButton;
    IBOutlet UIView *accessoryView;

}

+ (UIImage *)onImage;
+ (UIImage *)offImage;

   
@property IBOutlet UIButton *emailButton;
@property IBOutlet UIImageView *FavoritesImage, *jukeboxImage;
@property IBOutlet UILabel *favLabel;
@property BOOL Favorite, Jukebox;
@property LibraryItem *Item;

- (IBAction)buttonTapped:(id)sender;
- (IBAction)selectButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)renameButtonTapped:(id)sender;
- (IBAction)email:(id)sender;
@end
