//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/PatternList.java
//
//  Created by nziebart on 9/17/12.
//

#import "Aqwertian/fingering/PatternList.h"
#import "Aqwertian/fingering/util/StringTokenizer.h"
#import "IOSCharArray.h"
#import "IOSIntArray.h"
#import "java/io/BufferedReader.h"
#import "java/io/Reader.h"
#import "java/lang/IllegalArgumentException.h"
#import "java/lang/Integer.h"
#import "java/lang/NullPointerException.h"
#import "java/lang/StringBuffer.h"
#import "java/util/ArrayList.h"
#import "java/util/Iterator.h"
#import "java/util/List.h"

@implementation AqwertianFingeringPatternList

- (id<JavaUtilList>)_patterns {
  return _patterns_;
}

- (void)set_patterns:(id<JavaUtilList>)new_patterns {
  [_patterns_ autorelease];
  _patterns_ = [new_patterns retain];
}


- (id)init {
  if ((self = [super init])) {
    _patterns_ = [[JavaUtilArrayList alloc] init];
  }
  return self;
}

- (id)initWithJavaIoReader:(JavaIoReader *)inArg {
  if ((self = [super init])) {
    ([_patterns_ autorelease], _patterns_ = [[self extractPatternsWithJavaIoBufferedReader:[[[JavaIoBufferedReader alloc] initWithJavaIoReader:inArg] autorelease]] retain]);
  }
  return self;
}

- (id<JavaUtilList>)extractPatternsWithJavaIoBufferedReader:(JavaIoBufferedReader *)inArg {
  id<JavaUtilList> patterns = [[[JavaUtilArrayList alloc] init] autorelease];
  NSString *line;
  int lineCount = 0;
  while ((line = [((JavaIoBufferedReader *) NIL_CHK(inArg)) readLine]) != nil) {
    lineCount++;
    AqwertianFingeringUtilStringTokenizer *tok = [[[AqwertianFingeringUtilStringTokenizer alloc] initWithNSString:line] autorelease];
    int count = 0;
    while ([((AqwertianFingeringUtilStringTokenizer *) NIL_CHK(tok)) hasMoreTokens]) {
      [((AqwertianFingeringUtilStringTokenizer *) NIL_CHK(tok)) nextToken];
      count++;
    }
    if (count % 2 != 0) @throw [[[JavaLangIllegalArgumentException alloc] initWithNSString:[NSString stringWithFormat:@"File has illegal format. Line: %d", lineCount]] autorelease];
    count /= 2;
    tok = [[[AqwertianFingeringUtilStringTokenizer alloc] initWithNSString:line] autorelease];
    AqwertianFingeringPatternList_Pattern *p = [[[AqwertianFingeringPatternList_Pattern alloc] init] autorelease];
    ((AqwertianFingeringPatternList_Pattern *) NIL_CHK(p)).id_ = lineCount;
    ((AqwertianFingeringPatternList_Pattern *) NIL_CHK(p)).notes = [[IOSIntArray alloc] initWithLength:count];
    ((AqwertianFingeringPatternList_Pattern *) NIL_CHK(p)).qwertys = [[IOSCharArray alloc] initWithLength:count];
    int n = 0;
    while ([((AqwertianFingeringUtilStringTokenizer *) NIL_CHK(tok)) hasMoreTokens]) {
      NSString *item = [((AqwertianFingeringUtilStringTokenizer *) NIL_CHK(tok)) nextToken];
      if (n < count) [((IOSIntArray *) NIL_CHK(p.notes)) replaceIntAtIndex:n withInt:[JavaLangInteger parseIntWithNSString:item]];
      else [((IOSCharArray *) NIL_CHK(p.qwertys)) replaceCharAtIndex:n - count withChar:[NIL_CHK(item) charAtWithInt:0]];
      n++;
    }
    [((id<JavaUtilList>) NIL_CHK(patterns)) addWithId:p];
  }
  return patterns;
}

