//
//  NZURLRequest.h
//  Bridge
//
//  Created by Nathan Ziebart on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



//
//  NZURLRequest.h
//  Bridge
//
//  Created by Nathan Ziebart on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#define NZURL_TIMEOUT 1
#define NZURL_ERROR_RESULTS 2
#define NZURL_ERROR_NORESULTS 3
#define NZURL_SUCCESS 4


@interface NZURLConnection : NSURLConnection <NSURLConnectionDelegate>

@property (strong) NSMutableData *storageData;
@property (strong) void (^handler)(BOOL,NSData *);
@property (strong) void (^results_handler)(int,NSDictionary *);

+ (NZURLConnection *) sendAsynchronousRequest:(NSMutableURLRequest *)aRequest completionHandler:(void (^) (BOOL didSucceed, NSData *theResponse))aHandler;
+ (NZURLConnection *) postObject:(NSObject *)anObject toURL:(NSString *)aURL withTimeout:(NSInteger)aTimeout completionHandler:(void (^)(BOOL, NSData *))aHandler;

+ (NZURLConnection *) postObject:(NSObject *)anObject toURL:(NSString *)aURL withTimeout:(NSInteger)aTimeout easyCompletionHandler:(void (^)(int, NSDictionary *))aHandler;
+ (NZURLConnection *) getAsynchronousResponseFromURL:(NSString *)aURL withTimeout:(NSInteger)aTimeout completionHandler:(void (^)(BOOL, NSData *))aHandler;
- (id) initWithRequest:(NSURLRequest *)request;
- (void) startWithTimeout:(NSInteger)aTimeout;


@end
