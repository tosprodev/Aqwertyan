//
//  FingeringTest.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 5/31/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "FingeringTest.h"
#import "QwertyMapper.h"
#import "FingeringAdditions.h"

@implementation FingeringTest

#import <Foundation/Foundation.h>

#define RIGHT_HAND @"qwertasdfgzxcvb"
#define LEFT_HAND @"yuiophjkl;nm,./"

NSArray *genCombos(NSString *chars) {
    NSMutableArray *combos = [NSMutableArray new];
    
    for (int i = 0; i < chars.length; i++) {
        for (int j = i+1; j < chars.length; j++) {
            char c1 = [chars characterAtIndex:i];
            char c2 = [chars characterAtIndex:j];
            NSString *s = [NSString stringWithFormat:@"%c%c", c1, c2];
            [combos addObject:s.uppercaseString];
        }
    }
    
    return combos;
}

- (void) jimTest {
    ComAqwertianFingeringQwertyMapper *qm = [ComAqwertianFingeringQwertyMapper new];
    
    NSString *f1 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:'R'];
    NSString *f2 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:'B'];
    
    BOOL isViable = ![qm isImpossibleFingerWithNSString:f1 withNSString:f2];
   // BOOL newViable = chordIsValid('R', 'B');
  //  NSLog(@"old: %c, new: %c", isViable, newViable);
}

- (void) doTests {
        NSArray *rh = genCombos(RIGHT_HAND);
        NSArray *lh = genCombos(LEFT_HAND);
    
    NSMutableString *rhCSV  = [NSMutableString new];
    NSMutableString *lhCSV = [NSMutableString new];
    
    ComAqwertianFingeringQwertyMapper *qm = [ComAqwertianFingeringQwertyMapper new];
    
    for (NSString *combo in rh) {
        NSString *f1 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:[combo characterAtIndex:0]];
        NSString *f2 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:[combo characterAtIndex:1]];
        BOOL isViable = ![qm isImpossibleFingerWithNSString:f1 withNSString:f2];
        [rhCSV appendFormat:@"%@,%@\n", combo, isViable ? @"X" : @"" ];
    }
    
    for (NSString *combo in lh) {
        NSString *f1 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:[combo characterAtIndex:0]];
        NSString *f2 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:[combo characterAtIndex:1]];
        BOOL isViable = ![qm isImpossibleFingerWithNSString:f1 withNSString:f2];
        [lhCSV appendFormat:@"%@,%@\n", combo, isViable ? @"X" : @"" ];
    }
    
        [rhCSV writeToFile:@"/Users/nziebart/Dropbox/right_hand.csv" atomically:NO encoding:NSUTF8StringEncoding error:nil];
        [lhCSV writeToFile:@"/Users/nziebart/Dropbox/left_hand.csv" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *test = @{@"ZC" : @(YES),
                           @";N" : @(YES),
                           @"GV" : @(NO),
                           @"DZ" : @(YES),
                           @"AC" : @(YES),
                           @"H," : @(NO)};
    
    for (NSString *key in test.allKeys) {
        NSString *f1 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:[key characterAtIndex:0]];
        NSString *f2 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:[key characterAtIndex:1]];
        BOOL isViable = ![qm isImpossibleFingerWithNSString:f1 withNSString:f2];
        if (isViable != [test[key] boolValue]) {
            NSLog(@"test failed");
        }
    }
    
    NSString *f1 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:'C'];
    NSString *f2 = [ComAqwertianFingeringQwertyMapper getFingerWithInt:'V'];
    [qm isImpossibleFingerWithNSString:f1 withNSString:f2];
        
    }



@end
