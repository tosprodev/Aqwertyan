//
//  MusFileManager.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/25/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "MusFileManager.h"
//#import "Structs.h"
//#import "Mus.h"

@interface MusFileManager ()

//- (Piece *)readMusFile:(NSString *)s;

@end

@implementation MusFileManager {
    char *filename;
    int m_SM;
    int can_restore;
}

+ (MusFileManager *)sharedManager {
    static MusFileManager *theManager = nil;
    
    if (theManager == nil)
        theManager = [MusFileManager new];
    
    return theManager;
}

//+ (void)setDifficulty:(NSInteger)aDifficulty forPiece:(Piece *)aPiece {
//    if (aDifficulty == CHORDED) {
//        [ doChording:aPiece];
//    }
//}


//- (Piece *)loadMusFile:(NSString *)aFileName {
//    char *s;
//	Piece *p2;
//	Measure *m;
//    char *fname = [aFileName cStringUsingEncoding:NSUTF8StringEncoding];
// 
//	s = (char *) malloc(sizeof(char)*(strlen(fname)+1));
//	strcpy(s, fname);
//	p2 = [InputHandler readMusFile:s];
//    //[InputHandler removeExmatch:p2];
// 
//	if (p2 == NULL) {
//		if (filename == NULL) filename = s; else free(s);
//		return nil;
//	}
//    
//	if (filename == NULL || strcmp(filename, fname) != 0) {
//		if (rb_empty(p2->measures)) {
//			m_SM = 1;
//		} else {
//			m = (Measure *) rb_first(p2->measures)->v.val;
//			m_SM = m->number;
//		}
//	}
//    
//	if (filename != NULL) free(filename);
//	filename = s;
//	return p2;
//	
//	can_restore = 0;
//	return TRUE;
//}






@end
