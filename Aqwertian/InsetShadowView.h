//
//  InsetShadowView.h
//  Bridge
//
//  Created by Nathan Ziebart on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsetShadowView : UITextField

@property NSInteger cornerRadius;
@property double shadowOpacity;
@property NSInteger shadowOffset;
@property NSInteger shadowRadius;

- (void) addGradient;
- (void) setup;
- (void) goGray;
- (void) goGradient;
- (void) goWhite;
@end
