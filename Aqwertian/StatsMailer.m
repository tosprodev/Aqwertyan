//
//  StatsMailer.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/4/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "StatsMailer.h"
#import <MessageUI/MessageUI.h>
#import "NZEvents.h"
#import "SongOptions.h"
#import "Util.h"
#import "AudioPlayer.h"
#import <Social/Social.h>

@implementation StatsMailer {
    UIActionSheet *actionSheet;
    UIView *screenshot;
    UIViewController  *viewController;
    CGRect screenFrame;
}

+ (StatsMailer *)instance {
    static StatsMailer *mailer;
    if (!mailer) {
        mailer = [StatsMailer new];
    }
    return mailer;
}

- (void) showActionSheetFromRect:(CGRect)rect inView:(UIView *)view forScreenshot:(UIView *)screenshotView withFrame:(CGRect)frame forViewController:(UIViewController *)vc {
    screenFrame = frame;
    screenshot = screenshotView;
    viewController = vc;
    actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                              delegate: self
                                     cancelButtonTitle: nil
                                destructiveButtonTitle: nil
                                     otherButtonTitles: @"Email", @"Twitter", @"Facebook", nil];
    
    
    
    
    [actionSheet showFromRect: rect inView:view animated: YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == -1) return;
    
    [NZEvents logEvent:@"Performance score shared on social network" args:@{@"Type" : buttonIndex == 0 ? @"Email" : (buttonIndex == 1 ? @"Twitter" : @"Facebook")}];
    if (buttonIndex == 0) {
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *title = [SongOptions CurrentItem].Title; //componentsSeparatedByString:@" ("][0];
            
            Statistics *s = [[SongOptions currentStats] count] ? [SongOptions currentStats][0] : nil;
            NSString *message;
            
            if (s) {
                float totalNotes = s.skippedNotes + s.rightNotes;
                float accuracy = 100.0 * (float)(s.rightNotes) / (float)(s.rightNotes +s.wrongNotes);
                float onTime = 100.0 * (float)s.notesPlayedOnTime / totalNotes;
                
                // if ([SongOptions isExmatch]) {
                message = [NSString stringWithFormat:@"I just scored %d on %@!", s.totalScore, title];
                //    } else {
                //      message = [NSString stringWithFormat:@"I just played %@!<br />Tempo Accuracy: %d%%", title, (int)(onTime+0.5)];
                //  }
            } else {
                title = message = [NSString stringWithFormat:@"I just played %@!", title];
            }
            
            LibraryItem *item = [SongOptions CurrentItem];
            item.Arrangement.fileData = [NSData dataWithContentsOfFile:[[Util uploadedSongsDirectory] stringByAppendingPathComponent:item.Arrangement.MidiFile]];
            
            
            NSMutableDictionary *dict = [item toDictionary].mutableCopy;
            dict[@"Jukebox"] = @(NO);
            dict[@"Favorite"] = @(NO);
            if (item.Type != LibraryItemTypeArrangement) {
                dict[@"Title"] = [item.Title stringByAppendingFormat:@" (%@)", [[AudioPlayer sharedPlayer] getCurrentProgram:[SongOptions activeChannel]]];
                dict[@"Type"] = @(LibraryItemTypeArrangement);
            }
            
            NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * fileName = [item.Title stringByAppendingString:@".aqw"];
            
            
            
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            [mailer addAttachmentData:data mimeType:@"application/octet-stream" fileName:fileName];
            [mailer setSubject:[NSString stringWithFormat:@"Check out my performance stats for %@", [SongOptions CurrentItem].Title]];
            
            
            NSString *emailBody = [message stringByAppendingString:@"<br /><br /><a href=\"http://itunes.apple.com/app/id584106288\">Aqwertyan for iPad</a>"];

            UIImage *image = [self snapshotFromView:screenshot];
            image = [self cropImage:image toRect:screenFrame];
            NSData *imageData = UIImagePNGRepresentation(image);
            
            
            [mailer  addAttachmentData:imageData mimeType:@"image/png" fileName:@"Screenshot"];
            [mailer setMessageBody:emailBody isHTML:YES];
            [viewController presentViewController:mailer animated:YES completion:nil];
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
    } else {
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:buttonIndex == 1 ? SLServiceTypeTwitter : SLServiceTypeFacebook];
        // Configure Compose View Controller
        NSString *title = [SongOptions CurrentItem].Title; //componentsSeparatedByString:@" ("][0];
        
        Statistics *s = [[SongOptions currentStats] count] ? [SongOptions currentStats][0] : nil;
        NSString *message;
        
        if (s) {
            float totalNotes = s.skippedNotes + s.rightNotes;
            float accuracy = 100.0 * (float)(s.rightNotes) / (float)(s.rightNotes +s.wrongNotes);
            float onTime = 100.0 * (float)s.notesPlayedOnTime / totalNotes;
            
            message = [NSString stringWithFormat:@"I just scored %d %@!\nAqwertyan for iPad!", s.totalScore, title];

//            if ([SongOptions isExmatch]) {
//                message = [NSString stringWithFormat:@"I just played %@ with %d%% correct notes and %d%% on time.\nAqwertyan for iPad!", title, (int)accuracy, (int)onTime];
//            } else {
//                message = [NSString stringWithFormat:@"I just played %@ with %d%% tempo accuracy on Aqwertyan for iPad!", title, (int)(onTime+0.5)];
//            }
        } else {
            title = message = [NSString stringWithFormat:@"I just played %@ on Aqwertyan for iPad!", title];
        }
        
        [vc setInitialText:message];
        
        // [vc setInitialText:[NSString stringWithFormat:@"I'm playing %@ on Aqwertyan for iPad!", title]];
        [vc addURL:[NSURL URLWithString:@"http://www.aqwertyan.com"]];
        
        // Present Compose View Controller
        [viewController presentViewController:vc animated:YES completion:nil];
    }
    
}

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)frame {
    if (CGRectEqualToRect(CGRectZero, frame)) return image;
    frame.origin.x *= 2;
    frame.origin.y *= 2;
    frame.size.width *= 2;
    frame.size.height *= 2;
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImage;
}

- (UIImage *)snapshotFromView:(UIView *)view
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    CGSize size = view.bounds.size;
    if (size.width == 768) size.width = 1024;
    if (size.height == 1024) size.height = 768;

    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the window's anchor point
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    // Apply the window's transform about the anchor point
    CGContextConcatCTM(context, [view transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    
    // Render the layer hierarchy to the current context
    [[view layer] renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    return image;
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
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
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


@end
