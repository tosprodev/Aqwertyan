//
//  NSObject+NZHelpers.m
//  PodcastTestCreator
//
//  Created by Nathan Ziebart on 5/10/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "NSObject+NZHelpers.h"
#import <objc/runtime.h>
typedef void(^Block)(NSDictionary *change);

static char *MGObserversKey = "bob123__";
static char *MGEventHandlersKey;

typedef void (^MHChannelsBlock)(id sender, id dictionary);

@interface MGObserver : NSObject

@property (nonatomic, weak) NSObject *observee;
@property (nonatomic, weak) id observer;
@property (nonatomic, copy) NSString *keypath;
@property (nonatomic, copy) Block block;

+ (MGObserver *)observer:(id)observer for:(NSObject *)object keypath:(NSString *)keypath
                      block:(Block)block;

@end

@implementation MGObserver

+ (MGObserver *)observer:(id)anObserver for:(NSObject *)object keypath:(NSString *)keypath block:(Block)block {
    MGObserver *observer = [[MGObserver alloc] init];
    observer.observee = object;
    observer.keypath = keypath;
    observer.block = block;
    observer.observer = anObserver;
    [object addObserver:observer forKeyPath:keypath options:0 context:nil];
    return observer;
}

- (void)observeValueForKeyPath:(NSString *)keypath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (self.block) {
        self.block(change);
    }
}

- (void)dealloc {
    [self.observee removeObserver:self forKeyPath:self.keypath];
}

@end


@interface MHChannelListener : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, copy) MHChannelsBlock block;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) dispatch_queue_t queue;

@end

@implementation MHChannelListener

@synthesize object;
@synthesize block;
@synthesize priority;
@synthesize queue;

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ object = %@", [super description], object];
}

@end

@implementation NSObject (NZHelpers)

- (void)triggerEvent:(NSString *)event withArgs:(NSDictionary *)args {
    [self mh_post:args toChannel:event];
}

- (void)cancelBlocksForEvent:(NSString *)event {
    [self mh_removeFromChannel:event];
}

- (void)onEvent:(NSString *)event do:(void (^)(id, id))block {
    [self mh_listenOnChannel:event block:block];
}

- (void)onChangeOf:(NSString *)keyPath observer:(id)anObserver do:(void (^)(id))block {
    // get observers for this keypath
    NSMutableArray *observers = self.MGObservers[keyPath];
    if (!observers) {
        observers = @[].mutableCopy;
        self.MGObservers[keyPath] = observers;
        
    }
    
    // make and store an observer
    MGObserver *observer = [MGObserver observer:anObserver for:self keypath:keyPath block:block];
    [observers addObject:observer];
}

- (void)removeBlockObserver:(id)observer {
    for (NSArray *observers in self.MGObservers.allValues) {
        NSMutableArray *toRemove = [NSMutableArray new];
        for (MGObserver *obs in observers) {
            if (obs.observer == observer) {
                [toRemove addObject:obs];
            }
        }
        [observer removeObjectsInArray:toRemove];
    }
}

- (void)removeBlockObserver:(id)observer forKeyPath:(NSString *)keyPath {
    if (!self.MGObservers[keyPath]) return;
    
    NSMutableArray *toRemove = [NSMutableArray new];
    for (MGObserver *obs in self.MGObservers[keyPath]) {
        if (obs.observer == observer) {
            [toRemove addObject:obs];
        }
    }
    [observer removeObjectsInArray:toRemove];
}

#pragma mark - Property observing

#pragma mark - Getters

- (NSMutableDictionary *)MGObservers {
    id observers = objc_getAssociatedObject(self, MGObserversKey);
    if (!observers) {
        observers = @{ }.mutableCopy;
        self.MGObservers = observers;
    }
    return observers;
}

#pragma mark - Setters

