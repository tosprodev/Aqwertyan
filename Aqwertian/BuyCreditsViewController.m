//
//  BuyCreditsViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "BuyCreditsViewController.h"
#import "StoreViewController.h"
#import "CreditsManager.h"

BuyCreditsViewController *theBuyCreditsController;

@interface BuyCreditsViewController ()

- (IBAction)dismiss:(id)sender;
- (IBAction)buttonTapped:(id)sender;

@end

@implementation BuyCreditsViewController

////
# pragma mark - STATIC CLASS METHODS
//

+ (BuyCreditsViewController *)sharedController {
    return theBuyCreditsController;
}


////
# pragma mark - INIT
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        theBuyCreditsController = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    theBuyCreditsController = self;
    return self;
}


////
# pragma mark - VIEW CONTROLLER
//

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood"]]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


////
# pragma mark - BUTTONS
//

- (void)dismiss:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
    [[StoreViewController sharedController] updateCredits];
}

- (void)buttonTapped:(id)sender {
    UIButton *theButton = (UIButton *)sender;
    [self showLoadingHUD:@"Processing your purchase" subText:nil];
    [[CreditsManager sharedManager] buyCredits:theButton.tag withCallback:^(BOOL success) {
        [self hideHUD:0];
        if (success) {
            [self showAlertWithTitle:@"Success!" message:@"Your credits have been added."];
        }
    }];
}

@end
