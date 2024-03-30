//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/Documents/MusFingering/com/aqwertian/fingering/MusicFile.java
//
//  Created by nziebart on 1/27/13.
//

@class ComAqwertianFingeringMusicFile_Note;
@class IOSByteArray;
@class IOSObjectArray;
@class JavaIoInputStream;
@protocol JavaUtilCollection;
@protocol JavaUtilList;
@protocol JavaUtilMap;

#import "JreEmulation.h"
#import "java/lang/Comparable.h"

@interface ComAqwertianFingeringMusicFile : NSObject {
 @public
  id<JavaUtilMap> _notes_;
}

@property (nonatomic, strong) id<JavaUtilMap> _notes;

- (id)init;
- (int)getChannelCount;
- (id<JavaUtilList>)getNotesWithJavaUtilCollection:(id<JavaUtilCollection>)channels;
- (void)sortNotesWithJavaUtilList:(id<JavaUtilList>)notes;
- (BOOL)sameNoteWithComAqwertianFingeringMusicFile_Note:(ComAqwertianFingeringMusicFile_Note *)n1
                withComAqwertianFingeringMusicFile_Note:(ComAqwertianFingeringMusicFile_Note *)n2;
- (id<JavaUtilList>)extractNotesWithJavaUtilCollection:(id<JavaUtilCollection>)channels;
- (int)readWithJavaIoInputStream:(JavaIoInputStream *)inArg;
- (void)readWithJavaIoInputStream:(JavaIoInputStream *)inArg
            withJavaLangByteArray:(IOSByteArray *)buff
                          withInt:(int)length;
@end

@interface ComAqwertianFingeringMusicFile_Note : NSObject < JavaLangComparable > {
 @public
  int channel_;
  int time_;
  int duration_;
  int note_;
  int volume_;
  int rate_;
  NSString *lyrics_;
  char qwerty_;
  NSString *reason_;
}

@property (nonatomic, assign) int channel;
@property (nonatomic, assign) int time;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int note;
@property (nonatomic, assign) int volume;
@property (nonatomic, assign) int rate;
@property (nonatomic, assign) BOOL isTrill;
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, assign) char qwerty;
@property (nonatomic, assign) char noteOffKey;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, assign) int timePlayed;
@property (nonatomic, assign) int timeFinished;
@property (nonatomic, assign) int actualNotePlayed;
@property (nonatomic, assign) BOOL tie, removedFromUserNotes, autoPlayed;

#define NOT_PLAYED 0
#define SKIPPED 1
#define PLAYING 2
#define PLAYED 3
#define UPCOMING 4

@property (nonatomic, assign) int state;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) UIView *noteView;
@property (nonatomic, retain) NSArray *tieNotes;
@property (nonatomic, retain) NSMutableArray *overlays;
@property (nonatomic, assign) int timing, chord;
@property (nonatomic, assign) BOOL heldForRightDuration;

- (id)initWithInt:(int)channel
          withInt:(int)time
          withInt:(int)duration
          withInt:(int)note
          withInt:(int)volume
          withInt:(int)rate
     withNSString:(NSString *)lyrics;
+ (IOSObjectArray *)NOTES;
- (NSString *)getNoteName;
+ (NSString *)getNoteNameWithInt:(int)note;
- (int)getOctave;
+ (int)getOctaveWithInt:(int)note;
- (NSString *)getNoteValue;
+ (NSString *)getNoteValueWithInt:(int)note;
- (BOOL)overlapsWithComAqwertianFingeringMusicFile_Note:(ComAqwertianFingeringMusicFile_Note *)n;
- (int)compareToWithId:(ComAqwertianFingeringMusicFile_Note *)n;
- (NSString *)description;
- (NSComparisonResult) compare:(ComAqwertianFingeringMusicFile_Note *)n;

@end

typedef ComAqwertianFingeringMusicFile_Note RGNote;
