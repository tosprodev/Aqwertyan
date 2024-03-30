//
//  MeasureClass.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 10/17/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "MeasureClass.h"


@implementation MeasureClass

+ (id)initWith:(Measure *)aMeasure {
    MeasureClass *theClass = [MeasureClass new];
    theClass.Measure = aMeasure;
    return  theClass;
}

@end;