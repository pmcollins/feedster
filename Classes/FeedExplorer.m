//
//  RssTitleReader.m
//  XReader
//
//  Created by Pablo Collins on 11/14/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "FeedExplorer.h"
#import "M.h"
#import "AttributeHandler.h"

@interface FeedExplorer () {
    BOOL _findLinksIfNotAFeed;
} @end

@implementation FeedExplorer

- (id)init
{
    self = [super init];

    ContentHandler *titleHandler = [[ContentHandler alloc] initWithTagName:@"title" property:nil];
    [titleHandler setPropertyValueDelegate:self];
    [_channelHandler setChildHandler:titleHandler forKey:@"title"];
    [_atomFeedHandler setChildHandler:titleHandler forKey:@"title"];

	ContentHandler *rssLinkHandler = [[ContentHandler alloc] initWithTagName:@"link" property:nil];
	[_channelHandler setChildHandler:rssLinkHandler forKey:@"link"];
	[rssLinkHandler setPropertyValueDelegate:self];
	
	AttributeHandler *atomLinkHandler = [[AttributeHandler alloc] initWithAttributeName:@"href" property:@"foo"];
	[_atomFeedHandler setChildHandler:atomLinkHandler forKey:@"link"];
	[atomLinkHandler setPropertyValueDelegate:self];

    return self;
}

+ (BOOL)documentAppearsToBeAFeed:(NSString *)doc
{
    NSError *e;
    
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"^\\s*<\\?xml"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&e];
    NSTextCheckingResult *r = [regEx firstMatchInString:doc options:0 range:NSMakeRange(0, [doc length])];
    if (r) return YES;

    regEx = [NSRegularExpression regularExpressionWithPattern:@"^\\s*<feed"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&e];
    r = [regEx firstMatchInString:doc options:0 range:NSMakeRange(0, [doc length])];
    if (r) return YES;
    
    regEx = [NSRegularExpression regularExpressionWithPattern:@"^\\s*<rss"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&e];
    r = [regEx firstMatchInString:doc options:0 range:NSMakeRange(0, [doc length])];
    if (r) return YES;
    
    return NO;
}

- (void)findLinksInDocument:(ResourceDownload *)documentDownload
{
    NSError *e;
    NSRegularExpression *regEx =
		[NSRegularExpression regularExpressionWithPattern:@"<link(.*?)>"
												  options:(NSRegularExpressionCaseInsensitive |
														   NSRegularExpressionDotMatchesLineSeparators)
													error:&e];
    NSRegularExpression *tokenRex = [NSRegularExpression regularExpressionWithPattern:@"___(\\d+)___"
                                                                              options:0
                                                                                error:&e];
    NSString *doc = [documentDownload asString];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSArray *matches = [regEx matchesInString:doc options:0 range:NSMakeRange(0, [doc length])];
    NSMutableArray *hrefs = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match rangeAtIndex:1];
        NSString *attrs = [doc substringWithRange:range];
        if (attrs == nil) {
            continue;
        }
        NSArray *qtSplit = [attrs componentsSeparatedByString:@"\""];
        NSMutableArray *qtTokens = [[NSMutableArray alloc] init];
        NSMutableString *tokenizedStr = [[NSMutableString alloc] init];
        for (int i = 0; i < [qtSplit count]; i++) {
            NSString *str = qtSplit[i];
            if (i % 2) {
                [qtTokens addObject:str];
                [tokenizedStr appendString:[NSString stringWithFormat:@"___%i___", (i-1)/2]];
            } else {
                [tokenizedStr appendString:str];
            }
        }
        NSArray *nvPairs = [tokenizedStr componentsSeparatedByString:@" "];
        NSMutableDictionary *attrDict = [[NSMutableDictionary alloc] init];
        for (NSString *nvPair in nvPairs) {
            NSArray *nvArray = [nvPair componentsSeparatedByString:@"="];
            if ([nvArray count] == 1) {
                continue;
            }
            NSString *name = nvArray[0];
            name = [name lowercaseString];
            NSString *value = nvArray[1];
            NSTextCheckingResult *match = [tokenRex firstMatchInString:value options:0 range:NSMakeRange(0, [value length])];
            if (match) {
                NSString *nStr = [value substringWithRange:[match rangeAtIndex:1]];
                NSNumber *idx = [f numberFromString:nStr];
                value = [[NSString stringWithFormat:@"%@", qtTokens[[idx intValue]]] lowercaseString];
            }
            [attrDict setValue:value forKey:name];
        }
        if ([attrDict[@"rel"] isEqualToString:@"alternate"]
            && [attrDict[@"type"] isEqualToString:@"application/rss+xml"]) {
            [hrefs addObject:attrDict[@"href"]];
        }
    }
    if ([hrefs count]) {
        [_delegate explorerFoundFeedUrls:[self normalizeHrefs:hrefs finalURL:[documentDownload finalURL]]];
    } else {
        [_delegate explorerExploded:@"No feeds found at that address."];
    }
}

