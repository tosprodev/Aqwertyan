//
//  LikeViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/15/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "LikeViewController.h"
#import "FileSelectViewController.h"
#import "CreditsManager.h"

@interface LikeViewController ()

@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) IBOutlet UILabel *pleaseLabel;

- (IBAction)noThanks:(id)sender;

@end

@implementation LikeViewController {
    BOOL loggedIn;
    CFTimeInterval startTime;
    NSTimer *timer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _webView.delegate=self;
    startTime = CACurrentMediaTime();
    [self showLikeView];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    });
    
   
}

- (void) showLikeView {
     [_webView loadHTMLString:@"<html><head><style>.itm{ width:200; height:258;position:absolute; left:50%; top:50%; margin:-150px 0 0 -100px;}</style></head><body><div class=\"itm\"><iframe id=\"iframe01\" src=\"http://www.facebook.com/plugins/likebox.php?href=https%3A%2F%2Fwww.facebook.com%2Fpages%2FAqwertyan%2F516841201707482%3Ffref%3Dts&amp;width=200&amp;height=258&amp;show_faces=true&amp;colorscheme=light&amp;stream=false&amp;border_color&amp;header=false\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; width:200px; height:258px;\" allowTransparency\"true\"></iframe></div></body></html>" baseURL:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //[self showAlertWithTitle:@"Error" message:error.description];
    
}

- (BOOL) checkIfLiked {
    NSString *jsString = @"window.frames['iframe01'].document.body.innerHTML";
    NSString *text = [_webView stringByEvaluatingJavaScriptFromString:jsString];
    if ([text rangeOfString:@"<span class=\"\" id=\"u_0_3\">You and"].location != NSNotFound || [text rangeOfString:@"<span id=\"u_0_3\">You and"].location != NSNotFound) {
        return YES;
    }
    return NO;

}

- (void) tick {
    if ([self checkIfLiked]) {
        NSLog(@"liked");
        [[CreditsManager sharedManager] addCredits:1];
        [self showAlertWithTitle:@"Thanks!" message:[NSString stringWithFormat:@"You now have %d Qwerty%@!",
                                                     [CreditsManager sharedManager].numberOfCredits,
                                                     ([CreditsManager sharedManager].numberOfCredits == 1 ? @"" : @"s")]];
        [[NSUserDefaults standardUserDefaults] setObject:LIKED_KEY forKey:LIKED_KEY];
        [[FileSelectViewController sharedController] hideLikeButton];
        if (_pleaseLabel.alpha) [self hideLabel];
        [timer invalidate];
    }
    
}

- (void)noThanks:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:LIKED_KEY forKey:LIKED_KEY];
    [[FileSelectViewController sharedController] hideLikeButton];
    [self dismiss:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString rangeOfString:@"close_popup"].location != NSNotFound) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showLikeView];
        });
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"event"]) {
        if ([request.URL.resourceSpecifier isEqualToString:@"edge.create"]) {
            NSLog(@"liked");
            [self showMessageHUD:@"Thank you!" subText:@"You're awesome." hide:2];
            self.HUD.userInteractionEnabled=NO;
            [[NSUserDefaults standardUserDefaults] setObject:LIKED_KEY forKey:LIKED_KEY];
            [[FileSelectViewController sharedController] hideLikeButton];
            [self hideLabel];
            
            return YES;
        }
    }
    if ([request.URL.path isEqualToString:@"/dialog/plugin.optin"] ||
        ([request.URL.path isEqualToString:@"/plugins/like/connect"] && [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] hasPrefix:@"lsd"])) {
        
        if (!loggedIn) {
//        [self showMessageHUD:@"Please Log In" subText:@"We greatly appreciate it!" hide:2];
//        self.HUD.detailsLabelFont = [UIFont fontWithName:@"Futura-Medium" size:16];
//        self.HUD.labelFont = [UIFont fontWithName:@"Futura-Medium" size:20];
//        self.HUD.userInteractionEnabled = NO;
            loggedIn = YES;
        }
    }
    //NSLog(@"%@", request.URL.absoluteString);
    if (CACurrentMediaTime() - startTime > 2 && _pleaseLabel.alpha) {
        [self hideLabel];
    }
    return YES;
}

- (void) hideLabel {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.65];
    _pleaseLabel.alpha = 0;
    [UIView commitAnimations];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicator stopAnimating];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