- (void)setMGObservers:(NSMutableDictionary *)observers {
    objc_setAssociatedObject(self, MGObserversKey, observers,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)mh_channelsDictionary
{
	static dispatch_once_t pred;
	static NSMutableDictionary *dictionary;
	dispatch_once(&pred, ^{ dictionary = [NSMutableDictionary dictionaryWithCapacity:4]; });
	return dictionary;
}

- (void)mh_pruneDeadListenersFromChannel:(NSString *)channelName
{
	NSMutableDictionary *channelsDictionary = [self mh_channelsDictionary];
	NSMutableArray *listeners = [channelsDictionary objectForKey:channelName];
    
	NSMutableSet *listenersToRemove = nil;
    
	for (MHChannelListener *listener in listeners)
	{
		if (listener.object == nil)
		{
			if (listenersToRemove == nil)
				listenersToRemove = [NSMutableSet set];
            
			[listenersToRemove addObject:listener];
		}
	}
    
	if (listenersToRemove != nil)
	{
		for (MHChannelListener *listener in listenersToRemove)
			[listeners removeObject:listener];
        
		if ([listeners count] == 0)
			[channelsDictionary removeObjectForKey:channelName];
	}
}

- (void)mh_post:(NSDictionary *)dictionary toChannel:(NSString *)channelName
{
	NSParameterAssert(channelName != nil);
    
	NSMutableDictionary *channelsDictionary = [self mh_channelsDictionary];
	@synchronized (channelsDictionary)
	{
		NSMutableArray *listeners = [channelsDictionary objectForKey:channelName];
		if (listeners != nil)
		{
			for (MHChannelListener *listener in listeners)
			{
				if (listener.object != nil)
				{
					if (listener.queue == nil)
						listener.block(listener, dictionary);
					else
						dispatch_async(listener.queue, ^{ listener.block(listener, dictionary); });
				}
			}
            
			[self mh_pruneDeadListenersFromChannel:channelName];
		}
	}
}

- (void)mh_listenOnChannel:(NSString *)channelName block:(MHChannelsBlock)block
{
	[self mh_listenOnChannel:channelName priority:0 queue:nil block:block];
}

- (void)mh_listenOnChannel:(NSString *)channelName priority:(NSInteger)priority queue:(dispatch_queue_t)queue block:(MHChannelsBlock)block
{
	NSParameterAssert(channelName != nil);
	NSParameterAssert(block != nil);
    
	NSMutableDictionary *channelsDictionary = [self mh_channelsDictionary];
	@synchronized (channelsDictionary)
	{
		NSMutableArray *listeners = [channelsDictionary objectForKey:channelName];
		if (listeners == nil)
		{
			listeners = [NSMutableArray arrayWithCapacity:2];
			[channelsDictionary setObject:listeners forKey:channelName];
		}
        
        // Don't allow the same object to re-add inself to the list
        NSMutableArray *toRemove = @[].mutableCopy;
        for (MHChannelListener *listener in listeners) {
            if (listener.object == self) {
                [toRemove addObject:listener];
            }
        }
        [listeners removeObjectsInArray:toRemove];
        
		MHChannelListener *listener = [[MHChannelListener alloc] init];
		listener.object = self;
		listener.block = block;
		listener.priority = priority;
		listener.queue = queue;
        
		[listeners addObject:listener];
		[self mh_pruneDeadListenersFromChannel:channelName];
        
		[listeners sortUsingComparator:^(MHChannelListener *obj1, MHChannelListener *obj2)
         {
             if (obj1.priority < obj2.priority)
                 return NSOrderedDescending;
             else if (obj1.priority > obj2.priority)
                 return NSOrderedAscending;
             else
                 return NSOrderedSame;
         }];
	}
}

- (void)mh_removeFromChannel:(NSString *)channelName
{
	NSParameterAssert(channelName != nil);
    
	NSMutableDictionary *channelsDictionary = [self mh_channelsDictionary];
	@synchronized (channelsDictionary)
	{
		NSMutableArray *listeners = [channelsDictionary objectForKey:channelName];
		if (listeners != nil)
		{
			for (MHChannelListener *listener in listeners)
			{
				if (listener.object == self)
					listener.object = nil;
			}
            
			[self mh_pruneDeadListenersFromChannel:channelName];
		}
	}
}

- (void)mh_debugChannels
{
	NSMutableDictionary *channelsDictionary = [self mh_channelsDictionary];
	@synchronized (channelsDictionary)
	{
		NSLog(@"Channels dictionary: %@", channelsDictionary);
	}
}



@end
