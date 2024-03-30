//
//  Util.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NZEvents.h"

#define NB(a) [NSNumber numberWithBool:a]
#define NI(a) [NSNumber numberWithInt:a]
#define IN(a) [a integerValue]
#define BN(a) [a boolValue]

bool ios5, scaleBack;

@interface Util : NSObject <UIAlertViewDelegate>

+ (NSString *)documentsDirectory;
+ (NSString *)libraryDirectory;
+ (NSString *)uploadedSongsDirectory;
+ (NSString *)tempFilesDirectory;
+ (NSArray *)allFilesAtPath:(NSString *)aPath;
+ (void) showAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (NSArray *)allFilesAtPath:(NSString *)aPath withPredicate:(NSPredicate *)predicate sorted:(BOOL)sorted;
+ (NSString *)musFilesDirectory;
+ (void) deleteFile:(NSString *)aPath;
+ (BOOL)fileExists:(NSString *)aPath;
@end
