//
//  MidiWebViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/13/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "MidiWebViewController.h"
#import "Util.h"
#import "StoreViewController.h"
#import "NZURLRequest.h"
#import "MBProgressHUD.h"
#import "SSZipArchive.h"
#import "AudioPlayer.h"

@interface MidiWebViewController () {
    IBOutlet UIWebView *webView;
    IBOutlet UITextField *textField;
    IBOutlet UISegmentedControl *segControl;
    NSURLConnection *theConnection;
    MBProgressHUD *theHUD;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    NSString *path;
    UIBarButtonItem *stopButton;
    IBOutlet UIToolbar *toolbar;
}

- (IBAction)switchSite:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)startLoad:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)stopPlaying:(id)sender;
- (IBAction)addFavorite:(id)sender;

@end

@implementation MidiWebViewController {
    NSString *title;
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
    segControl.selectedSegmentIndex = 1;
    [self switchSite:segControl];
    title = @"Untitled";
    //[segControl setWidth:0 forSegmentAtIndex:segControl.numberOfSegments-1];
}

- (void) stopPlaying:(id)sender {
    [[AudioPlayer sharedPlayer] stopPlaying];
    [[StoreViewController sharedController] songDidStop];
    if (textField.frame.size.width == 668) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect frame = textField.frame;
        frame.size.width = 723;
        textField.frame = frame;
        activityIndicator.center = CGPointMake(activityIndicator.center.x + (723 - 668), activityIndicator.center.y);
        [UIView commitAnimations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NZEvents startTimedFlurryEvent:@"Midi web search opened"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AudioPlayer sharedPlayer] stopPlaying];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
     [NZEvents stopTimedFlurryEvent:@"Midi web search opened"];
}



////
# pragma mark - IBACTIONS
//

