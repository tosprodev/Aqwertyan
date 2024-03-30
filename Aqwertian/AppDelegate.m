//
//  AppDelegate.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/2/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "AppDelegate.h"
#import "LibraryManager.h"
#import "Util.h"
#import "CreditsManager.h"
#import "FileSelectViewController.h"
#import "AudioPlayer.h"
#import "PerformanceViewController.h"
#import "Appirater.h"
#import "NZInputHandler.h"
#import "StoreViewController.h"
#import "TestFlight.h"
#import "NZEvents.h"
#import "FingeringTest.h"
#import "OverlayView.h"
@implementation AppDelegate {
    NSMutableDictionary *alerts;
}

#define FIRST_LAUNCH_KEY @"FirstTimeLaunched"

void uncaughtExceptionHandler(NSException *exception)
{
    [NZEvents logCrash:@"Crash" exception:exception];
}
 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
  //  [[FingeringTest new] doTests];
   // [[FingeringTest new] jimTest];
    
   // NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    alerts = [NSMutableDictionary new];
    [Util initialize];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:DONT_SHOW_QUICK_START_KEY]) {
    
    }
    
    [OverlayView initialize];
    
 //   [TestFlight takeOff:@"c07a30bb-0b31-4f0f-8e00-f615183daee0"];
    
   // NSLog([NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.justmidis.com/00-MIDI/2/000000004743/Bomb%20omb%20Battlefield"] encoding:NSUTF8StringEncoding error:nil]);
   // NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    [self loadDefaultSongs];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"Futura-Medium" size:18]];
    [Appirater setAppId:@"584106288"];
   //  [self handleNewFile:url];
  //  [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:FIRST_LAUNCH_KEY]) {
        [[NSUserDefaults standardUserDefaults] setObject:FIRST_LAUNCH_KEY forKey:FIRST_LAUNCH_KEY];
        [[CreditsManager sharedManager] addCredits:5];
    }
    
    [NZEvents startSession];

  //  NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return YES;
}

- (void) loadDefaultSongs {
    NSArray *files = [[NSBundle mainBundle] pathsForResourcesOfType:@".mid" inDirectory:@"default_songs"];
    
    for (NSString *file in files) {
        [self loadSong:file];
    }
    files = [[NSBundle mainBundle] pathsForResourcesOfType:@".aqw" inDirectory:@"default_songs"];
    files  = [files sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        if ([a compare:b] == NSOrderedAscending) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    for (NSString *file in files) {
        [self loadArrangement:file];
    }
    
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        NSArray *m = @[];
//        NSString *s = m[1];
//        NSLog(s);
//    });
}

- (void) loadArrangement:(NSString *)path {
        NSString *key = [@"DEFAULT-" stringByAppendingString:[path lastPathComponent]];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:key]) {
            return;
        }
    LibraryItem *item = [LibraryItem fromDictionary:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:kNilOptions error:nil]];
    NSString *newPath = [[Util uploadedSongsDirectory] stringByAppendingPathComponent:[item.Arrangement.MidiFile lastPathComponent]];
    newPath = [LibraryManager findUniquePathName:newPath];
    if ([item.Arrangement.fileData writeToFile:newPath atomically:NO]) {
        item.Arrangement.MidiFile = [newPath lastPathComponent];
        NSData *data = item.Arrangement.fileData;
        item.Arrangement.fileData = nil;
        if ([LibraryManager addItem:item] && ([LibraryManager hasPurchasedSongWithData:data] || [LibraryManager addItem:[LibraryItem itemWithFile:newPath]])) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key];
        }
    }
}

- (void) loadSong:(NSString *)path {
    NSString *key = [@"DEFAULT-" stringByAppendingString:[path lastPathComponent]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key]) {
        return;
    }
    NSString *newPath = [[Util documentsDirectory] stringByAppendingPathComponent:[path lastPathComponent]];
    if ([[NSFileManager defaultManager] copyItemAtPath:path toPath:newPath error:nil]) {
        if ([LibraryManager hasPurchasedSongWithData:[NSData dataWithContentsOfFile:path]]) {
             [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key];
        } else if ([LibraryManager addSong:newPath]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key];
        }
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleNewFile:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleNewFile:url];
}

