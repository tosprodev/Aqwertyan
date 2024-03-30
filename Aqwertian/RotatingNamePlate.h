//
//  RotatingNamePlate.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/10/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RotatingNamePlate : UIView

- (void) setSong:(NSString *)text;
- (void) setProgramName:(NSString *)text;

- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;

- (void) flashSongName;
- (void) updateProgram;

- (int) program;
@end