- (AqwertianFingeringPatternList_Pattern *)matchPatternWithAqwertianFingeringPatternList_NoteFinder:(id<AqwertianFingeringPatternList_NoteFinder>)f {
  {
    id<JavaLangIterable> array__ = (id<JavaLangIterable>) _patterns_;
    if (!array__) {
      @throw [[[JavaLangNullPointerException alloc] init] autorelease];
    }
    id<JavaUtilIterator> iter__ = [array__ iterator];
    while ([iter__ hasNext]) {
      AqwertianFingeringPatternList_Pattern * p = (AqwertianFingeringPatternList_Pattern *) [iter__ next];
      BOOL found = YES;
      for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(p.notes)) count]; i++) {
        if ([((IOSIntArray *) NIL_CHK(p.notes)) intAtIndex:i] != [((id<AqwertianFingeringPatternList_NoteFinder>) NIL_CHK(f)) getNoteWithInt:i]) {
          found = NO;
          break;
        }
      }
      if (found) return p;
    }
  }
  return nil;
}

- (NSString *)description {
  JavaLangStringBuffer *buff = [[[JavaLangStringBuffer alloc] initWithNSString:@"Patterns (notes; keys [usage count]):\n"] autorelease];
  {
    id<JavaLangIterable> array__ = (id<JavaLangIterable>) _patterns_;
    if (!array__) {
      @throw [[[JavaLangNullPointerException alloc] init] autorelease];
    }
    id<JavaUtilIterator> iter__ = [array__ iterator];
    while ([iter__ hasNext]) {
      AqwertianFingeringPatternList_Pattern * p = (AqwertianFingeringPatternList_Pattern *) [iter__ next];
      [[[((JavaLangStringBuffer *) NIL_CHK(buff)) appendWithNSString:@"   "] appendWithInt:((AqwertianFingeringPatternList_Pattern *) NIL_CHK(p)).id_] appendWithNSString:@"-"];
      for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(p.notes)) count]; i++) [[((JavaLangStringBuffer *) NIL_CHK(buff)) appendWithUnichar:' '] appendWithInt:[((IOSIntArray *) NIL_CHK(p.notes)) intAtIndex:i]];
      [((JavaLangStringBuffer *) NIL_CHK(buff)) appendWithUnichar:';'];
      for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(p.notes)) count]; i++) [[((JavaLangStringBuffer *) NIL_CHK(buff)) appendWithUnichar:' '] appendWithUnichar:[((IOSCharArray *) NIL_CHK(p.qwertys)) charAtIndex:i]];
      [[[[((JavaLangStringBuffer *) NIL_CHK(buff)) appendWithNSString:@" ["] appendWithInt:((AqwertianFingeringPatternList_Pattern *) NIL_CHK(p)).frequency] appendWithUnichar:']'] appendWithUnichar:0x000a];
    }
  }
  return [((JavaLangStringBuffer *) NIL_CHK(buff)) description];
}

- (void)dealloc {
  ([_patterns_ autorelease], _patterns_ = nil);
  [super dealloc];
}

@end


@implementation AqwertianFingeringPatternList_Pattern

- (int)id_ {
  return id__;
}

- (void)setId_:(int)newId_ {
  id__ = newId_;
}

- (IOSIntArray *)notes {
  return notes_;
}

- (void)setNotes:(IOSIntArray *)newNotes {
  [notes_ autorelease];
  notes_ = [newNotes retain];
}

- (IOSCharArray *)qwertys {
  return qwertys_;
}

- (void)setQwertys:(IOSCharArray *)newQwertys {
  [qwertys_ autorelease];
  qwertys_ = [newQwertys retain];
}

- (int)frequency {
  return frequency_;
}

- (void)setFrequency:(int)newFrequency {
  frequency_ = newFrequency;
}


- (void)dealloc {
  ([qwertys_ autorelease], qwertys_ = nil);
  ([notes_ autorelease], notes_ = nil);
  [super dealloc];
}

@end


