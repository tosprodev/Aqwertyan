//
//  LibraryCell.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/4/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "LibraryCell.h"

@implementation LibraryCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self  = [super initWithCoder:aDecoder];
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

+ (UIImage *)onImage {
    UIImage *theImage = nil;
    
    if (!theImage) {
        theImage = [[UIImage imageNamed:@"button_bg_pressed_clear"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    
    return theImage;
}

+ (UIImage *)offImage {
    UIImage *theImage = nil;
    
    if (!theImage) {
        theImage = [[UIImage imageNamed:@"button_bg_clear"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    
    return theImage;
}

- (void)setAccessoryView:(UIView *)anAccessoryView {
    accessoryView = anAccessoryView;
    if (accessoryView.superview == self.contentView) {
        NSString *s = @"";
    }
  //  [self.accessoryView setFrame:CGRectMake(0, 0, 50, 50)];
}

- (UIView *)accessoryView {
    return accessoryView;
}

- (void)setup {
    self.FavoritesImage = [UIImageView new];
    self.FavoritesImage.image = [LibraryCell offImage];
    self.FavoritesImage.tag = 0;
    self.FavoritesImage.userInteractionEnabled = YES;
    [self.FavoritesImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)]];
    [self.contentView addSubview:self.FavoritesImage];
    
    self.favLabel = [UILabel new];
    self.favLabel.font = [UIFont boldSystemFontOfSize:20];
    self.favLabel.textColor = [UIColor blackColor];
    self.favLabel.shadowColor = [UIColor whiteColor];
    self.favLabel.shadowOffset = CGSizeMake(0,1);
    [self.contentView addSubview:self.favLabel];
    self.favLabel.text = @"Fav";
    [self.favLabel setFrame:CGRectMake(0, 0, 100, 50)];
    self.favLabel.backgroundColor = [UIColor clearColor];
    self.favLabel.textAlignment = UITextAlignmentCenter;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) jukeboxTapped:(id)sender {
    if (self.Jukebox) {
        self.Jukebox = NO;
        [[FileSelectViewController sharedController] removeJukebox:self.Item];
    } else {
        self.Jukebox = YES;
        [[FileSelectViewController sharedController] addJukebox:self.Item];
    }
}

- (void) buttonTapped:(id)sender {
    if (self.Favorite) {
        self.Favorite = NO;
        [[FileSelectViewController sharedController] removeFavorite:self.Item];
    } else {
        self.Favorite = YES;
        [[FileSelectViewController sharedController] addFavorite:self.Item];
    }
}

- (void)deleteButtonTapped:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", self.Label.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show ];
}

- (void)renameButtonTapped:(id)sender {
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Rename" message:[NSString stringWithFormat:@"Enter a new name for %@", self.Label.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    theAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [theAlert show];
}

- (void)selectButtonTapped:(id)sender {
    [[FileSelectViewController sharedController] selectCurrentItem];
}

- (void)email:(id)sender {
    [[FileSelectViewController sharedController] emailCurrentItem];
}

- (void)setFavorite:(BOOL)Favorite {
    if (Favorite) {
        self.FavoritesImage.tag = 1;
        self.FavoritesImage.image = [LibraryCell onImage];
    } else {
        self.FavoritesImage.tag = 0;
        self.FavoritesImage.image = [LibraryCell offImage];
    }
}

- (void)setJukebox:(BOOL)Jukebox {
    if (Jukebox) {
        self.jukeboxImage.tag = 1;
        self.jukeboxImage.image = [UIImage imageNamed:@"jukebox-on"];
    } else {
        self.jukeboxImage.tag = 0;
        self.jukeboxImage.image = [UIImage imageNamed:@"jukebox-off"];
    }
}

- (BOOL)Jukebox {
    return  self.jukeboxImage.tag == 1;
}

- (BOOL)Favorite {
    return self.FavoritesImage.tag == 1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.FavoritesImage setFrame:CGRectMake(self.contentView.frame.size.width - 80, 2, 70, 46)];
    self.favLabel.center = self.FavoritesImage.center;
    if (![self.contentView.subviews containsObject:self.accessoryView]) {
        
        [self.accessoryView removeFromSuperview];
        [self.contentView addSubview:self.accessoryView];
    }
    CGRect frame = accessoryView.frame;
    frame.origin.x = 20;
    frame.origin.y = 48;
    accessoryView.frame = frame;
   // self.accessoryView.frame = CGRectMake(10, 50, self.frame.size.width - 20, 55);
        if (self.frame.size.height < 80) {
            if (self.accessoryView.alpha == 1) {
                [UIView beginAnimations:nil context:nil];
                self.accessoryView.alpha = 0;
                [UIView commitAnimations];
            }
        } else {
            if (self.accessoryView.alpha == 0) {
                [UIView beginAnimations:nil context:nil];
                self.accessoryView.alpha = 1;
                [UIView commitAnimations];
            }
        }
    
}

////
# pragma mark - ALERT VIEW DELEGATE
//

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save"]) {
        self.Label.text = [alertView textFieldAtIndex:0].text;
        [LibraryManager setNewTitle:[alertView textFieldAtIndex:0].text forItem:self.Item];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        [[FileSelectViewController sharedController] deleteCurrentItem];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
