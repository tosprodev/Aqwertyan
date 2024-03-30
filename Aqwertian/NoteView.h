//
//  NoteView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicFile.h"

#define LEFT_HAND 1
#define RIGHT_HAND 2

#define NORMAL 1
#define PLAYING 2
#define PLAYED 3
#define SHADOW 4
#define HIGHLIGHTED 5
#define PLAYED_TOO_LATE 6
#define PLAYED_TOO_EARLY 7

@interface NoteView : UIImageView

@property (nonatomic) NSString *Note;
@property (nonatomic) NSInteger Hand;
@property (nonatomic) BOOL attachLeft, attachRight;
@property (nonatomic) RGNote *rgNote;
@property (nonatomic) BOOL isFirstHalf;

+ (UIImage *)rightHandImage;
+ (UIImage *)leftHandImage;

- (void) setState:(NSInteger)state duration:(NSTimeInterval)dur;
- (void) setState:(NSInteger)state modifier:(int)modifier duration:(NSTimeInterval)dur;
- (void) setColumn:(char)aColumn;
- (int) state;
- (void) addAttachedView:(NoteView *)view;

- (void) showAttachedViews;

- (void) collapseAttachedViews;

@end
