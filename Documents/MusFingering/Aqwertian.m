//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/Documents/MusFingering/com/aqwertian/fingering/Aqwertian.java
//
//  Created by nziebart on 10/31/12.
//

#import "Aqwertian.h"
#import "IOSObjectArray.h"
#import "MidiFile.h"
#import "MusNotesFile.h"
#import "MusPlayFile.h"
#import "MusicFile.h"
#import "PatternList.h"
#import "QwertyMapper.h"
#import "java/io/FileInputStream.h"
#import "java/io/FileOutputStream.h"
#import "java/io/FileReader.h"
#import "java/io/IOException.h"
#import "java/io/OutputStream.h"
#import "java/lang/Exception.h"
#import "java/lang/Integer.h"
#import "java/lang/NullPointerException.h"
#import "java/util/ArrayList.h"
#import "java/util/Collection.h"
#import "java/util/Iterator.h"
#import "java/util/List.h"

@implementation ComAqwertianFingeringAqwertian

static ComAqwertianFingeringQwertyMapper_AlgorithmEnum * ComAqwertianFingeringAqwertian_ALGO_;

+ (ComAqwertianFingeringQwertyMapper_AlgorithmEnum *)ALGO {
  return ComAqwertianFingeringAqwertian_ALGO_;
}

+ (void)printStatsWithComAqwertianFingeringQwertyMapper:(ComAqwertianFingeringQwertyMapper *)qm
                                 withJavaUtilCollection:(id<JavaUtilCollection>)notes
                   withComAqwertianFingeringPatternList:(ComAqwertianFingeringPatternList *)patterns {
  int count = 250;
  NSLog(@"%@", [((ComAqwertianFingeringPatternList *) NIL_CHK(patterns)) description]);
  NSLog(@"%@", [NSString stringWithFormat:@"%d notes: ", [((id<JavaUtilCollection>) NIL_CHK(notes)) size]]);
  NSLog(@"%@", [((ComAqwertianFingeringQwertyMapper *) NIL_CHK(qm)) getInfo]);
  {
    id<JavaLangIterable> array__ = (id<JavaLangIterable>) notes;
    if (!array__) {
      @throw [[JavaLangNullPointerException alloc] init];
    }
    id<JavaUtilIterator> iter__ = [array__ iterator];
    while ([iter__ hasNext]) {
      ComAqwertianFingeringMusicFile_Note * note = (ComAqwertianFingeringMusicFile_Note *) [iter__ next];
      if (--count >= 0) NSLog(@"%@", [((ComAqwertianFingeringQwertyMapper *) NIL_CHK(qm)) toStringWithComAqwertianFingeringMusicFile_Note:note]);
      else break;
    }
  }
  NSLog(@"");
  [((ComAqwertianFingeringQwertyMapper *) NIL_CHK(qm)) printStatisticsWithJavaUtilCollection:notes];
  NSLog(@"%@", @"----------------");
  NSLog(@"");
}

+ (ComAqwertianFingeringMusicFile *)createMusicFileWithNSString:(NSString *)fileName {
  ComAqwertianFingeringMusicFile *mf;
  JavaIoFileInputStream *file = [[JavaIoFileInputStream alloc] initWithNSString:fileName];
  if ([NIL_CHK(fileName) hasSuffix:@".mus"]) mf = [[ComAqwertianFingeringMusPlayFile alloc] initWithJavaIoInputStream:file];
  else if ([NIL_CHK(fileName) hasSuffix:@".nts"]) mf = [[ComAqwertianFingeringMusNotesFile alloc] initWithJavaIoInputStream:file];
  else mf = [[ComAqwertianFingeringMidiFile alloc] initWithJavaIoInputStream:file];
  [((JavaIoFileInputStream *) NIL_CHK(file)) close];
  return mf;
}

+ (ComAqwertianFingeringPatternList *)getPatternsWithNSString:(NSString *)fileName {
  @try {
    JavaIoFileReader *pfile = [[JavaIoFileReader alloc] initWithNSString:[NSString stringWithFormat:@"%@.patterns", fileName]];
    ComAqwertianFingeringPatternList *patterns = [[ComAqwertianFingeringPatternList alloc] initWithJavaIoReader:pfile];
    [((JavaIoFileReader *) NIL_CHK(pfile)) close];
    return patterns;
  }
  @catch (JavaIoIOException *e) {
    return [[ComAqwertianFingeringPatternList alloc] init];
  }
}

+ (void)storeMusicFileWithComAqwertianFingeringMusicFile:(ComAqwertianFingeringMusicFile *)m
                                        withJavaUtilList:(id<JavaUtilList>)notes
                                            withNSString:(NSString *)fileName {
  JavaIoOutputStream *out = [[JavaIoFileOutputStream alloc] initWithNSString:fileName];
  [ComAqwertianFingeringMusPlayFile storeNotesWithNSString:@"Auto Generated" withJavaUtilList:notes withJavaIoOutputStream:out];
  [((JavaIoOutputStream *) NIL_CHK(out)) close];
}

