//
//  ButtonKey.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/21/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBShapedButton.h"

@class ButtonKey;

@protocol ButtonKeyDelegate <NSObject>

- (void) keyDown:(ButtonKey *)sender;
- (void) keyUp:(ButtonKey *)sender;

@end


@interface ButtonKey : OBShapedButton

@property id<ButtonKeyDelegate> Delegate;

- (void) setChar:(char)aChar thumb:(BOOL)thumb;
- (void) keyDown:(id)sender; 
- (void) keyUp:(id)sender;
- (void) setColumned:(BOOL)columned;
- (BOOL) containsPoint:(CGPoint)point withExpansion:(float)expansionWidth;

@end
