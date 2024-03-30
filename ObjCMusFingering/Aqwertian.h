//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/Documents/MusFingering/com/aqwertian/fingering/Aqwertian.java
//
//  Created by nziebart on 1/20/13.
//

@class ComAqwertianFingeringMusicFile;
@class ComAqwertianFingeringPatternList;
@class ComAqwertianFingeringQwertyMapper;
@class ComAqwertianFingeringQwertyMapper_AlgorithmEnum;
@class IOSObjectArray;
@protocol JavaUtilCollection;
@protocol JavaUtilList;

#import "JreEmulation.h"

@interface ComAqwertianFingeringAqwertian : NSObject {
}

+ (ComAqwertianFingeringQwertyMapper_AlgorithmEnum *)ALGO;
+ (void)printStatsWithComAqwertianFingeringQwertyMapper:(ComAqwertianFingeringQwertyMapper *)qm
                                 withJavaUtilCollection:(id<JavaUtilCollection>)notes
                   withComAqwertianFingeringPatternList:(ComAqwertianFingeringPatternList *)patterns;
+ (ComAqwertianFingeringMusicFile *)createMusicFileWithNSString:(NSString *)fileName;
+ (ComAqwertianFingeringPatternList *)getPatternsWithNSString:(NSString *)fileName;
+ (void)storeMusicFileWithComAqwertianFingeringMusicFile:(ComAqwertianFingeringMusicFile *)m
                                        withJavaUtilList:(id<JavaUtilList>)notes
                                            withNSString:(NSString *)fileName;
+ (void) assignFingering:(NSArray *)notes difficulty:(unichar)difficulty seed:(long)seed chordQuantum:(int)quantum trillQuantum:(int)trillQuantum;

+ (NSMutableArray *) GetNotesForFile:(NSString *)midiFile difficulty:(unichar)diff channels:(NSArray *)channels exmatch:(BOOL)exmatch;
@end