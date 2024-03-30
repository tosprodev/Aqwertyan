//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/Documents/MusFingering/com/aqwertian/fingering/PatternList.java
//
//  Created by nziebart on 10/23/12.
//

@class ComAqwertianFingeringPatternList_Pattern;
@class IOSCharArray;
@class IOSIntArray;
@class JavaIoBufferedReader;
@class JavaIoReader;
@protocol ComAqwertianFingeringPatternList_NoteFinder;
@protocol JavaUtilList;

#import "JreEmulation.h"

@interface ComAqwertianFingeringPatternList : NSObject {
 @public
  id<JavaUtilList> _patterns_;
}

@property (nonatomic, strong) id<JavaUtilList> _patterns;

- (id)init;
- (id)initWithJavaIoReader:(JavaIoReader *)inArg;
- (id<JavaUtilList>)extractPatternsWithJavaIoBufferedReader:(JavaIoBufferedReader *)inArg;
- (ComAqwertianFingeringPatternList_Pattern *)matchPatternWithComAqwertianFingeringPatternList_NoteFinder:(id<ComAqwertianFingeringPatternList_NoteFinder>)f;
- (NSString *)description;
@end

@interface ComAqwertianFingeringPatternList_Pattern : NSObject {
 @public
  int id__;
  IOSIntArray *notes_;
  IOSCharArray *qwertys_;
  int frequency_;
}

@property (nonatomic, assign) int id_;
@property (nonatomic, strong) IOSIntArray *notes;
@property (nonatomic, strong) IOSCharArray *qwertys;
@property (nonatomic, assign) int frequency;

@end

@protocol ComAqwertianFingeringPatternList_NoteFinder < NSObject >
- (int)getNoteWithInt:(int)index;
@end
