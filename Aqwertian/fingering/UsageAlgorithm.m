//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/UsageAlgorithm.java
//
//  Created by nziebart on 9/17/12.
//

#import "Aqwertian/fingering/MusicFile.h"
#import "Aqwertian/fingering/PatternList.h"
#import "Aqwertian/fingering/QwertyMapper.h"
#import "Aqwertian/fingering/UsageAlgorithm.h"
#import "IOSBooleanArray.h"
#import "IOSCharArray.h"
#import "IOSIntArray.h"
#import "IOSObjectArray.h"
#import "java/lang/Integer.h"
#import "java/util/ArrayList.h"
#import "java/util/Collection.h"
#import "java/util/Collections.h"
#import "java/util/Iterator.h"
#import "java/util/List.h"
#import "java/util/Map.h"
#import "java/util/Random.h"

@implementation AqwertianFingeringUsageAlgorithm

static IOSIntArray * AqwertianFingeringUsageAlgorithm_FREQUENCY_INTERMEDIATE_;
static IOSIntArray * AqwertianFingeringUsageAlgorithm_FREQUENCY_BEGINNER_;
static IOSIntArray * AqwertianFingeringUsageAlgorithm_FREQUENCY_ADVANCED_;
static IOSIntArray * AqwertianFingeringUsageAlgorithm_FREQUENCY_EXPERT_;
static IOSObjectArray * AqwertianFingeringUsageAlgorithm__chording_;

- (AqwertianFingeringQwertyMapper *)_mapper {
  return _mapper_;
}

- (void)set_mapper:(AqwertianFingeringQwertyMapper *)new_mapper {
  _mapper_ = new_mapper;
}

- (IOSIntArray *)_frequency {
  return _frequency_;
}

- (void)set_frequency:(IOSIntArray *)new_frequency {
  _frequency_ = new_frequency;
}

- (id<JavaUtilList>)_firstKeys {
  return _firstKeys_;
}

- (void)set_firstKeys:(id<JavaUtilList>)new_firstKeys {
  _firstKeys_ = new_firstKeys;
}


- (id)initWithAqwertianFingeringQwertyMapper:(AqwertianFingeringQwertyMapper *)m
withAqwertianFingeringQwertyMapper_LevelOfDifficultyEnum:(AqwertianFingeringQwertyMapper_LevelOfDifficultyEnum *)level {
  if ((self = [super init])) {
    _mapper_ = m;
    NSLog(@"%@", [NSString stringWithFormat:@"Using level: %@", level]);
    switch ([level ordinal]) {
      case AqwertianFingeringQwertyMapper_LevelOfDifficulty_BEGINNER:
      _frequency_ = AqwertianFingeringUsageAlgorithm_FREQUENCY_BEGINNER_;
      break;
      case AqwertianFingeringQwertyMapper_LevelOfDifficulty_INTERMEDIATE:
      _frequency_ = AqwertianFingeringUsageAlgorithm_FREQUENCY_INTERMEDIATE_;
      break;
      case AqwertianFingeringQwertyMapper_LevelOfDifficulty_ADVANCED:
      _frequency_ = AqwertianFingeringUsageAlgorithm_FREQUENCY_ADVANCED_;
      break;
      case AqwertianFingeringQwertyMapper_LevelOfDifficulty_EXPERT:
      _frequency_ = AqwertianFingeringUsageAlgorithm_FREQUENCY_EXPERT_;
      break;
      default:
      _frequency_ = AqwertianFingeringUsageAlgorithm_FREQUENCY_EXPERT_;
      break;
    }
  }
  return self;
}

+ (IOSIntArray *)FREQUENCY_INTERMEDIATE {
  return AqwertianFingeringUsageAlgorithm_FREQUENCY_INTERMEDIATE_;
}

+ (IOSIntArray *)FREQUENCY_BEGINNER {
  return AqwertianFingeringUsageAlgorithm_FREQUENCY_BEGINNER_;
}

+ (IOSIntArray *)FREQUENCY_ADVANCED {
  return AqwertianFingeringUsageAlgorithm_FREQUENCY_ADVANCED_;
}

+ (IOSIntArray *)FREQUENCY_EXPERT {
  return AqwertianFingeringUsageAlgorithm_FREQUENCY_EXPERT_;
}

