//
//  ModalDoneViewController.m
//  Bridge
//
//  Created by Nathan Ziebart on 11/1/12.
//
//

#import "HUDViewController.h"

@interface HUDViewController ()

@end

@implementation HUDViewController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)showLoadingHUD:(NSString *)aMessage subText:(NSString *)subText {
    [self.HUD hide:NO];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText = aMessage;
    self.HUD.detailsLabelText = subText;
}

- (void)hideHUD:(double)delay {
    if (delay > 0)
        [self.HUD hide:YES afterDelay:delay];
    else
        [self.HUD hide:YES];
}


- (void)showMessageHUD:(NSString *)aMessage subText:(NSString *)subText hide:(double)time {
    [self.HUD hide:NO];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.labelText = aMessage;
    self.HUD.detailsLabelText = subText;
    if (time > 0) {
        [self.HUD hide:YES afterDelay:time];
    }
}

- (void)changeLoadingHUDToTextHUD:(NSString *)aMessage subText:(NSString *)subText hide:(double)time {
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.labelText = aMessage;
    self.HUD.detailsLabelText = subText;
    if (time > 0) {
        [self.HUD hide:YES afterDelay:time];
    }
}

- (void)dismiss:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}



@end
