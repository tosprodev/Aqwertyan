//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/nziebart/GoogleDrive/Aqwertian/Aqwertian/fingering/util/StringTokenizer.java
//
//  Created by nziebart on 9/17/12.
//

@class IOSIntArray;

#import "JreEmulation.h"
#import "java/util/Enumeration.h"

@interface AqwertianFingeringUtilStringTokenizer : NSObject < JavaUtilEnumeration > {
 @public
  int currentPosition_;
  int newPosition_;
  int maxPosition_;
  NSString *str_;
  NSString *delimiters_;
  BOOL retDelims_;
  BOOL delimsChanged_;
  int maxDelimCodePoint_;
  BOOL hasSurrogates_;
  IOSIntArray *delimiterCodePoints_;
}

@property (nonatomic, assign) int currentPosition;
@property (nonatomic, assign) int newPosition;
@property (nonatomic, assign) int maxPosition;
@property (nonatomic, copy) NSString *str;
@property (nonatomic, copy) NSString *delimiters;
@property (nonatomic, assign) BOOL retDelims;
@property (nonatomic, assign) BOOL delimsChanged;
@property (nonatomic, assign) int maxDelimCodePoint;
@property (nonatomic, assign) BOOL hasSurrogates;
@property (nonatomic, strong) IOSIntArray *delimiterCodePoints;

- (void)setMaxDelimCodePoint;
- (id)initWithNSString:(NSString *)str
          withNSString:(NSString *)delim
              withBOOL:(BOOL)returnDelims;
- (id)initWithNSString:(NSString *)str
          withNSString:(NSString *)delim;
- (id)initWithNSString:(NSString *)str;
- (int)skipDelimitersWithInt:(int)startPos;
- (int)scanTokenWithInt:(int)startPos;
- (BOOL)isDelimiterWithInt:(int)codePoint;
- (BOOL)hasMoreTokens;
- (NSString *)nextToken;
- (NSString *)nextTokenWithNSString:(NSString *)delim;
- (BOOL)hasMoreElements;
- (id)nextElement;
- (int)countTokens;
@end