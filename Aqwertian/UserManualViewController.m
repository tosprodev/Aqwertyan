//
//  UserManualViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 4/7/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "UserManualViewController.h"
#import <MessageUI/MessageUI.h>
#import "PerformanceViewController.h"
#import "TitleCell.h"
#import "SectionCell.h"
#import "BrowserViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NZEvents.h"
#import "PerformanceViewController.h"

@interface UserManualViewController ()

- (IBAction)emailTapped:(id)sender;
- (IBAction)showVideo:(id)sender;

@property (nonatomic) IBOutlet UIButton *emailButton;
@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIImageView *overlayView;
@property (nonatomic) IBOutlet UIView *backButtonView;

- (IBAction)back:(id)sender;
@end

@implementation UserManualViewController {
    NSArray *sections;
    NSDictionary *titles;
    int selectedSection;
}

- (void)showVideo:(id)sender {
    [self performSegueWithIdentifier:@"Intro" sender:nil];
    [NZEvents logEvent:@"Slides opened from user guide"];
    
//    MPMoviePlayerViewController *player =
//    [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://www.aqwertyan.com/scripts/UserGuide.mov"]];
//   // player.moviePlayer.movieSourceType = MPMovieSourceTypeUnknown;
//    
//    // [player.view setFrame: self.view.bounds];  // player's frame must match parent's
//    // [self.view addSubview: player.view];
//    // ...
//    // NSLog(@"%d",(int)player.readyForDisplay);
//    [player.moviePlayer prepareToPlay];
//    [self presentMoviePlayerViewControllerAnimated:player];
//    [NZEvents logEvent:@"User manual video opened"];
   // [player.moviePlayer play];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)back:(id)sender {
    [self hideOverlay];
}

- (void)emailTapped:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"Aqwertyan Feedback"]];
                NSArray *toRecipients = [NSArray arrayWithObjects:@"nathan@aqwertyan.com", @"jim@aqwertyan.com", nil];
                [mailer setToRecipients:toRecipients];
        //   UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
        //  NSData *imageData = UIImagePNGRepresentation(myImage);
        //[mailer addAttachmentData:data mimeType:@"application/octet-stream" fileName:fileName];
       // NSString *emailBody = @"Tap on the file to open it in Aqwertyan. Don't have Aqwertyan? Download it <a href=\"itms-apps://itunes.com/apps/Chrome\">HERE</a>";
       // [mailer setMessageBody:emailBody isHTML:YES];
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Your device doesn't support sending email from within the app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}
         
         - (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
        {
            switch (result)
            {
                case MFMailComposeResultCancelled:
                    NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
                    break;
                case MFMailComposeResultSaved:
                    NSLog(@"Mail saved: you saved the email message in the drafts folder.");
                    break;
                case MFMailComposeResultSent:
                    NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
                    break;
                case MFMailComposeResultFailed:
                    NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
                    break;
                default:
                    NSLog(@"Mail not sent.");
                    break;
            }
            // Remove the mail view
            [self dismissModalViewControllerAnimated:YES];
        }

# pragma mark - path
- (BOOL)pathPressed:(int)screen {
    switch (screen) {
        case PERFORMANCE:
            [[PerformanceViewController sharedController] dismissGuide];
            break;
        case OPTIONS:
            [[PerformanceViewController sharedController] dismissGuide];
            [[PerformanceViewController sharedController] performSelector:@selector(showOptions) withObject:nil afterDelay:0.75];
            break;
        case ARRANGEMENT:
            [[PerformanceViewController sharedController] dismissGuide];
            [[PerformanceViewController sharedController] performSelector:@selector(showSongOptions) withObject:nil afterDelay:0.75];
            break;
        case STORE:
            [[PerformanceViewController sharedController] dismissGuide];
            [[PerformanceViewController sharedController] performSelector:@selector(showStore) withObject:nil afterDelay:0.75];
            break;
        case LIBRARY:
            [[PerformanceViewController sharedController] dismissGuide];
            [[PerformanceViewController sharedController] performSelector:@selector(showLibrary) withObject:nil afterDelay:0.75];
            break;
        case INSTRUMENTS:
            [[PerformanceViewController sharedController] dismissGuide];
            [[PerformanceViewController sharedController] performSelector:@selector(showInstruments) withObject:nil afterDelay:0.75];
            break;
        case COLLAB:
            return NO;
            break;
        case USER_GUIDE:
            return NO;
            break;
            
        default:
            return nil;
            break;
    }
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void) showTeam {
    _overlayView.alpha = 0;
    _overlayView.image = [UIImage imageNamed:@"team-cropped"];
    [self showOverlay];
}

- (void) showDefined {
    _overlayView.alpha = 0;
    _overlayView.image = [UIImage imageNamed:@"defined-cropped"];
    [self showOverlay];
}

- (void) showOverlay {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    _overlayView.alpha = 1;
    _backButtonView.alpha = 1;
    _backButtonView.userInteractionEnabled=YES;
    [UIView commitAnimations];
}

- (void) hideOverlay {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    _overlayView.alpha = 0;
    _backButtonView.alpha = 0;
    _backButtonView.userInteractionEnabled=NO;
    [UIView commitAnimations];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedSection = -1;
    _webView.delegate = self;
    _backButtonView.alpha = 0;
    _backButtonView.hidden = NO;
    titles = @{@"FAQ" : @[@"ADJUSTING PERFORMANCE DIFFICULTY", @"FINDING & ADDING NEW SONGS", @"PIANO VIBRATO", @"USING EXTERNAL MIDI INSTRUMENTS", @"KARAOKE MICROPHONE", @"BLUETOOTH KEYBOARDS"],
               @"ABOUT" : @[@"AQWERTYAN DEFINED", @"FOUNDATION OF AQWERTYAN", @"AQWERTYAN TEAM"],
               @"LEGAL" : @[@"MUSIC LICENSE", @"INTELLECTUAL PROPERTY", @"POLICY ON VIRTUAL CURRENCY", @"MUSIC INDUSTRY",@"PRIVACY POLICY", @"COPYRIGHT INFO"],
               @"MUSIC EDUCATION" : @[@"MUSIC EDUCATION", @"MARCHING BAND SUPPORT"]
               };
    
    sections = @[@"FAQ",@"ABOUT", @"LEGAL", @"MUSIC EDUCATION"];
    
//    id scrollview = [_webView.subviews objectAtIndex:0];
//    for (UIView *subview in [scrollview subviews])
//        if ([subview isKindOfClass:[UIImageView class]])
//            subview.hidden = YES;
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NZEvents startTimedFlurryEvent:@"User Manual screen opened"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NZEvents stopTimedFlurryEvent:@"User Manual screen opened"];
}

