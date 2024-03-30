//
//  StatsMailer.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/4/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface StatsMailer : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

+ (StatsMailer *) instance;

- (void) showActionSheetFromRect:(CGRect)rect inView:(UIView *)view forScreenshot:(UIView *)screenshotView withFrame:(CGRect)frame forViewController:(UIViewController *)vc;
@end
