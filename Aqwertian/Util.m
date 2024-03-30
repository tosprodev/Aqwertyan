//
//  Util.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "Util.h"

Util *theUtil = nil;

@implementation Util

+ (void)initialize {

 
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        ios5 = NO;
    } else {
        ios5 = ![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
    }
}

+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)libraryDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)tempFilesDirectory {
    BOOL dir;
    NSString *path = [[Util documentsDirectory] stringByAppendingPathComponent:@"Temporary"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir] || !dir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)uploadedSongsDirectory {
    BOOL dir;
    NSString *path = [[Util libraryDirectory] stringByAppendingPathComponent:@"UploadedSongs"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir] || !dir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSArray *)allFilesAtPath:(NSString *)aPath {
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath error:nil];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    if (!theUtil) {
            theUtil = [Util new];
    }
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:theUtil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
+ (NSString *)musFilesDirectory {
    BOOL dir;
    NSString *path = [[Util libraryDirectory] stringByAppendingPathComponent:@"MusFiles"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir] || !dir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (BOOL)fileExists:(NSString *)aPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:aPath];
}

+ (void)deleteFile:(NSString *)aPath {
    if (aPath == nil || aPath.length == 0) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
}


- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}
+ (NSArray *)allFilesAtPath:(NSString *)aPath withPredicate:(NSPredicate *)predicate sorted:(BOOL)sorted {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:aPath error:nil];
    NSPredicate *fltr = predicate;
    NSArray *list = [dirContents filteredArrayUsingPredicate:fltr];
    if (sorted) {
        list = [list sortedArrayUsingSelector:@selector(compare:)];

    }
    return list;
                     
                     }

@end