+ (int)countWithJavaLangIntegerArray:(IOSIntArray *)values {
  int count = 0;
  for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(values)) count]; i++) {
    count += [((IOSIntArray *) NIL_CHK(values)) intAtIndex:i];
  }
  return count;
}

- (NSString *)getInfo {
  return @"Key assignment based on key usage.";
}

- (void)mapWithJavaUtilCollection:(id<JavaUtilCollection>)nts
withAqwertianFingeringPatternList:(AqwertianFingeringPatternList *)patterns
                  withJavaUtilMap:(id<JavaUtilMap>)notesHistogram {
  IOSObjectArray *notes = [((id<JavaUtilCollection>) NIL_CHK(nts)) toArrayWithNSObjectArray:[[IOSObjectArray alloc] initWithLength:[((id<JavaUtilCollection>) NIL_CHK(nts)) size] type:[IOSClass classWithClass:[AqwertianFingeringMusicFile_Note class]]]];
  IOSIntArray *freq = [[IOSIntArray alloc] initWithLength:(int) [((IOSIntArray *) NIL_CHK(_frequency_)) count]];
  IOSIntArray *used = [[IOSIntArray alloc] initWithLength:(int) [((IOSIntArray *) NIL_CHK(_frequency_)) count]];
  int freqCount = [AqwertianFingeringUsageAlgorithm countWithJavaLangIntegerArray:_frequency_];
  for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(freq)) count]; i++) {
    if ([((IOSIntArray *) NIL_CHK(_frequency_)) intAtIndex:i] != 0) {
      [((IOSIntArray *) NIL_CHK(freq)) replaceIntAtIndex:i withInt:(int) ((double) (freqCount + [((IOSIntArray *) NIL_CHK(_frequency_)) intAtIndex:i] - 1) / [((IOSIntArray *) NIL_CHK(_frequency_)) intAtIndex:i])];
    }
  }
  AqwertianFingeringQwertyMapper_KeyHistory *history = [((AqwertianFingeringQwertyMapper *) NIL_CHK(_mapper_)) createKeyHistory];
  for (int count = 0; count < (int) [((IOSObjectArray *) NIL_CHK(notes)) count]; count++) {
    AqwertianFingeringMusicFile_Note *n = [((IOSObjectArray *) NIL_CHK(notes)) objectAtIndex:count];
    if (((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).note == 0) {
      ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).qwerty = ' ';
      continue;
    }
    int skip = [self matchPatternWithAqwertianFingeringMusicFile_NoteArray:notes withAqwertianFingeringPatternList:patterns withInt:count];
    if (skip > 0) {
      count += skip - 1;
      continue;
    }
    skip = [self matchChordWithAqwertianFingeringMusicFile_NoteArray:notes withInt:count];
    if (skip > 0) {
      count += skip - 1;
      continue;
    }
    AqwertianFingeringMusicFile_Note *historyNote = [((AqwertianFingeringQwertyMapper_KeyHistory *) NIL_CHK(history)) findMappedNoteWithAqwertianFingeringMusicFile_Note:n];
    int index;
    if (historyNote != nil && ![((AqwertianFingeringQwertyMapper *) NIL_CHK(_mapper_)) ruleFailsWithAqwertianFingeringQwertyMapper_KeyHistory:history withAqwertianFingeringMusicFile_Note:n withUnichar:((AqwertianFingeringMusicFile_Note *) NIL_CHK(historyNote)).qwerty]) {
      index = [AqwertianFingeringQwertyMapper getIndexWithUnichar:((AqwertianFingeringMusicFile_Note *) NIL_CHK(historyNote)).qwerty];
      ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).reason = @"Previously mapped.";
    }
    else {
      AqwertianFingeringUsageAlgorithm_NextKey *k = [self calcNextKeyWithAqwertianFingeringQwertyMapper_KeyHistory:history withAqwertianFingeringMusicFile_Note:n withJavaLangIntegerArray:freq withJavaLangIntegerArray:used];
      index = ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(k)).index;
      ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).reason = ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(k)).reason;
    }
    [((IOSIntArray *) NIL_CHK(used)) replaceIntAtIndex:index withInt:count];
    unichar key = [AqwertianFingeringQwertyMapper getKeyWithInt:index];
    ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).qwerty = key;
    [((AqwertianFingeringQwertyMapper_KeyHistory *) NIL_CHK(history)) addNoteWithAqwertianFingeringMusicFile_Note:n];
  }
}