+ (void)ConvertToMusWithNSString:(NSString *)inFile
                    withNSString:(NSString *)outFile
                     withUnichar:(unichar)difficulty
           withJavaUtilArrayList:(JavaUtilArrayList *)channels
                        withBOOL:(BOOL)exmatch {
  ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum *level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum EXPERT];
  ComAqwertianFingeringPatternList *patterns = nil;
  ComAqwertianFingeringQwertyMapper *qm = nil;
  if (difficulty == 'b') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum BEGINNER];
  else if (difficulty == 'i') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum INTERMEDIATE];
  else if (difficulty == 'a') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum ADVANCED];
  else if (difficulty == 'e') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum EXPERT];
  NSString *infile = inFile;
  NSString *outfile = outFile;
  @try {
    ComAqwertianFingeringMusicFile *midi = [ComAqwertianFingeringAqwertian createMusicFileWithNSString:infile];
    if (exmatch) {
      patterns = [ComAqwertianFingeringAqwertian getPatternsWithNSString:infile];
    }
    id<JavaUtilList> notes = [((ComAqwertianFingeringMusicFile *) NIL_CHK(midi)) getNotesWithJavaUtilCollection:[[JavaUtilArrayList alloc] init]];
    if (exmatch) {
      qm = [[ComAqwertianFingeringQwertyMapper alloc] initWithComAqwertianFingeringQwertyMapper_AlgorithmEnum:ComAqwertianFingeringAqwertian_ALGO_ withComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum:level];
      [((ComAqwertianFingeringQwertyMapper *) NIL_CHK(qm)) mapWithJavaUtilCollection:notes withComAqwertianFingeringPatternList:patterns];
      [ComAqwertianFingeringAqwertian printStatsWithComAqwertianFingeringQwertyMapper:qm withJavaUtilCollection:notes withComAqwertianFingeringPatternList:patterns];
    }
    [ComAqwertianFingeringAqwertian storeMusicFileWithComAqwertianFingeringMusicFile:midi withJavaUtilList:notes withNSString:outfile];
  }
  @catch (JavaLangException *ex) {
    [((JavaLangException *) NIL_CHK(ex)) printStackTrace];
  }
}

+ (void)initialize {
  if (self == [ComAqwertianFingeringAqwertian class]) {
    ComAqwertianFingeringAqwertian_ALGO_ = [ComAqwertianFingeringQwertyMapper_AlgorithmEnum USAGE];
  }
}

@end

//
//int main( int argc, const char *argv[] ) {
//  int exitCode = 0;
//  @autoreleasepool {
//    IOSObjectArray *args = JreEmulationMainArguments(argc, argv);
//
//    @try {
//      if ((int) [((IOSObjectArray *) NIL_CHK(args)) count] == 0) {
//        NSLog(@"%@", @"Usage: Aqwertian -level infile outfile");
//        NSLog(@"%@", @"    level is optional and must be one of");
//        NSLog(@"%@", @"    b(eginner), i(ntermediate), a(dvanced), e(xpert)");
//        NSLog(@"%@", @"    default is expert.");
//        return 0;
//      }
//      ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum *level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum EXPERT];
//      int index = 0;
//      NSString *parm = [((IOSObjectArray *) NIL_CHK(args)) objectAtIndex:index];
//      if ([NIL_CHK(parm) hasPrefix:@"-"]) {
//        unichar l = [NIL_CHK(parm) charAtWithInt:1];
//        if (l == 'b') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum BEGINNER];
//        else if (l == 'i') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum INTERMEDIATE];
//        else if (l == 'a') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum ADVANCED];
//        else if (l == 'e') level = [ComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum EXPERT];
//        index++;
//      }
//      NSString *infile = [((IOSObjectArray *) NIL_CHK(args)) objectAtIndex:index];
//      index++;
//      NSString *outfile = [NSString stringWithFormat:@"%@.out", infile];
//      if ((int) [((IOSObjectArray *) NIL_CHK(args)) count] >= index + 1) outfile = [((IOSObjectArray *) NIL_CHK(args)) objectAtIndex:index];
//      ComAqwertianFingeringMusicFile *midi = [ComAqwertianFingeringAqwertian createMusicFileWithNSString:infile];
//      ComAqwertianFingeringPatternList *patterns = [ComAqwertianFingeringAqwertian getPatternsWithNSString:infile];
//      id<JavaUtilList> notes = [((ComAqwertianFingeringMusicFile *) NIL_CHK(midi)) getNotesWithJavaUtilCollection:[[JavaUtilArrayList alloc] init]];
//      ComAqwertianFingeringQwertyMapper *qm = [[ComAqwertianFingeringQwertyMapper alloc] initWithComAqwertianFingeringQwertyMapper_AlgorithmEnum:[ComAqwertianFingeringAqwertian ALGO] withComAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum:level];
//      [((ComAqwertianFingeringQwertyMapper *) NIL_CHK(qm)) mapWithJavaUtilCollection:notes withComAqwertianFingeringPatternList:patterns];
//      [ComAqwertianFingeringAqwertian printStatsWithComAqwertianFingeringQwertyMapper:qm withJavaUtilCollection:notes withComAqwertianFingeringPatternList:patterns];
//      [ComAqwertianFingeringAqwertian storeMusicFileWithComAqwertianFingeringMusicFile:midi withJavaUtilList:notes withNSString:outfile];
//    }
//    @catch (JavaLangException *ex) {
//      [((JavaLangException *) NIL_CHK(ex)) printStackTrace];
//    }
//  }
//  return exitCode;
//}
