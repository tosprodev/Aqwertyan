//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/RoundRobinAlgorithm.java
//
//  Created by nziebart on 9/17/12.
//

#import "Aqwertian/fingering/MusicFile.h"
#import "Aqwertian/fingering/PatternList.h"
#import "Aqwertian/fingering/QwertyMapper.h"
#import "Aqwertian/fingering/RoundRobinAlgorithm.h"
#import "IOSIntArray.h"
#import "IOSObjectArray.h"
#import "java/lang/NullPointerException.h"
#import "java/util/Collection.h"
#import "java/util/Iterator.h"
#import "java/util/Map.h"

@implementation AqwertianFingeringRoundRobinAlgorithm

static IOSObjectArray * AqwertianFingeringRoundRobinAlgorithm_FINGERS_;
static IOSIntArray * AqwertianFingeringRoundRobinAlgorithm_ROWS_;

- (AqwertianFingeringQwertyMapper *)_mapper {
  return _mapper_;
}

- (void)set_mapper:(AqwertianFingeringQwertyMapper *)new_mapper {
  [_mapper_ autorelease];
  _mapper_ = [new_mapper retain];
}


- (id)initWithAqwertianFingeringQwertyMapper:(AqwertianFingeringQwertyMapper *)m {
  if ((self = [super init])) {
    ([_mapper_ autorelease], _mapper_ = [m retain]);
  }
  return self;
}

- (NSString *)getInfo {
  return @"Round robin finger assignment, round robin row.";
}

+ (IOSObjectArray *)FINGERS {
  return AqwertianFingeringRoundRobinAlgorithm_FINGERS_;
}

+ (IOSIntArray *)ROWS {
  return AqwertianFingeringRoundRobinAlgorithm_ROWS_;
}

- (void)mapWithJavaUtilCollection:(id<JavaUtilCollection>)notes
withAqwertianFingeringPatternList:(AqwertianFingeringPatternList *)patterns
                  withJavaUtilMap:(id<JavaUtilMap>)notesHistogram {
  int finger = 0;
  int row = 0;
  {
    id<JavaLangIterable> array__ = (id<JavaLangIterable>) notes;
    if (!array__) {
      @throw [[[JavaLangNullPointerException alloc] init] autorelease];
    }
    id<JavaUtilIterator> iter__ = [array__ iterator];
    while ([iter__ hasNext]) {
      AqwertianFingeringMusicFile_Note * n = (AqwertianFingeringMusicFile_Note *) [iter__ next];
      NSString *f = [((IOSObjectArray *) NIL_CHK(AqwertianFingeringRoundRobinAlgorithm_FINGERS_)) objectAtIndex:finger];
      if (++finger >= (int) [((IOSObjectArray *) NIL_CHK(AqwertianFingeringRoundRobinAlgorithm_FINGERS_)) count]) finger = 0;
      if ([NIL_CHK(f) isEqual:@"T0"]) ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).qwerty = [((AqwertianFingeringQwertyMapper *) NIL_CHK(_mapper_)) getQwertyWithNSString:f withInt:0];
      else {
        do {
          ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).qwerty = [((AqwertianFingeringQwertyMapper *) NIL_CHK(_mapper_)) getQwertyWithNSString:f withInt:[((IOSIntArray *) NIL_CHK(AqwertianFingeringRoundRobinAlgorithm_ROWS_)) intAtIndex:row]];
          if (++row >= (int) [((IOSIntArray *) NIL_CHK(AqwertianFingeringRoundRobinAlgorithm_ROWS_)) count]) row = 0;
        }
        while (((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).qwerty == 0);
      }
    }
  }
}

+ (void)initialize {
  if (self == [AqwertianFingeringRoundRobinAlgorithm class]) {
    AqwertianFingeringRoundRobinAlgorithm_FINGERS_ = [[IOSObjectArray arrayWithObjects:(id[]){ @"L1", @"R1", @"L2", @"R2", @"L3", @"R3", @"L4", @"R4", @"T0" } count:9 type:[IOSClass classWithClass:[NSString class]]] retain];
    AqwertianFingeringRoundRobinAlgorithm_ROWS_ = [[IOSIntArray arrayWithInts:(int[]){ 1, 2, 3, 4, 3, 2 } count:6] retain];
  }
}

- (void)dealloc {
  ([_mapper_ autorelease], _mapper_ = nil);
  [super dealloc];
}

@end