- (AqwertianFingeringUsageAlgorithm_NextKey *)calcNextKeyWithAqwertianFingeringQwertyMapper_KeyHistory:(AqwertianFingeringQwertyMapper_KeyHistory *)history
                                                                  withAqwertianFingeringMusicFile_Note:(AqwertianFingeringMusicFile_Note *)currNote
                                                                              withJavaLangIntegerArray:(IOSIntArray *)freq
                                                                              withJavaLangIntegerArray:(IOSIntArray *)used {
  AqwertianFingeringUsageAlgorithm_NextKey *ret = [[AqwertianFingeringUsageAlgorithm_NextKey alloc] init];
  ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index = -1;
  if (_firstKeys_ == nil) _firstKeys_ = [self getFirstKeys];
  if ([((id<JavaUtilList>) NIL_CHK(_firstKeys_)) size] > 0) {
    for (int i = 0; i < [((id<JavaUtilList>) NIL_CHK(_firstKeys_)) size]; i++) {
      ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index = [((JavaLangInteger *) [((id<JavaUtilList>) NIL_CHK(_firstKeys_)) getWithInt:i]) intValue];
      if (![((AqwertianFingeringQwertyMapper *) NIL_CHK(_mapper_)) ruleFailsWithAqwertianFingeringQwertyMapper_KeyHistory:history withAqwertianFingeringMusicFile_Note:currNote withUnichar:[AqwertianFingeringQwertyMapper getKeyWithInt:((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index]]) {
        [((id<JavaUtilList>) NIL_CHK(_firstKeys_)) removeWithInt:i];
        ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).reason = @"From first keys list.";
        return ret;
      }
    }
  }
  IOSBooleanArray *tried = [[IOSBooleanArray alloc] initWithLength:(int) [((IOSIntArray *) NIL_CHK(freq)) count]];
  do {
    int min = JavaLangInteger_MAX_VALUE;
    ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index = -1;
    for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(freq)) count]; i++) {
      if ([((IOSIntArray *) NIL_CHK(freq)) intAtIndex:i] == 0 || [((IOSBooleanArray *) NIL_CHK(tried)) booleanAtIndex:i]) continue;
      int usage = [((IOSIntArray *) NIL_CHK(freq)) intAtIndex:i] + [((IOSIntArray *) NIL_CHK(used)) intAtIndex:i];
      if (usage < min) {
        min = usage;
        ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index = i;
        ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).reason = [NSString stringWithFormat:@"Lowest frequency (%d) plus use count (%d).", [((IOSIntArray *) NIL_CHK(freq)) intAtIndex:i], [((IOSIntArray *) NIL_CHK(used)) intAtIndex:i]];
      }
    }
    if (((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index < 0) {
      ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index = [AqwertianFingeringQwertyMapper getIndexWithUnichar:'A'];
      ((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).reason = @"Could not find an unused finger.";
      break;
    }
    [((IOSBooleanArray *) NIL_CHK(tried)) replaceBooleanAtIndex:((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index withBoolean:YES];
  }
  while ([((AqwertianFingeringQwertyMapper *) NIL_CHK(_mapper_)) ruleFailsWithAqwertianFingeringQwertyMapper_KeyHistory:history withAqwertianFingeringMusicFile_Note:currNote withUnichar:[AqwertianFingeringQwertyMapper getKeyWithInt:((AqwertianFingeringUsageAlgorithm_NextKey *) NIL_CHK(ret)).index]]);
  return ret;
}

- (id<JavaUtilList>)getFirstKeys {
  int count = 0;
  for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(_frequency_)) count]; i++) if ([((IOSIntArray *) NIL_CHK(_frequency_)) intAtIndex:i] != 0) count++;
  IOSIntArray *keys = [[IOSIntArray alloc] initWithLength:count];
  for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(_frequency_)) count]; i++) {
    if ([((IOSIntArray *) NIL_CHK(_frequency_)) intAtIndex:i] != 0) {
      int index;
      do {
        index = [((JavaUtilRandom *) NIL_CHK(_mapper_.rand)) nextIntWithInt:(int) [((IOSIntArray *) NIL_CHK(keys)) count]];
      }
      while ([((IOSIntArray *) NIL_CHK(keys)) intAtIndex:index] != 0);
      [((IOSIntArray *) NIL_CHK(keys)) replaceIntAtIndex:index withInt:i + 1];
    }
  }
  id<JavaUtilList> keyList = [[JavaUtilArrayList alloc] init];
  for (int i = 0; i < (int) [((IOSIntArray *) NIL_CHK(keys)) count]; i++) [((id<JavaUtilList>) NIL_CHK(keyList)) addWithId:[JavaLangInteger valueOfWithInt:[((IOSIntArray *) NIL_CHK(keys)) intAtIndex:i] - 1]];
  return keyList;
}

