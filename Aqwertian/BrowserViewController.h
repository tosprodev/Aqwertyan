//
//  BrowserViewController.h
//  Bridge
//
//  Created by Nathan Ziebart on 1/8/13.
//
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (strong) IBOutlet UIWebView *webView;
@property (copy) NSString *initialURL;

+ (void) presentBrowserWithInitialURL:(NSString *)url;

@end
