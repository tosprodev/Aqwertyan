//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/Aqwertian.java
//
//  Created by nziebart on 9/17/12.
//

@class AqwertianFingeringMusicFile;
@class AqwertianFingeringPatternList;
@class AqwertianFingeringQwertyMapper;
@class AqwertianFingeringQwertyMapper_AlgorithmEnum;
@class IOSObjectArray;
@protocol JavaUtilCollection;

#import "JreEmulation.h"

@interface AqwertianFingeringAqwertian : NSObject {
}

+ (AqwertianFingeringQwertyMapper_AlgorithmEnum *)ALGO;
+ (void)printStatsWithAqwertianFingeringQwertyMapper:(AqwertianFingeringQwertyMapper *)qm
                              withJavaUtilCollection:(id<JavaUtilCollection>)notes
                   withAqwertianFingeringPatternList:(AqwertianFingeringPatternList *)patterns;
+ (AqwertianFingeringMusicFile *)createMusicFileWithNSString:(NSString *)fileName;
+ (AqwertianFingeringPatternList *)getPatternsWithNSString:(NSString *)fileName;
+ (void)storeMusicFileWithAqwertianFingeringMusicFile:(AqwertianFingeringMusicFile *)m
                                         withNSString:(NSString *)fileName;
+ (void)aqw_mainWithNSStringArray:(IOSObjectArray *)args;
@end
