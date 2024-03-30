//
//  MidiSearchManager.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 12/13/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "MidiSearchManager.h"
#import "NZURLRequest.h"
#import "TFHpple.h"

id<MidiSearchDelegate> theSearchDelegate = nil;
NSMutableArray *theURLs;
NSMutableArray *theResults;
NSURLConnection *freeMidiConnection, *laurasMidiConnection, *downloadConnection;
NSString *theDownloadingSong = nil;
static int laurasMidiCount = 0;
BOOL _aqw_managerIsSearching;

@implementation MidiSearchManager

+ (BOOL) isSearching {
    return _aqw_managerIsSearching;
}

+ (void) setSearching:(BOOL)searching {
    _aqw_managerIsSearching = searching;
}

+ (void)initialize {
    theResults = [NSMutableArray new];
    theURLs = [NSMutableArray new];
}

+ (void)setDelegate:(id<MidiSearchDelegate>)delegate {
    theSearchDelegate = delegate;
}

+ (void)searchFor:(NSString *)aQuery {
    [self cancel];
    [theResults removeAllObjects];
    [theURLs removeAllObjects];
    [self setSearching:YES];
    [self launchFreeMidiSearch:aQuery];
    laurasMidiCount++;
    int lmc = laurasMidiCount;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (lmc == laurasMidiCount) {
            [self launchLaurasMidiSearch:aQuery];
            NSLog(@"LM Search");
        }
    });

}

+ (void) launchFreeMidiSearch:(NSString *)query {
    NSString *url = [NSString stringWithFormat:@"http://www.free-midi.org/search/%@/pg1/", [query stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
    freeMidiConnection = [NZURLConnection getAsynchronousResponseFromURL:url withTimeout:15 completionHandler:^(BOOL success, NSData *response) {
        if (!success) {
            [self cancel];
            [theSearchDelegate searchFailed:@"The request timed out."];
        } else {
            NSString *theHTML = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            if ([self parseFreeMidiResults:theHTML]) {
                [theSearchDelegate searchFinished:theResults];
            } else {
                [theSearchDelegate searchFailed:@"There was an error extracting the results."];
            }
        }
    }];
}

+ (void) launchLaurasMidiSearch:(NSString *)query {
    NSString *url = [NSString stringWithFormat:@"http://www.google.com/custom?sitesearch=www.justmidis.com&q=%@", [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    laurasMidiConnection = [NZURLConnection getAsynchronousResponseFromURL:url withTimeout:15 completionHandler:^(BOOL success, NSData *response) {
        [self setSearching:NO];
        if (!success) {
            [self cancel];
            [theSearchDelegate searchFailed:@"The request timed out."];
        } else {
            if ([self parseLaurasMidiResults:response]) {
                [theSearchDelegate searchFinished:theResults];
            } else {
                [theSearchDelegate searchFailed:@"There was an error extracting the results."];
            }
        }
    }];

}

+ (void) cancel {
    [freeMidiConnection cancel];
    [laurasMidiConnection cancel];
    [downloadConnection cancel];
    theDownloadingSong = nil;
}

+ (BOOL) parseLaurasMidiResults:(NSData *)htmlData {
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    NSString *query = @"/html/body/div[@id='res']//div[@class='g']/a[@class='l']";
    NSArray *results = [parser searchWithXPathQuery:query];
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    for (TFHppleElement *result in results) {
        static NSString *prefix = @"http://www.justmidis.com/00-MIDI/";
        NSString *link = [result objectForKey:@"href"];
        if ([link hasPrefix:prefix]) {
            NSString *partOfInterest = [link substringFromIndex:prefix.length];
            if (![partOfInterest hasPrefix:@"0"]) continue;
            NSArray *parts = [partOfInterest componentsSeparatedByString:@"/"];
            if (parts.count == 2) {
                NSString *midiId = parts[0];
                NSString *midiName = [parts[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [theResults addObject:midiName];
                NSString *url = [NSString stringWithFormat:@"http://www.justmidis.com/cgi-bin/forcedownload.cgi?id=%@", midiId];
                [theURLs addObject:url];
            }
        }
    }
    return YES;
}

+ (BOOL) parseFreeMidiResults:(NSString *)html {
    NSString *divOpen = @"<div id=\"tabcontent1\">";
    NSRange divRange = [html rangeOfString:divOpen];
    if (divRange.location == NSNotFound) {
        return NO;
    }
    NSString *div = [html substringFromIndex:divRange.location];
    NSRange divClose = [div rangeOfString:@"</ul>"];
    if (divClose.location == NSNotFound) {
        return NO;
    }
    div = [div substringToIndex:divClose.location];
    
    NSScanner *scanner = [NSScanner scannerWithString:div];
    NSString *linkStart = @"href=\"";
    NSString *linkEnd = @"\">";
    NSString *nameEnd = @"</a>";
    NSString *url, *songName;
    
    NSMutableArray *results = [NSMutableArray new];
    theURLs = [NSMutableArray new];
    
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:linkStart intoString:nil];
        [scanner scanString:linkStart intoString:nil];
        if ([scanner scanUpToString:linkEnd intoString:&url] &&
            [scanner scanString:linkEnd intoString:nil] &&
            [scanner scanUpToString:nameEnd intoString:&songName]) {
            [theResults addObject:songName];
            url = [[url lastPathComponent] stringByDeletingPathExtension];
            url = [NSString stringWithFormat:@"http://www.free-midi.org/midi1/%c/%@.mid", [[url lowercaseString] characterAtIndex:0], url];
            [theURLs addObject:url];
        } else {
            break;
        }
    }
    return YES;
}

+ (NSString *)downloadingSong {
    return theDownloadingSong;
}

+ (void)downloadSong:(int)aResult toDirectory:(NSString *)path {
    [self cancel];
    
    if (aResult >= theResults.count) {
        [theSearchDelegate downloadFailed:@"There as an error downloading the file."];
        return;
    }
    NSString *name = [theResults objectAtIndex:aResult];
    NSString *url = [theURLs objectAtIndex:aResult];
    theDownloadingSong = name;
    downloadConnection = [NZURLConnection getAsynchronousResponseFromURL:url withTimeout:15 completionHandler:^(BOOL success, NSData *data) {
        NSString *newPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mid", name]];
        if (!success || ![data writeToFile:newPath atomically:NO]) {
            [theSearchDelegate downloadFailed:@"There as an error downloading the file."];
        } else {
            NSString *song = [theDownloadingSong copy];
            theDownloadingSong = nil;
            [theSearchDelegate downloadFinished:newPath forSong:song];
        }
    }];
}


@end