- (NSString *) titleForRow:(int)row isSection:(BOOL *)isSection {
    int title = -1;
    int section = 0;
    int count = 0;
    BOOL _section = YES;
    while (count < row) {
        if (section == selectedSection && title + 1 < [titles[sections[section]] count]) {
            title++;
            _section = NO;
        } else {
            section++;
            _section = YES;
            title = -1;
        }
        count++;
    }
    if (isSection) {
        *isSection = _section;
    }
    if (_section) {
        return sections[section];
    }
    return titles[sections[section]][title];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSection;
    NSString *text = [self titleForRow:indexPath.row isSection:&isSection];
    if (isSection) {
        SectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"section"];
        cell.textLabel.text = text;
        return cell;
    } else {
        TitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
        cell.textLabel.text = text;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int total = sections.count;
    if (selectedSection > -1) {
        total += [titles[sections[selectedSection]] count];
    }
    return total;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL section;
    NSString *title = [self titleForRow:indexPath.row isSection:&section];
    if (section) {
        
       
        
        int newSection = [sections indexOfObject:title];
        
        
        if (newSection == selectedSection) return;
        
        NSMutableArray *toRemove = [NSMutableArray new];
        int i = 1;
        if (selectedSection > -1) {
        for (NSString *title in titles[sections[selectedSection]]) {
            [toRemove addObject:[NSIndexPath indexPathForRow:selectedSection + i++ inSection:0]];
        }
        }
        
        [_tableView beginUpdates];
        selectedSection = -1;
        [_tableView deleteRowsAtIndexPaths:toRemove withRowAnimation:UITableViewRowAnimationFade];
        
        selectedSection = newSection;
        i = 1;
        NSMutableArray *toAdd = [NSMutableArray new];
        for (NSString *title in titles[sections[selectedSection]]) {
            [toAdd addObject:[NSIndexPath indexPathForRow:selectedSection + i++ inSection:0]];
        }
  
        [_tableView insertRowsAtIndexPaths:toAdd withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        
       
        
       // [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        if ([title isEqualToString:@"EXAMPLE"]) return;
        if ([title isEqualToString:@"AQWERTYAN DEFINED"]) {
            [_webView loadHTMLString:@"" baseURL:nil];
           // [self performSegueWithIdentifier:@"MusicDefined" sender:nil];
            [self showDefined];
            return;
        } else if ([title isEqualToString:@"QUESTIONS & SUGGESTIONS"]) {
            [BrowserViewController presentBrowserWithInitialURL:[[NSBundle mainBundle] pathForResource:@"Beta" ofType:@"pdf"]];
            return;
        } else if ([title isEqualToString:@"AQWERTYAN TEAM"]) {
            [_webView loadHTMLString:@"" baseURL:nil];
            [self showTeam];
            return;
        } else if ([title isEqualToString:@"MUSIC LICENSE"] || [title isEqualToString:@"PIANO VIBRATO"] || [title isEqualToString:@"MARCHING BAND SUPPORT"] || [title hasPrefix:@"USING EXTERNAL"]) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:title ofType:@"webarchive"];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:fileURL];
            [_webView loadRequest:requestObj];
            return;
        } else if ([title isEqualToString:@"KARAOKE MICROPHONE"]) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:title ofType:@"webarchive"];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:fileURL];
            [_webView loadRequest:requestObj];
            return;
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:title ofType:@"html"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:fileURL];
        [_webView loadRequest:requestObj];
    }
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (![request.URL isFileURL]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView    {
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
