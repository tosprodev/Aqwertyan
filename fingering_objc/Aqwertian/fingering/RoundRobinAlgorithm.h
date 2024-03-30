//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/RoundRobinAlgorithm.java
//
//  Created by nziebart on 9/17/12.
//

@class AqwertianFingeringPatternList;
@class AqwertianFingeringQwertyMapper;
@class IOSIntArray;
@class IOSObjectArray;
@protocol JavaUtilCollection;
@protocol JavaUtilMap;

#import "JreEmulation.h"
#import "Aqwertian/fingering/MapAlgorithm.h"

@interface AqwertianFingeringRoundRobinAlgorithm : NSObject < AqwertianFingeringMapAlgorithm > {
 @public
  AqwertianFingeringQwertyMapper *_mapper_;
}

@property (nonatomic, retain) AqwertianFingeringQwertyMapper *_mapper;

- (id)initWithAqwertianFingeringQwertyMapper:(AqwertianFingeringQwertyMapper *)m;
- (NSString *)getInfo;
+ (IOSObjectArray *)FINGERS;
+ (IOSIntArray *)ROWS;
- (void)mapWithJavaUtilCollection:(id<JavaUtilCollection>)notes
withAqwertianFingeringPatternList:(AqwertianFingeringPatternList *)patterns
                  withJavaUtilMap:(id<JavaUtilMap>)notesHistogram;
@end
