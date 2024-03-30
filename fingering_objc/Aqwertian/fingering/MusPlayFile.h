//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/MusPlayFile.java
//
//  Created by nziebart on 9/17/12.
//

@class AqwertianFingeringMusPlayFile_MusPlayNote;
@class AqwertianFingeringMusPlayFile_MusPlayNote_Duration;
@class AqwertianFingeringUtilStringTokenizer;
@class IOSObjectArray;
@class JavaIoInputStream;
@class JavaIoOutputStream;
@class JavaIoPrintWriter;
@protocol JavaUtilCollection;
@protocol JavaUtilList;

#import "JreEmulation.h"
#import "Aqwertian/fingering/MusicFile.h"
#import "java/lang/Comparable.h"

@interface AqwertianFingeringMusPlayFile : AqwertianFingeringMusicFile {
 @public
  NSString *_name_;
  id<JavaUtilList> _events_;
  id<JavaUtilList> _repeats_;
}

@property (nonatomic, copy) NSString *_name;
@property (nonatomic, retain) id<JavaUtilList> _events;
@property (nonatomic, retain) id<JavaUtilList> _repeats;

+ (NSString *)INDENT;
- (id)initWithJavaIoInputStream:(JavaIoInputStream *)inArg;
- (void)addNoteWithAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)note;
- (void)setNoteDurationWithAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)note
                           withAqwertianFingeringUtilStringTokenizer:(AqwertianFingeringUtilStringTokenizer *)tok;
- (int)getNoteWithNSString:(NSString *)cmd
withAqwertianFingeringUtilStringTokenizer:(AqwertianFingeringUtilStringTokenizer *)tok;
- (int)calcNoteWithNSString:(NSString *)cmd
               withNSString:(NSString *)note
                    withInt:(int)base
withAqwertianFingeringUtilStringTokenizer:(AqwertianFingeringUtilStringTokenizer *)tok;
- (int)calcOctaveWithInt:(int)base
                 withInt:(int)octave;
+ (IOSObjectArray *)TONE;
- (NSString *)calcMusPlayToneWithInt:(int)note;
- (int)calcMusPlayOctaveWithInt:(int)note;
- (void)resetDurationWithAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)note;
- (int)getChannelCount;
- (id<JavaUtilList>)extractNotesWithJavaUtilCollection:(id<JavaUtilCollection>)channels;
- (void)processRepeats;
- (void)storeWithJavaIoOutputStream:(JavaIoOutputStream *)o;
- (void)processMetaInfoWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)prev
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)n;
- (void)processMeasureWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)prev
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)n;
- (void)processLineWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)prev
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)n;
- (void)processVolumeWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)prev
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)n;
- (void)processNoteWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)prev
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)n;
- (void)outputNoteWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)n;
- (void)outputDurationWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote_Duration:(AqwertianFingeringMusPlayFile_MusPlayNote_Duration *)d;
- (void)outputBeatsWithJavaIoPrintWriter:(JavaIoPrintWriter *)outArg
withAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)prev;
- (NSString *)toMusPlayNoteWithInt:(int)note;
- (NSString *)description;
@end

@interface AqwertianFingeringMusPlayFile_MusPlayNote : AqwertianFingeringMusicFile_Note < NSCopying > {
 @public
  AqwertianFingeringMusPlayFile_MusPlayNote_Duration *meter_;
  NSString *key_;
  NSString *tempo_;
  int measure_;
  NSString *line_;
  int volume_;
  AqwertianFingeringMusPlayFile_MusPlayNote_Duration *length_;
  int sequence_;
}

@property (nonatomic, retain) AqwertianFingeringMusPlayFile_MusPlayNote_Duration *meter;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *tempo;
@property (nonatomic, assign) int measure;
@property (nonatomic, copy) NSString *line;
@property (nonatomic, assign) int volume;
@property (nonatomic, retain) AqwertianFingeringMusPlayFile_MusPlayNote_Duration *length;
@property (nonatomic, assign) int sequence;

- (id)init;
- (id)initWithAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)previous;
- (id)clone;
- (NSString *)description;
- (int)compareToWithAqwertianFingeringMusicFile_Note:(AqwertianFingeringMusicFile_Note *)note;
- (void)addDurationWithAqwertianFingeringMusPlayFile_MusPlayNote:(AqwertianFingeringMusPlayFile_MusPlayNote *)toAdd;
- (id)copyWithZone:(NSZone *)zone;
@end

@interface AqwertianFingeringMusPlayFile_MusPlayNote_Duration : NSObject < JavaLangComparable, NSCopying > {
 @public
  int num_;
  int denom_;
  int divisor_;
  BOOL _reducable_;
}

@property (nonatomic, assign) int num;
@property (nonatomic, assign) int denom;
@property (nonatomic, assign) int divisor;
@property (nonatomic, assign) BOOL _reducable;

- (id)init;
- (id)initWithBOOL:(BOOL)reducable;
- (void)addWithAqwertianFingeringMusPlayFile_MusPlayNote_Duration:(AqwertianFingeringMusPlayFile_MusPlayNote_Duration *)toAdd;
- (void)subtractWithAqwertianFingeringMusPlayFile_MusPlayNote_Duration:(AqwertianFingeringMusPlayFile_MusPlayNote_Duration *)toSub;
- (int)compareToWithId:(AqwertianFingeringMusPlayFile_MusPlayNote_Duration *)toComp;
- (BOOL)isEqual:(id)o;
- (id)clone;
- (void)reduce;
- (NSString *)description;
- (id)copyWithZone:(NSZone *)zone;
@end

@interface AqwertianFingeringMusPlayFile_Repeat : NSObject {
 @public
  int start_;
  int end_;
  int repeat_at_;
}

@property (nonatomic, assign) int start;
@property (nonatomic, assign) int end;
@property (nonatomic, assign) int repeat_at;

@end
