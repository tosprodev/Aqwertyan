//
//  MusicDefinedViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/10/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "MusicDefinedViewController.h"

@interface MusicDefinedViewController ()

- (IBAction)dismiss:(id)sender;

@end

@implementation MusicDefinedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

# pragma mark - path
- (BOOL)pathPressed:(int)screen {
    id vc = self.parentViewController;
    if (!vc) vc = self.presentingViewController;
    
    if (screen != USER_GUIDE) {
    double delayInSeconds = 0.7;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [vc pathPressed:screen];
    });
    }
    
    [self dismiss:nil];
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
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

@end
