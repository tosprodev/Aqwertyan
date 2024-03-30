//
//  IntroViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 7/1/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "IntroViewController.h"
#import "SMPageControl.h"
#import "AQSwitch.h"
#import "NSObject+NZHelpers.h"

static NSMutableArray *imageNames;
static NSMutableArray *whatsNewImageNames;
static NSString * const DontShowIntroKey = @"DontShowIntro1";
static NSString * const ShowWhatsNewKey = @"ShowWhatsNew1.3_3";
@interface IntroViewController ()

@property IBOutlet UILabel *buttonLabel;
@property IBOutlet UIImageView *backgroundImageView;
@property IBOutlet SMPageControl *pageControl;

- (IBAction)next:(id)sender;

@end

@implementation IntroViewController {
    UIPageViewController *pageViewController;
    NSMutableArray *viewControllers;
    AQSwitch *showAgainSwitch;
}

+ (BOOL) shouldShowIntro {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:DontShowIntroKey] boolValue] == NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self  = [super initWithCoder:aDecoder];
    imageNames = @[@"intro-switchkeyboards", @"intro-qwertymode", @"intro-pianostyle", @"intro-thumbmode", @"intro-fastforward", @"intro-autoplay", @"intro-boostmode", @"intro-arrangement", @"intro-options", @"intro-highlights", @"intro-stats", @"intro-metronome", @"intro-midikeyboard",  @"intro-getmoresongs", @"intro-websearch", @"intro-help", @"intro-userguide", @"intro-bestwithheadphones", @"intro-done"].mutableCopy;
    whatsNewImageNames = @[@"intro-whatsnew13", @"intro-highlights", @"intro-stats", @"intro-metronome", @"intro-midikeyboard"].mutableCopy;
    return self;
}

+ (BOOL)shouldShowWhatsNew {
    return ![NSUserDefaults.standardUserDefaults objectForKey:ShowWhatsNewKey] && ![self shouldShowIntro];
}

- (void) setupViewControllers {
    UIPageViewController *pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    viewControllers = [NSMutableArray new];
    NSArray *names = [IntroViewController shouldShowWhatsNew] ? whatsNewImageNames : imageNames;
    for (NSString *imageName in names) {
        UIViewController *vc = [UIViewController new];
        //vc.view.userInteractionEnabled = NO;
        UIImageView *imageView = [UIImageView new];
        UIImage *image = [UIImage imageNamed:imageName];
        imageView.contentMode = UIViewContentModeTop;
        imageView.image = image;
        if (imageName != [imageNames lastObject]) {
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-paper"]];
            [backgroundImageView sizeToFit];
            [vc.view addSubview:backgroundImageView];
        }
        [vc.view addSubview:imageView];
              [imageView sizeToFit];
        [viewControllers addObject:vc];
    }
    
    if ([IntroViewController shouldShowIntro]) {
        UIViewController *doneVC = [viewControllers lastObject];
        showAgainSwitch = [[AQSwitch alloc] initWithFrame:CGRectMake(393, 429, 100, 100)];
        showAgainSwitch.on = YES;
        [doneVC.view addSubview:showAgainSwitch];
    } else if (![IntroViewController shouldShowWhatsNew]) {
        [viewControllers removeLastObject];
    }
    
    [self.view addSubview:pageVC.view];
    [self.view sendSubviewToBack:pageVC.view];
    [self.view sendSubviewToBack:_backgroundImageView];
    [pageVC.view setFrame:self.view.bounds];
    pageVC.delegate = self;
    pageVC.dataSource = self;
   // pageVC.view.backgroundColor = [UIColor blueColor];
    [pageVC setViewControllers:@[viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    pageViewController = pageVC;
    _pageControl.numberOfPages = viewControllers.count;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController  {
    int index = [viewControllers indexOfObject:viewController];
    if (index == viewControllers.count-1) return nil;
    return viewControllers[index+1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = [viewControllers indexOfObject:viewController];
    if (index == 0) return nil;
    return viewControllers[index-1];
}

- (void)next:(id)sender {
    UIViewController *next = [self pageViewController:pageViewController viewControllerAfterViewController:pageViewController.viewControllers[0]];
    if (next) {
         __weak id weakSelf = self;
        __weak id weakPageVC = pageViewController;
        [pageViewController setViewControllers:@[next] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            if (finished) {
                [weakSelf pageViewController:weakPageVC didFinishAnimating:YES previousViewControllers:nil transitionCompleted:YES];
            }
        }];
    } else {
        if ([IntroViewController shouldShowIntro]) {
            if (!showAgainSwitch.on) {
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:DontShowIntroKey];
            }
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:ShowWhatsNewKey];
        } else if ([IntroViewController shouldShowWhatsNew]) {
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:ShowWhatsNewKey];
        }
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void) {
            [self triggerEvent:@"IntroDismissed" withArgs:nil];
        }];
        
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
                int index = [viewControllers indexOfObject:pageViewController.viewControllers[0]];
    if (completed) {
        if (index == viewControllers.count - 1) {
            _buttonLabel.text = @"DONE";
        } else {
            _buttonLabel.text = @"NEXT";
        }
    }
    _pageControl.currentPage = index;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [_pageControl setPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
	[_pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];
        [self setupViewControllers];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
