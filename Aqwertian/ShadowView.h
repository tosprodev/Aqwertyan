//
//  ShadowView.h
//  Bridge
//
//  Created by Nathan Ziebart on 11/10/12.
//
//

#import <UIKit/UIKit.h>

@interface ShadowView : UIView

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
