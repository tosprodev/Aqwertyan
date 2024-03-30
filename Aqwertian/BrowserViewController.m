//
//  BrowserViewController.m
//  Bridge
//
//  Created by Nathan Ziebart on 1/8/13.
//
//

#import "BrowserViewController.h"
#import "PerformanceViewController.h"

@interface BrowserViewController () {
    IBOutlet UIActivityIndicatorView *loadingIndicator;
    IBOutlet UITextField *textField;
}

- (IBAction)refresh:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)go:(id)sender;

@end

@implementation BrowserViewController

+ (void)presentBrowserWithInitialURL:(NSString *)url {
    BrowserViewController *bvc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Browser"];
    bvc.initialURL = url;
    UIViewController *top = [PerformanceViewController sharedController];
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    [top presentViewController:bvc animated:YES completion:nil];
   // [[TabsController sharedInstance] presentViewController:bvc animated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.initialURL) {
        if ([self.initialURL hasPrefix:@"/var"]) {
             [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.initialURL]]];
        } else {
        textField.text = self.initialURL;
        [self go:nil];
        }
       
    }
}



- (void)dismiss:(id)sender {
    _webView.delegate=nil;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)goForward:(id)sender {
    [_webView goForward];
}

- (void)goBack:(id)sender {
    [_webView goBack];
}

- (void)refresh:(id)sender {
    [_webView reload];
}

- (void)cancel:(id)sender {
    [_webView stopLoading];
}

- (void)go:(id)sender {
    NSString *url = textField.text;
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"file"]) {
        if (![url hasPrefix:@"www."]) {
            url = [@"www." stringByAppendingString:url];
        }
        url = [@"http://" stringByAppendingString:url];
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [loadingIndicator stopAnimating];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    // [[TabsController sharedInstance] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [loadingIndicator stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [loadingIndicator startAnimating];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    //[[TabsController sharedInstance] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
