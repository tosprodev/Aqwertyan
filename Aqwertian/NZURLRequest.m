//
//  NZURLRequest.m
//  Bridge
//
//  Created by Nathan Ziebart on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NZURLRequest.h"

@implementation NZURLConnection {
    bool completed;
}

@synthesize storageData, handler;

- (id)initWithRequest:(NSURLRequest *)request {
    if (self = [super initWithRequest:request delegate:self]) {
        //[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        
        self.storageData = [[NSMutableData alloc] init];
        completed = NO;
    }
    return self;
}



+ (NZURLConnection *)sendAsynchronousRequest:(NSMutableURLRequest *)aRequest completionHandler:(void (^)(BOOL, NSData *))aHandler {
    NZURLConnection *theConnection = [[NZURLConnection alloc] initWithRequest:aRequest];
    theConnection.handler = aHandler;
    [theConnection startWithTimeout:10];
    
    return theConnection;
}

+ (NZURLConnection *)postObject:(NSObject *)anObject toURL:(NSString *)aURL withTimeout:(NSInteger)aTimeout completionHandler:(void (^)(BOOL, NSData *))aHandler {
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    theRequest.timeoutInterval = aTimeout;
    //[theRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    [theRequest setHTTPMethod:@"POST"];
    
    NSData *theData = [NSJSONSerialization dataWithJSONObject:anObject options:kNilOptions error:nil];
    
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:[NSString stringWithFormat:@"%d", [theData length]] forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:theData];
    
    NZURLConnection *theConnection = [[NZURLConnection alloc] initWithRequest:theRequest];
    theConnection.handler = aHandler;
    [theConnection startWithTimeout:aTimeout];
    
    return theConnection;
}

+ (NZURLConnection *)postObject:(NSObject *)anObject toURL:(NSString *)aURL withTimeout:(NSInteger)aTimeout easyCompletionHandler:(void (^)(int, NSDictionary *))aHandler {
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    theRequest.timeoutInterval = aTimeout;
    //[theRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    [theRequest setHTTPMethod:@"POST"];
    
    NSData *theData = [NSJSONSerialization dataWithJSONObject:anObject options:kNilOptions error:nil];
    
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:[NSString stringWithFormat:@"%d", [theData length]] forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:theData];
    
    NZURLConnection *theConnection = [[NZURLConnection alloc] initWithRequest:theRequest];
    theConnection.results_handler = aHandler;
    [theConnection startWithTimeout:aTimeout];
    
    return theConnection;
}

+ (NZURLConnection *)getAsynchronousResponseFromURL:(NSString *)aURL withTimeout:(NSInteger)aTimeout completionHandler:(void (^)(BOOL, NSData *))aHandler {
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:aTimeout];
    //[theRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    //  theRequest.timeoutInterval = aTimeout;
    
    NZURLConnection *theConnection = [[NZURLConnection alloc] initWithRequest:theRequest];
    theConnection.handler = aHandler;
    [theConnection startWithTimeout:aTimeout];
    return theConnection;
}

- (void)cancelWithHandler {
    if (!completed) {
        [super cancel];
        if (self.handler) {
            self.handler(NO, self.storageData);
        } else {
            self.results_handler(NZURL_TIMEOUT, nil);
        }
    }
    completed = YES;
}

- (void) cancel {
    [super cancel];
    completed = YES;
}

- (void)startWithTimeout:(NSInteger)aTimeout {
    [self performSelector:@selector(cancelWithHandler) withObject:nil afterDelay:aTimeout];
    [self start];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    completed = YES;
    if (self.handler) {
        self.handler(NO, self.storageData);
    } else {
        self.results_handler(NZURL_TIMEOUT, nil);
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.storageData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    completed = YES;
    if (self.handler) {
        self.handler(YES, self.storageData);
    } else {
        NSDictionary *theResults = [NSJSONSerialization JSONObjectWithData:self.storageData options:kNilOptions error:nil];
        if (theResults && [theResults objectForKey:@"Result"] && [[theResults objectForKey:@"Result"] isEqualToString:@"Success"]) {
            self.results_handler(NZURL_SUCCESS, theResults);
        } else {
            if (theResults && [theResults objectForKey:@"Reason"]) {
                NSLog(@"NZURL Error: %@", theResults);
                self.results_handler(NZURL_ERROR_RESULTS, theResults);
            } else {
                NSLog(@"NZURL Error: %@",[[NSString alloc] initWithData:self.storageData encoding:NSUTF8StringEncoding]);
                self.results_handler(NZURL_ERROR_NORESULTS, theResults);
            }
            
        }
        
    }
    
}


@end