- (int)matchPatternWithAqwertianFingeringMusicFile_NoteArray:(IOSObjectArray *)notes
                           withAqwertianFingeringPatternList:(AqwertianFingeringPatternList *)patterns
                                                     withInt:(int)count {
  int skip = 0;
  AqwertianFingeringPatternList_Pattern *p = [((AqwertianFingeringPatternList *) NIL_CHK(patterns)) matchPatternWithAqwertianFingeringPatternList_NoteFinder:[[AqwertianFingeringUsageAlgorithm_$1 alloc] initWithAqwertianFingeringUsageAlgorithm:self withInt:count withNSObjectArray:notes]];
  if (p != nil) {
    p.frequency++;
    skip = (int) [((IOSCharArray *) NIL_CHK(p.qwertys)) count];
    for (int i = 0; i < skip; i++) {
      AqwertianFingeringMusicFile_Note *n = [((IOSObjectArray *) NIL_CHK(notes)) objectAtIndex:count + i];
      ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).qwerty = [((IOSCharArray *) NIL_CHK(p.qwertys)) charAtIndex:i];
      ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).reason = [NSString stringWithFormat:@"Pattern %d.%d", p.id_, (i + 1)];
    }
  }
  return skip;
}

- (int)matchChordWithAqwertianFingeringMusicFile_NoteArray:(IOSObjectArray *)notes
                                                   withInt:(int)count {
  int skip = 0;
  AqwertianFingeringMusicFile_Note *start = [((IOSObjectArray *) NIL_CHK(notes)) objectAtIndex:count];
  id<JavaUtilList> chord = [[JavaUtilArrayList alloc] init];
  [((id<JavaUtilList>) NIL_CHK(chord)) addWithId:start];
  for (int i = count + 1; i < (int) [((IOSObjectArray *) NIL_CHK(notes)) count]; i++) {
    AqwertianFingeringMusicFile_Note *n = [((IOSObjectArray *) NIL_CHK(notes)) objectAtIndex:i];
    if (((AqwertianFingeringMusicFile_Note *) NIL_CHK(start)).time == ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).time) [((id<JavaUtilList>) NIL_CHK(chord)) addWithId:n];
  }
  if ([((id<JavaUtilList>) NIL_CHK(chord)) size] >= 3 && [((id<JavaUtilList>) NIL_CHK(chord)) size] <= 4) skip = [self processChordWithJavaUtilList:chord];
  return skip;
}

+ (IOSObjectArray *)_chording {
  return AqwertianFingeringUsageAlgorithm__chording_;
}

+ (void)set_chordingWithAqwertianFingeringUsageAlgorithm_ChordFingerArray:(IOSObjectArray *)_chording {
  AqwertianFingeringUsageAlgorithm__chording_ = _chording;
}

