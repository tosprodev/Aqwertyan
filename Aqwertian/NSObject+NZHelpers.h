//
//  NSObject+NZHelpers.h
//  PodcastTestCreator
//
//  Created by Nathan Ziebart on 5/10/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NZHelpers) {
    
}

- (void) onChangeOf:(NSString *)keyPath observer:(id)observer do:(void (^)(NSDictionary *change))block;
- (void) removeBlockObserver:(id)observer;
- (void) removeBlockObserver:(id)observer forKeyPath:(NSString *)keyPath;

- (void) triggerEvent:(NSString *)event withArgs:(id)args;
- (void) onEvent:(NSString *)event do:(void (^)(id sender, id args))block;
- (void) cancelBlocksForEvent:(NSString *)event;


@end
