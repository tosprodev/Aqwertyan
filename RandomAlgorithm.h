//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/Documents/MusFingering/com/aqwertian/fingering/RandomAlgorithm.java
//
//  Created by nziebart on 10/23/12.
//

@class ComAqwertianFingeringPatternList;
@class ComAqwertianFingeringQwertyMapper;
@class JavaUtilRandom;
@protocol JavaUtilCollection;
@protocol JavaUtilMap;

#import "JreEmulation.h"
#import "MapAlgorithm.h"

@interface ComAqwertianFingeringRandomAlgorithm : NSObject < ComAqwertianFingeringMapAlgorithm > {
 @public
  JavaUtilRandom *rand_;
}

@property (nonatomic, strong) JavaUtilRandom *rand;

- (id)initWithComAqwertianFingeringQwertyMapper:(ComAqwertianFingeringQwertyMapper *)m;
- (NSString *)getInfo;
- (void)mapWithJavaUtilCollection:(id<JavaUtilCollection>)notes
withComAqwertianFingeringPatternList:(ComAqwertianFingeringPatternList *)patterns
                  withJavaUtilMap:(id<JavaUtilMap>)notesHistogram;
@end