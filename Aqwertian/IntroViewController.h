//
//  IntroViewController.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 7/1/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>


+ (BOOL) shouldShowIntro;
+ (BOOL) shouldShowWhatsNew;

@end
