//
//  AQSwitch.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 3/28/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AQSwitch : UIImageView

@property (nonatomic) id target;
@property (nonatomic) SEL selector;
@property (nonatomic) BOOL on;

@end
