//
//  LyricView.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/12/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteView.h"

@interface LyricView : UILabel

- (void) setState:(NSInteger)state;
- (void) setState:(NSInteger)state animated:(BOOL)animated;
- (void) setLyric:(NSString *)lyric;

@end
