//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/Documents/MusFingering/com/aqwertian/fingering/RoundRobinAlgorithm.java
//
//  Created by nziebart on 10/23/12.
//

@class ComAqwertianFingeringPatternList;
@class ComAqwertianFingeringQwertyMapper;
@class IOSIntArray;
@class IOSObjectArray;
@protocol JavaUtilCollection;
@protocol JavaUtilMap;

#import "JreEmulation.h"
#import "MapAlgorithm.h"

@interface ComAqwertianFingeringRoundRobinAlgorithm : NSObject < ComAqwertianFingeringMapAlgorithm > {
 @public
  ComAqwertianFingeringQwertyMapper *_mapper_;
}

@property (nonatomic, strong) ComAqwertianFingeringQwertyMapper *_mapper;

- (id)initWithComAqwertianFingeringQwertyMapper:(ComAqwertianFingeringQwertyMapper *)m;
- (NSString *)getInfo;
+ (IOSObjectArray *)FINGERS;
+ (IOSIntArray *)ROWS;
- (void)mapWithJavaUtilCollection:(id<JavaUtilCollection>)notes
withComAqwertianFingeringPatternList:(ComAqwertianFingeringPatternList *)patterns
                  withJavaUtilMap:(id<JavaUtilMap>)notesHistogram;
@end