- (NSArray *)normalizeHrefs:(NSArray *)hrefs finalURL:(NSURL *)finalUrl
{
    NSMutableArray *out = [[NSMutableArray alloc] init];
    for (NSString *href in hrefs) {
        NSURL *u = [NSURL URLWithString:href];
        if ([u scheme] == nil) {
            u = [[NSURL alloc] initWithString:href relativeToURL:finalUrl];
            [out addObject:[u absoluteString]];
        } else {
            [out addObject:href];
        }
    }
    return out;
}

+ (NSString *)fixupFeedUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = [url scheme];
	if (scheme == nil) {
		return [NSString stringWithFormat:@"http://%@", urlString];
	} else if ([scheme isEqualToString:@"feed"]) {
        return [urlString stringByReplacingOccurrencesOfString:@"feed://" withString:@"http://" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 7)];
    }
    return urlString;
}

- (void)loadUrl:(NSURL *)url findLinks:(BOOL)findLinks
{
    _findLinksIfNotAFeed = findLinks;
    ResourceDownload *dl = [[ResourceDownload alloc] initWithUrl:url delegate:self];
    [dl run];
}

- (Feed *)feed
{
    if (feed == nil) {
        feed = [[M sharedInstance] insert:@"Feed"];
    }
    return feed;
}

- (NSData *)downloadFaviconAtDomain:(NSString *)domain
{
	NSURL *faviconUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/favicon.ico", domain]];
	NSURLResponse *response;

    NSURLRequest *req = [NSURLRequest requestWithURL:faviconUrl
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:4];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req
										 returningResponse:&response
													 error:nil];

	UIImage *img = [UIImage imageWithData:data];
	if (img) {
		return data;
	} else {
		return nil;
	}
}

- (void)downloadFaviconForLink:(NSString *)link
{
	NSURL *u = [NSURL URLWithString:link];
	NSString *host = [u host];
    if (!host) {
        return;
    }
	NSData *favicon = [self downloadFaviconAtDomain:host];
	if (favicon) {
		[self feed].favicon = favicon;
	} else {
		NSArray *a = [host componentsSeparatedByString:@"."];
        if (a.count <= 2) {
            return;
        }
		NSMutableArray *ma = [NSMutableArray arrayWithArray:a];
		ma[0] = @"www";
		NSString *wwwDomain = [ma componentsJoinedByString:@"."];
		favicon = [self downloadFaviconAtDomain:wwwDomain];
		if (favicon) {
			[self feed].favicon = favicon;
		}
	}
}

- (void)handlerFoundValue:(NSString *)str forName:(NSString *)name property:(NSString *)property
{
	if (name == nil) return;
	if ([name isEqualToString:@"title"]) {
		[self feed].title = str;
		[_delegate explorerFoundFeed:feed];
	} else if ([name isEqualToString:@"link"] || [name isEqualToString:@"href"]) {
		[self downloadFaviconForLink:str];
	}
}

- (void)handlerFoundValue:(NSString *)v
{
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [_delegate explorerCompleted];
}

#pragma - ResourceDownloadDelegate

- (void)download:(ResourceDownload *)d failedWithError:(NSError *)error
{
    [_delegate explorerExploded:[error localizedDescription]];
}

- (void)resourceDownloadFinished:(ResourceDownload *)documentDownload
{
    NSString *document = [documentDownload asString];
	@try {
		if (document == nil || document.length == 0) {
			[NSException raise:@"EmptyDocumentForUrl" format:@"empty document"];
		}
		bool isFeed = [FeedExplorer documentAppearsToBeAFeed:document];
		if (isFeed) {
			[super loadDocument:document];
		} else if (_findLinksIfNotAFeed) {
			[self findLinksInDocument:documentDownload];
		} else {
            [_delegate explorerExploded:@"Not a feed and no links in document"];
        }
	}
	@catch (NSException *e) {
		[_delegate explorerExploded:[e reason]];
	}
}

@end