- (BOOL) handleNewFile:(NSURL *)path {
    @try {
        if (!path || !([[path absoluteString] hasSuffix:@"mid"] || [path.absoluteString hasSuffix:@"kar"] || [path.absoluteString hasSuffix:@"midi"] || [path.absoluteString hasSuffix:@"aqw"])) {
            return NO;
        }
        if ([path.absoluteString hasSuffix:@"aqw"]) {
            [NZEvents logEvent:@"AQW file opened"];
            LibraryItem *item = [LibraryItem fromDictionary:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path.path] options:kNilOptions error:nil]];
            
            if ([LibraryManager hasPurchasedSongWithData:item.Arrangement.fileData]) {
                [self addArrangementToLibrary:item];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import this song?" message:@"Would you like to spend a qwerty to import this arrangement?" delegate:self cancelButtonTitle:@"Add to Store" otherButtonTitles:@"Translate!", nil];
                [alerts setObject:item forKey:[NSNumber numberWithInt:alert.hash]];
                [alert show];
            }
            [[NSFileManager defaultManager] removeItemAtPath:path.path error:nil];
        } else {
            [NZEvents logEvent:@"MIDI file opened"];
            if ([LibraryManager hasPurchasedSongWithData:[NSData dataWithContentsOfFile:path.path]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You already have this song!" message:@"But, it may be under a different name. Would you like to add it to your library anyway?" delegate:self cancelButtonTitle:@"Ignore" otherButtonTitles:@"Add it!", nil];
                [alerts setObject:path.path forKey:[NSNumber numberWithInt:alert.hash]];
                [alert show];
            } else {
                if ([[CreditsManager sharedManager] numberOfCredits] > 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import this song?" message:@"Would you like to spend a qwerty to translate this song?" delegate:self cancelButtonTitle:@"Add to store" otherButtonTitles:@"Translate!", nil];
                    [alerts setObject:path.path forKey:[NSNumber numberWithInt:alert.hash]];
                    [alert show];
                } else {
//                    [[[UIAlertView alloc] initWithTitle:@"Song Added!" message:[NSString stringWithFormat:@"%@ has been added to the store.", path.lastPathComponent.stringByDeletingPathExtension] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [self addItemToStore:path.path];
                }
            }
        }
        return YES;
    }
    @catch (NSException *e) {
        return NO;
    }
}

- (void) addArrangementToLibrary:(LibraryItem *)item {
    NSString *newPath = [[Util uploadedSongsDirectory] stringByAppendingPathComponent:[item.Arrangement.MidiFile lastPathComponent]];
    newPath = [LibraryManager findUniquePathName:newPath];
    if ([item.Arrangement.fileData writeToFile:newPath atomically:NO]) {
        item.Arrangement.MidiFile = [newPath lastPathComponent];
        item.Arrangement.fileData = nil;
        if ([LibraryManager addItem:item] && [LibraryManager addItem:[LibraryItem itemWithFile:newPath]]) {
        [[[UIAlertView alloc] initWithTitle:@"Arrangement Added!" message:[NSString stringWithFormat:@"%@ has been added to your library under Arrangements.", item.Title] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [[FileSelectViewController sharedController] refresh];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:[NSString stringWithFormat:@"There was an error copying the file."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void) addSongToLibrary: (NSString *)path {
    if ([LibraryManager addSong:path]) {
        [[[UIAlertView alloc] initWithTitle:@"Song Added!" message:[NSString stringWithFormat:@"%@ has been added to your library under Songs.", [[path lastPathComponent] stringByDeletingPathExtension]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
        [[FileSelectViewController sharedController] refresh];
    }
}

- (void) addArrangementToStore:(LibraryItem *)item {
    NSString *newPath = [[Util documentsDirectory] stringByAppendingPathComponent:[item.Arrangement.MidiFile lastPathComponent]];
    newPath = [LibraryManager findUniquePathName:newPath];
    [item.Arrangement.fileData writeToFile:newPath atomically:NO];
    [LibraryManager noteArrangementForFutureSong:item.Arrangement];
    [[[UIAlertView alloc] initWithTitle:@"Song Added!" message:[NSString stringWithFormat:@"%@ has been added to the store under the \"My iPad\" tab.",[[item.Arrangement.MidiFile lastPathComponent] stringByDeletingPathExtension]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    id path = [alerts objectForKey:[NSNumber numberWithInt:[alertView hash]]];
    if ([[alertView buttonTitleAtIndex:buttonIndex].lowercaseString rangeOfString:@"store"].location != NSNotFound || [[alertView buttonTitleAtIndex:buttonIndex].lowercaseString rangeOfString:@"not now"].location != NSNotFound) {
        if ([path isKindOfClass:[NSString class]]) {
            [self addItemToStore:path];
        } else {
            LibraryItem *item = (LibraryItem *)path;
            [self addArrangementToStore:item];
        }
    } else if ([[[alertView buttonTitleAtIndex:buttonIndex] lowercaseString] rangeOfString:@"library"].location != NSNotFound || [[[alertView buttonTitleAtIndex:buttonIndex] lowercaseString] rangeOfString:@"translate"].location != NSNotFound) {
        if ([path isKindOfClass:[NSString class]]) {
            if ([CreditsManager sharedManager].numberOfCredits > 0) {
                [[CreditsManager sharedManager] subtractCredit];
                [self addSongToLibrary:path];
            }
        } else {
            LibraryItem *item = (LibraryItem *)path;
            if ([CreditsManager sharedManager].numberOfCredits > 0) {
                [[CreditsManager sharedManager] subtractCredit];
                [self addArrangementToLibrary:item];
            }
        }
    }
}

- (void) addItemToStore:(NSString *)path {
    NSString *newPath = [[Util documentsDirectory] stringByAppendingPathComponent:[[[path lastPathComponent].stringByDeletingPathExtension stringByAppendingPathExtension:@"mid" ] stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
        newPath = [[newPath stringByDeletingPathExtension] stringByAppendingFormat:@"%d.mid", (arc4random() % 10000)];
    }
    [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    [[[UIAlertView alloc] initWithTitle:@"Song Added!"
                                message:[NSString stringWithFormat:@"%@ has been added to the store under the \"My iPad\" tab.",
                                         [[[path lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"_" withString:@" "]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [[StoreViewController sharedController] refreshSongList];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[PerformanceViewController sharedController] willResignActive];
    [[AudioPlayer sharedPlayer] stopPlaying];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
