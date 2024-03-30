//
//  FlipSegue.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/18/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "FlipSegue.h"
#import <QuartzCore/QuartzCore.h>
#import "StoreViewController.h"
#import "PerformanceViewController.h"
#import "FileSelectViewController.h"
#import "SongOptionsViewController.h"

@implementation FlipSegue
//- (void)perform
//{
//
//        UIViewController *src = (UIViewController *) self.sourceViewController;
//        UIViewController *dst = (UIViewController *) self.destinationViewController;
//        [UIView transitionWithView:src.view duration:0.8 options:UIViewAnimationOptionTransitionFlipFromBottom
//                       animations:^{
//                           [src presentViewController:dst animated:NO completion:nil];
//                       }
//                       completion:NULL];
//    
//}

-(void)perform {
    
    __block UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    __block UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
//    CATransition* transition = [CATransition animation];
//    transition.duration = 1;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
//    
//    
//    
//    [sourceViewController.navigationController.view.layer addAnimation:transition
//                                                                forKey:kCATransition];
//    
//    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
    if ([sourceViewController isKindOfClass:[PerformanceViewController class]]) {
        if ([destinationController isKindOfClass:[SongOptionsViewController class]]) {
            [sourceViewController.view.superview addSubview:destinationController.view];
            [destinationController viewWillAppear:NO];
            CGRect frame = destinationController.view.frame;
            frame.origin = CGPointMake(1024, 0);
            destinationController.view.frame = frame;
            [UIView transitionWithView:sourceViewController.view.superview duration:1 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
                destinationController.view.frame = CGRectMake(0,0,1024,768);
                sourceViewController.view.frame = CGRectMake(-1024,0,1024,768);
            } completion:^(BOOL finished) {
//                [sourceViewController.view setBounds:CGRectMake(0, 0, 1024, 768)];
//                [sourceViewController presentViewController:destinationController animated:NO completion:nil];
            }];
        }
    } else if ([sourceViewController isKindOfClass:[SongOptionsViewController class]]) {
        if ([destinationController isKindOfClass:[PerformanceViewController class]]) {

            [destinationController viewWillAppear:NO];
            [UIView transitionWithView:destinationController.view.window duration:1 options:UIViewAnimationOptionTransitionNone animations:^(void) {
                sourceViewController.view.frame = CGRectMake(1024,0,1024,768);
                destinationController.view.frame = CGRectMake(0,0,1024,768);
               // destinationController.view.frame = CGRectMake(0,-768,1024,768);
            } completion:^(BOOL finished) {
                [sourceViewController.view removeFromSuperview];
            }];
        }
    }
   

    
}

@end