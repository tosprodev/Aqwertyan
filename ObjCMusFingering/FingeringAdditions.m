//
//  FingeringAdditions.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 6/6/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "FingeringAdditions.h"

@implementation FingeringAdditions

static NSMutableSet *validChords;
static NSMutableSet *validCombinations;
static BOOL isRightHand[100];

+ (void)initialize {
    validChords = [NSMutableSet new];
    NSArray *combinations = @[@"QR", @"QT", @"QG", @"QV", @"QB", @"WE", @"WR", @"WT", @"WF", @"WG", @"ER", @"ET", @"EF", @"RA", @"AF", @"AG", @"AV", @"AB", @"SD", @"SF", @"SG", @"SV", @"SB", @"DF", @"DG", @"DC", @"DV", @"DB", @"GZ", @"GX", @"ZV", @"ZB", @"XC", @"XV", @"XB", @"CV",
        @"YP", @"UI", @"UO", @"UP", @"U;", @"IO", @"IH", @"IJ", @"IN", @"IM", @"OH", @"OJ", @"ON", @"HK", @"HL", @"H;", @"JK", @"JL", @"J;", @"KL", @"KN", @"KM", @"LN", @"LM", @"NM", @"N,", @"N.", @"M,", @"M.", @",.",];
    NSArray *chords = @[@"WE",@"WR",@"ER",@"SD",@"SF",@"DF",@"XC",@"XV",@"CV",@"CB",
                        @"OI",@"OU",@"LK",@"LJ",@"KJ"@"KH"];
    for (NSString *s in combinations) {
        
        // Add each chord and its reverse
        [validCombinations addObject:s];
        [validCombinations addObject:[NSString stringWithFormat:@"%c%c", [s characterAtIndex:1], [s characterAtIndex:0]]];
    }
    
    for (NSString *s in chords) {
        [validChords addObject:s];
    }
    
    NSArray *fingers = @[@"R00", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"R21", @"", @"R31", @"R41", @"R44", @"L44", @"L34", @"L24", @"L14", @"L14", @"R14", @"R14", @"R24", @"R34", @"", @"R42", @"", @"", @"", @"", @"", @"L42", @"L11", @"L21", @"L22", @"L23", @"L12", @"L12", @"R12", @"R23", @"R12", @"R22", @"R32", @"R11", @"R11", @"R33", @"R43", @"L43", @"L13", @"L32", @"L13", @"R13", @"L11", @"L33", @"L31", @"R13", @"L41"];
    for (int i = 0; i < fingers.count; i++) {
        NSString *finger = fingers[i];
        isRightHand[i] = finger.length && [finger characterAtIndex:0] == 'R';
    }
}

BOOL chordIsValid(char c1, char c2, int time1, int time2, int quantum) {
    if (!validChords) {
        [FingeringAdditions initialize];
    }
    bool isChord = ABS(time1 - time2) <= quantum;
    if (!isChord) {
        if (isRightHand[c1 - ' '] ^ isRightHand[c2 - ' ']) {
            return YES;
        }
    }
    NSString *s = [NSString stringWithFormat:@"%c%c", c1, c2];
    if (isChord) {
        return [validChords containsObject:s];
    } else {
        return [validCombinations containsObject:s];
    }
}

@end
