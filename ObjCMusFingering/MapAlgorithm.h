//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/Documents/MusFingering/com/aqwertian/fingering/MapAlgorithm.java
//
//  Created by nziebart on 1/20/13.
//

@class ComAqwertianFingeringPatternList;
@protocol JavaUtilCollection;
@protocol JavaUtilMap;

#import "JreEmulation.h"

@protocol ComAqwertianFingeringMapAlgorithm < NSObject >
- (NSString *)getInfo;
- (void)mapWithJavaUtilCollection:(id<JavaUtilCollection>)notes
withComAqwertianFingeringPatternList:(ComAqwertianFingeringPatternList *)patterns
                  withJavaUtilMap:(id<JavaUtilMap>)notesHistogram;
@end