- (void)switchSite:(id)sender {
    NSString *url;
    int index = segControl.selectedSegmentIndex;
    if (index == 0) {
        url = @"http://www.google.com";
        [NZEvents logEvent:@"Web search tab selected" args:@{@"URL" : url}];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else if (index == 1) {
        url = @"http://aqwertyan.com/midisites.html";
        [NZEvents logEvent:@"Web search tab selected" args:@{@"URL" : url}];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else if (index == 2) {
        [self showFavorites];
    } 
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [segControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    });
    
}

- (void) showFavorites {
    [webView loadHTMLString:[self getFavoritesHtml] baseURL:nil];
}

- (void)cancel:(id)sender {
    if (theHUD) {
        [theHUD hide:YES];
        [theConnection cancel];
    }
}

- (void)startLoad:(id)sender {
    NSString *url = textField.text;
    if (![url hasPrefix:@"http://"]) {
        if (![url hasPrefix:@"www."]) {
            url = [@"www." stringByAppendingString:url];
        }
        url = [@"http://" stringByAppendingString:url];
    }
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)close:(id)sender {
    if ([self parentViewController]) {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) removeFavoriteWithUrl:(NSString *)url {
    NSMutableArray *favorites = [self getFavorites].mutableCopy;
    for (int i = 0; i < favorites.count ;i++) {
        NSDictionary *favorite = favorites[i];
        if ([favorite[@"URL"] isEqualToString:url]) {
            [favorites removeObjectAtIndex:i];
            [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"Web-Favorites"];
            return;
        }
    }
}

////
# pragma mark - WEB VIEW DELEGATE
//

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
   // [[[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   // NSLog(@"title - %@", [webView stringByEvaluatingJavaScriptFromString:@"document.title"]);
    NSString *urlString = request.URL.absoluteString;
    NSRange range = [urlString rangeOfString:@"delete_favorite_aqw?"];
    if (range.location != NSNotFound) {
        NSString *urlToDelete = [urlString substringFromIndex:range.location + range.length];
        [self removeFavoriteWithUrl:urlToDelete];
        [self performSelector:@selector(showFavorites) withObject:nil afterDelay:0.1];
        return NO;
    }
    textField.text = urlString;
   urlString = urlString.lowercaseString;
    if ([urlString hasSuffix:@".mid"] || [urlString hasSuffix:@".midi"] || [urlString hasSuffix:@".zip"] || [urlString hasSuffix:@".kar"] || [urlString rangeOfString:@"forcedownload.cgi"].location != NSNotFound || [urlString hasSuffix:@"download.php"]) {
        NSString *url = [[request URL] absoluteString];
        theHUD = [MBProgressHUD showHUDAddedTo:webView animated:YES];
        [theHUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)]];
        theHUD.labelText = @"Downloading MIDI";
        theHUD.detailsLabelText = @"Tap to cancel";
        
        theConnection = [NZURLConnection sendAsynchronousRequest:request.mutableCopy completionHandler:^(BOOL success, NSData *data) {
            NSString *newPath;
            if ([urlString rangeOfString:@"forcedownload.cgi"].location != NSNotFound) {
                NSString *theTitle =[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
                theTitle = [[theTitle stringByReplacingOccurrencesOfString:@"MIDI" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                theTitle = [theTitle stringByReplacingOccurrencesOfString:@"download.php" withString:@""];
                if (!theTitle.length) {
                    static NSDateFormatter *formatter;
                    if (!formatter) {
                        formatter = [[NSDateFormatter alloc] init];
                        formatter.dateFormat = @"MMM dd, yyyy - HH:mm";
                    }
                    theTitle = [formatter stringFromDate:NSDate.date];
                }
                newPath = [[[Util documentsDirectory] stringByAppendingPathComponent:theTitle] stringByAppendingPathExtension:@"mid"];
            } else if ([urlString hasSuffix:@"download.php"]) {
                newPath = [[[Util documentsDirectory] stringByAppendingPathComponent:title] stringByAppendingPathExtension:@"mid"];
            } else if ([[[request URL] absoluteString].lowercaseString hasSuffix:@".zip"]) {
                NSString *tmpPath = [[Util tempFilesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d%d", arc4random(), arc4random()]];
                success = [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
                NSString *zipPath = [[Util tempFilesDirectory] stringByAppendingPathComponent:@"zip"];
                if (success && [data writeToFile:zipPath atomically:NO] && [SSZipArchive unzipFileAtPath:zipPath toDestination:tmpPath]) {
                    NSArray *files = [Util allFilesAtPath:tmpPath];
                    int found = 0;
                    for (NSString *file in files) {
                        
                        if ([[file lowercaseString] hasSuffix:@"mid"] || [file.lowercaseString hasSuffix:@"kar"]) {
                            newPath = [[Util documentsDirectory] stringByAppendingPathComponent:[file lastPathComponent]];
                            newPath = [[newPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mid"];
                           
                            if ([[NSFileManager defaultManager] moveItemAtPath:[tmpPath stringByAppendingPathComponent:file] toPath:newPath error:nil]) {
                                found++;
                            }
                        }
                    }
                    if (found) {
                        NSString *message;
                        if (found > 1) {
                            message = @"Multiple files were added to the store.";
                            [[[UIAlertView alloc] initWithTitle:@"Download Complete" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

                        } else {
                            message = [NSString stringWithFormat:@"%@ has been downloaded!", [[newPath lastPathComponent] stringByDeletingPathExtension]];
                            [[[UIAlertView alloc] initWithTitle:@"Download Complete" message:message delegate:self cancelButtonTitle:nil otherButtonTitles: @"Add to Store",@"Listen",  nil] show];

                        }
                        path = newPath;
                        [NZEvents logEvent:@"Song downloaded from web search"];
                        [theHUD hide:YES];
                    } else {
                        [theHUD setMode:MBProgressHUDModeText];
                        [theHUD setDetailsLabelText:@"There was a problem downloading the file"];
                        [theHUD setLabelText:@"Error"];
                        [theHUD hide:YES afterDelay:2];
                    }
                } else {
                    [theHUD setMode:MBProgressHUDModeText];
                    [theHUD setDetailsLabelText:@"There was a problem downloading the file"];
                    [theHUD setLabelText:@"Error"];
                    [theHUD hide:YES afterDelay:2];
                }
                [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
                return;
            } else {
                newPath = [[Util documentsDirectory] stringByAppendingPathComponent:[url lastPathComponent]];
                newPath = [[newPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mid"];
            }
            newPath = [newPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            if (!success || ![data writeToFile:newPath atomically:NO]) {
                [theHUD setMode:MBProgressHUDModeText];
                [theHUD setDetailsLabelText:@"There was a problem downloading the file"];
                [theHUD setLabelText:@"Error"];
                [theHUD hide:YES afterDelay:2];
            } else {
                NSString *message;
                    message = [NSString stringWithFormat:@"%@ has been downloaded!", [[newPath lastPathComponent] stringByDeletingPathExtension]];
                [[[UIAlertView alloc] initWithTitle:@"Download Complete" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:  @"Add to Store",@"Listen", nil] show];
                 path = newPath;
                [theHUD hide:YES];
                [NZEvents logEvent:@"Song downloaded from web search"];
            }
        }];
        return NO;
    } else if ([urlString hasPrefix:@"http://www.electrofresh.com"] && [urlString rangeOfString:@"download-"].location != NSNotFound) {
        title = [[urlString componentsSeparatedByString:@"download-"] lastObject];
        title = [[title substringToIndex:[title rangeOfString:@".htm"].location] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    }
    
    return YES;
}

- (void)addFavorite:(id)sender {
    if (textField.text.length == 0) return;
    NSString *title =[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if ([title isEqualToString:@"Aqw-Favorites"]) return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Favorite" message:@"Choose a name for this site" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.tag = 10;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = title;
    [alert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSong:) object:nil];
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex].lowercaseString;
    if ([buttonTitle isEqualToString:@"listen"]) {
        if ([AudioPlayer sharedPlayer].isPlaying) {
            [[AudioPlayer sharedPlayer] stopPlaying];
            [self performSelector:@selector(playSong:) withObject:path afterDelay:1];
        } else {
            [self playSong:path];
        }
        [self showKeepOrDiscardAlert];
    } else if ([buttonTitle isEqualToString:@"add to store"]) {
        [[AudioPlayer sharedPlayer] stopPlaying];
        [self showRenameAlert];
    } else if ([buttonTitle isEqualToString:@"discard"]) {
        [[AudioPlayer sharedPlayer] stopPlaying];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    } else if ([buttonTitle isEqualToString:@"save"]) {
        if (alertView.tag == 10) {
            [self saveFavorite:[alertView textFieldAtIndex:0].text];
        } else {
        NSString *newTitle = [alertView textFieldAtIndex:0].text;
        newTitle = [self sanitizeFileNameString:newTitle];
        NSString *newPath = [[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newTitle] stringByAppendingPathExtension:@"mid"];
        if (![newPath isEqualToString:path]) {
            [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:nil];
        }
        }
    }
}

- (void) saveFavorite:(NSString *)title {
   NSString *url = webView.request.URL.absoluteString;
    NSDictionary *favorite = @{@"Title" : title, @"URL" : url};
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"Web-Favorites"];
    if (!favorites) {
        favorites = @[];
    }
    NSMutableArray *mutableFavorites = favorites.mutableCopy;
    [mutableFavorites addObject:favorite];
    [[NSUserDefaults standardUserDefaults] setObject:mutableFavorites forKey:@"Web-Favorites"];
}

- (NSString *) getFavoritesHtml {
    NSArray *favorites = [self getFavorites];
    if (favorites.count == 0) {
        return @"<html><h1>You don't have any favorites saved.</h1></html>";
    } else {
        NSMutableString *html = [NSMutableString new];
        [html appendString:@"<html>"];
        [html appendString:@"<head> \
         <title>Aqw-Favorites</title> \
         <style> \
         table, td, th \
        { \
        border:1px solid black; \
        } \
         </style> \
         </head>"];
        [html appendString:@"<h1>Favorites</h1>"];
        [html appendString:@"<table cellpadding=\"5\">"];
        for (NSDictionary *favorite in favorites) {
            [html appendFormat:@"<tr><td><a href=%@>%@</a></td><td><a href=delete_favorite_aqw?%@>Delete</a></td></tr>", favorite[@"URL"], favorite[@"Title"], favorite[@"URL"]];
        }
        [html appendString:@"</table>"];
        [html appendString:@"</html>"];
        return html;
    }
}

- (NSArray *) getFavorites {
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"Web-Favorites"];
    if (!favorites) {
        favorites = @[];
    }
    return favorites;
}

- (NSString *)sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

- (void) showRenameAlert {
    NSString *songTitle = [[path lastPathComponent] stringByDeletingPathExtension];
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Rename" message:[NSString stringWithFormat:@"If you would like, enter a new name for %@", songTitle] delegate:self cancelButtonTitle:@"Keep Name" otherButtonTitles:@"Save", nil];
    
    theAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [theAlert textFieldAtIndex:0].text = songTitle;
 //   [[theAlert textFieldAtIndex:0] selectAll:self];
    [theAlert show];
}

- (void) showKeepOrDiscardAlert {
    [[[UIAlertView alloc] initWithTitle:@"Playing.." message:@"Do you want to keep this song?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Discard", @"Add to Store",  nil] show];
}

- (void) playSong:(NSString *)aPath {
    [[AudioPlayer sharedPlayer] setMidiFile:aPath];
    unsigned long totalTicks;
    unsigned short division;
    [[AudioPlayer sharedPlayer] getInfo:&totalTicks dvision:&division];
    
    if (totalTicks == 0 || division == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"This midi file is invalid" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [[AudioPlayer sharedPlayer] startPlaying];
 //   [[StoreViewController sharedController] newSongDidStart];
//    if (textField.frame.size.width == 723) {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.3];
//        CGRect frame = textField.frame;
//        frame.size.width = 668;
//        textField.frame = frame;
//        activityIndicator.center = CGPointMake(activityIndicator.center.x - (723 - 668), activityIndicator.center.y);
//        [UIView commitAnimations];
//    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicator stopAnimating];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}

@end
