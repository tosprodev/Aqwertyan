//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/PatternList.java
//
//  Created by nziebart on 9/17/12.
//

@class AqwertianFingeringPatternList_Pattern;
@class IOSCharArray;
@class IOSIntArray;
@class JavaIoBufferedReader;
@class JavaIoReader;
@protocol AqwertianFingeringPatternList_NoteFinder;
@protocol JavaUtilList;

#import "JreEmulation.h"

@interface AqwertianFingeringPatternList : NSObject {
 @public
  id<JavaUtilList> _patterns_;
}

@property (nonatomic, retain) id<JavaUtilList> _patterns;

- (id)init;
- (id)initWithJavaIoReader:(JavaIoReader *)inArg;
- (id<JavaUtilList>)extractPatternsWithJavaIoBufferedReader:(JavaIoBufferedReader *)inArg;
- (AqwertianFingeringPatternList_Pattern *)matchPatternWithAqwertianFingeringPatternList_NoteFinder:(id<AqwertianFingeringPatternList_NoteFinder>)f;
- (NSString *)description;
@end

@interface AqwertianFingeringPatternList_Pattern : NSObject {
 @public
  int id__;
  IOSIntArray *notes_;
  IOSCharArray *qwertys_;
  int frequency_;
}

@property (nonatomic, assign) int id_;
@property (nonatomic, retain) IOSIntArray *notes;
@property (nonatomic, retain) IOSCharArray *qwertys;
@property (nonatomic, assign) int frequency;

@end

@protocol AqwertianFingeringPatternList_NoteFinder < NSObject >
- (int)getNoteWithInt:(int)index;
@end