- (int)processChordWithJavaUtilList:(id<JavaUtilList>)chord {
  [JavaUtilCollections sortWithJavaUtilList:chord withJavaUtilComparator:[[AqwertianFingeringUsageAlgorithm_$2 alloc] initWithAqwertianFingeringUsageAlgorithm:self]];
  id<JavaUtilIterator> it = ((id<JavaUtilIterator>) [((id<JavaUtilList>) NIL_CHK(chord)) iterator]);
  AqwertianFingeringMusicFile_Note *start = ((AqwertianFingeringMusicFile_Note *) [((id<JavaUtilIterator>) NIL_CHK(it)) next]);
  AqwertianFingeringUsageAlgorithm_ChordFinger *finger = [self findChordFingeringWithInt:((AqwertianFingeringMusicFile_Note *) NIL_CHK(start)).note];
  ((AqwertianFingeringMusicFile_Note *) NIL_CHK(start)).qwerty = [((IOSCharArray *) NIL_CHK(finger.fingers)) charAtIndex:0];
  ((AqwertianFingeringMusicFile_Note *) NIL_CHK(start)).reason = @"Chord - Base note.";
  int index = 1;
  while ([((id<JavaUtilIterator>) NIL_CHK(it)) hasNext] && index < (int) [((IOSCharArray *) NIL_CHK(finger.fingers)) count]) {
    AqwertianFingeringMusicFile_Note *n = ((AqwertianFingeringMusicFile_Note *) [((id<JavaUtilIterator>) NIL_CHK(it)) next]);
    ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).qwerty = [((IOSCharArray *) NIL_CHK(finger.fingers)) charAtIndex:index];
    ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).reason = @"Chord - continuation.";
    index++;
  }
  return index;
}

- (AqwertianFingeringUsageAlgorithm_ChordFinger *)findChordFingeringWithInt:(int)note {
  for (int i = 0; i < (int) [((IOSObjectArray *) NIL_CHK(AqwertianFingeringUsageAlgorithm__chording_)) count]; i++) {
    if (note <= ((AqwertianFingeringUsageAlgorithm_ChordFinger *) [((IOSObjectArray *) NIL_CHK(AqwertianFingeringUsageAlgorithm__chording_)) objectAtIndex:i]).maxMidi) return [((IOSObjectArray *) NIL_CHK(AqwertianFingeringUsageAlgorithm__chording_)) objectAtIndex:i];
  }
  return nil;
}

+ (void)initialize {
  if (self == [AqwertianFingeringUsageAlgorithm class]) {
    AqwertianFingeringUsageAlgorithm_FREQUENCY_INTERMEDIATE_ = [IOSIntArray arrayWithInts:(int[]){ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 878, 0, 752, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9081, 0, 0, 0, 0, 0, 8255, 439, 815, 9917, 2268, 5340, 5340, 5340, 2442, 5340, 10680, 9154, 439, 439, 2093, 1919, 1744, 1221, 9154, 1221, 1221, 439, 2093, 752, 1221, 0 } count:59];
    AqwertianFingeringUsageAlgorithm_FREQUENCY_BEGINNER_ = [IOSIntArray arrayWithInts:(int[]){ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11000, 0, 0, 0, 0, 0, 10000, 0, 0, 13000, 0, 7000, 7000, 7000, 0, 7000, 14000, 12000, 0, 0, 0, 0, 0, 0, 12000, 0, 0, 0, 0, 0, 0, 0 } count:59];
    AqwertianFingeringUsageAlgorithm_FREQUENCY_ADVANCED_ = [IOSIntArray arrayWithInts:(int[]){ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 877, 0, 985, 985, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8656, 0, 0, 0, 0, 0, 7856, 575, 1068, 9190, 2590, 4878, 4878, 4878, 2779, 4878, 9909, 8472, 575, 575, 2390, 2191, 1992, 1394, 8472, 1390, 1394, 575, 2390, 985, 1394, 821 } count:59];
    AqwertianFingeringUsageAlgorithm_FREQUENCY_EXPERT_ = [IOSIntArray arrayWithInts:(int[]){ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 788, 0, 939, 861, 514, 467, 561, 607, 327, 327, 327, 327, 654, 561, 0, 8264, 0, 0, 0, 0, 0, 7501, 548, 1018, 8773, 2469, 4663, 4663, 4663, 2659, 4663, 9458, 8088, 548, 548, 2279, 2079, 1899, 1329, 8088, 1329, 1329, 548, 2279, 939, 1329, 783 } count:59];
    AqwertianFingeringUsageAlgorithm__chording_ = [IOSObjectArray arrayWithObjects:(id[]){ [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:19 withNSString:@"VCXZ"], [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:31 withNSString:@"FDSA"], [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:43 withNSString:@"REWQ"], [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:55 withNSString:@"4321"], [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:67 withNSString:@"M,./"], [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:79 withNSString:@"JKL;"], [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:91 withNSString:@"UIOP"], [[AqwertianFingeringUsageAlgorithm_ChordFinger alloc] initWithInt:999 withNSString:@"7890"] } count:8 type:[IOSClass classWithClass:[AqwertianFingeringUsageAlgorithm_ChordFinger class]]];
  }
}

