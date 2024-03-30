//
//  ModalDoneViewController.h
//  Bridge
//
//  Created by Nathan Ziebart on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface HUDViewController : UIViewController <UIAlertViewDelegate>

@property MBProgressHUD *HUD;

- (IBAction)dismiss:(id)sender;
- (IBAction)back:(id)sender;
- (void) showLoadingHUD:(NSString *)aMessage subText:(NSString *)subText;
- (void) showMessageHUD:(NSString *)aMessage subText:(NSString *)subText hide:(double)time;
- (void) changeLoadingHUDToTextHUD:(NSString *)aMessage subText:(NSString *)subText hide:(double)time;
- (void) hideHUD:(double)delay;
- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message;

@property UIViewController *Parent;

@end
