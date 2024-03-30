//
//  NZTileCell.h
//  Bridge
//
//  Created by Nathan Ziebart on 11/17/12.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NZTileCellPosition) {
    NZTileCellPositionFirst,
    NZTileCellPositionLast,
    NZTileCellPositionMiddle,
    NZTileCellPositionBoth
};

@interface NZTileCell : UITableViewCell

+ (UIImage *)bgImage;

@property UIColor *TintColor;
@property BOOL Reverse;
@property IBOutlet UILabel *Label;
@property NZTileCellPosition Position;

- (void) setup;

@end
