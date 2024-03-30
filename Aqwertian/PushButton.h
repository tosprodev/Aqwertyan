//
//  PushButton.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/1/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBShapedButton.h"

@interface PushButton : UIButton

@property (nonatomic) UIImage *upImage, *downImage;
@property (nonatomic) BOOL ignoreTouchesOnTransparentRegions;

@end