@end


@implementation AqwertianFingeringUsageAlgorithm_NextKey

- (int)index {
  return index_;
}

- (void)setIndex:(int)newIndex {
  index_ = newIndex;
}

- (NSString *)reason {
  return reason_;
}

- (void)setReason:(NSString *)newReason {
  reason_ = newReason;
}


@end


@implementation AqwertianFingeringUsageAlgorithm_ChordFinger

- (int)maxMidi {
  return maxMidi_;
}

- (void)setMaxMidi:(int)newMaxMidi {
  maxMidi_ = newMaxMidi;
}

- (IOSCharArray *)fingers {
  return fingers_;
}

- (void)setFingers:(IOSCharArray *)newFingers {
  fingers_ = newFingers;
}


- (id)initWithInt:(int)max
     withNSString:(NSString *)f {
  if ((self = [super init])) {
    maxMidi_ = max;
    fingers_ = [[IOSCharArray alloc] initWithLength:4];
    [((IOSCharArray *) NIL_CHK(fingers_)) replaceCharAtIndex:0 withChar:[NIL_CHK(f) charAtWithInt:0]];
    [((IOSCharArray *) NIL_CHK(fingers_)) replaceCharAtIndex:1 withChar:[NIL_CHK(f) charAtWithInt:1]];
    [((IOSCharArray *) NIL_CHK(fingers_)) replaceCharAtIndex:2 withChar:[NIL_CHK(f) charAtWithInt:2]];
    [((IOSCharArray *) NIL_CHK(fingers_)) replaceCharAtIndex:3 withChar:[NIL_CHK(f) charAtWithInt:3]];
  }
  return self;
}

@end


@implementation AqwertianFingeringUsageAlgorithm_$1

- (AqwertianFingeringUsageAlgorithm *)this$0 {
  return this$0_;
}

- (void)setThis$0:(AqwertianFingeringUsageAlgorithm *)newThis$0 {
  this$0_ = newThis$0;
}

- (int)val$count {
  return val$count_;
}

- (void)setVal$count:(int)newVal$count {
  val$count_ = newVal$count;
}

- (IOSObjectArray *)val$notes {
  return val$notes_;
}

- (void)setVal$notes:(IOSObjectArray *)newVal$notes {
  val$notes_ = newVal$notes;
}


- (int)getNoteWithInt:(int)index {
  if (val$count_ + index >= (int) [((IOSObjectArray *) NIL_CHK(val$notes_)) count]) return -1;
  AqwertianFingeringMusicFile_Note *n = [((IOSObjectArray *) NIL_CHK(val$notes_)) objectAtIndex:val$count_ + index];
  return ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n)).note;
}

- (id)initWithAqwertianFingeringUsageAlgorithm:(AqwertianFingeringUsageAlgorithm *)outer$2
                                       withInt:(int)outer$0
                             withNSObjectArray:(IOSObjectArray *)outer$1 {
  if ((self = [super init])) {
    this$0_ = outer$2;
    val$count_ = outer$0;
    val$notes_ = outer$1;
  }
  return self;
}

@end


@implementation AqwertianFingeringUsageAlgorithm_$2

- (AqwertianFingeringUsageAlgorithm *)this$0 {
  return this$0_;
}

- (void)setThis$0:(AqwertianFingeringUsageAlgorithm *)newThis$0 {
  this$0_ = newThis$0;
}


- (int)compareWithId:(AqwertianFingeringMusicFile_Note *)n1
              withId:(AqwertianFingeringMusicFile_Note *)n2 {
  return ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n1)).note - ((AqwertianFingeringMusicFile_Note *) NIL_CHK(n2)).note;
}

- (id)initWithAqwertianFingeringUsageAlgorithm:(AqwertianFingeringUsageAlgorithm *)outer$0 {
  if ((self = [super init])) {
    this$0_ = outer$0;
  }
  return self;
}

@end

