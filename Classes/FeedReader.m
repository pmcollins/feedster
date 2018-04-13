//
//  RssArticlesReader.m
//  XReader
//
//  Created by Pablo Collins on 11/19/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "FeedReader.h"
#import "ContentHandler.h"
#import "AttributeHandler.h"
#import "M.h"
#import "RssArticleHandler.h"
#import "AtomArticleHandler.h"
#import "RdfArticleHandler.h"
#import "DownloadQueue.h"
#import "UpdateQueue.h"

@interface FeedReader () {
    ArticleHandler *_rssItemHandler, *_atomItemHandler;
    Feed *_feed;
    NSManagedObjectContext *_ctx;
    NSManagedObjectID *_fid;
    NSData *_data;
    UpdateQueue *_updateQueue;
} @end

@implementation FeedReader

+ (void)addContentHandlerTo:(ArticleHandler *)nodeHandler name:(NSString *)name property:(NSString *)p
{
    ContentHandler *contentHandler = [[ContentHandler alloc] initWithTagName:name property:p];
    [nodeHandler setChildHandler:contentHandler forKey:name];
    [contentHandler setPropertyValueDelegate:nodeHandler];
}

- (id)initWithFeedId:(NSManagedObjectID *)fid updateQueue:(UpdateQueue *)q data:(NSData *)data
{
    self = [super init];
    
    _fid = fid;
    _updateQueue = q;
    _data = data;
    
    //setup rss handlers
    _rssItemHandler = [[RssArticleHandler alloc] initWithReader:self];
    [_channelHandler setChildHandler:_rssItemHandler forKey:@"item"];
    [FeedReader addContentHandlerTo:_rssItemHandler name:@"title" property:@"title"];
    [FeedReader addContentHandlerTo:_rssItemHandler name:@"guid" property:@"guid"];
    [FeedReader addContentHandlerTo:_rssItemHandler name:@"link" property:@"link"];
    [FeedReader addContentHandlerTo:_rssItemHandler name:@"description" property:@"body"];
    [FeedReader addContentHandlerTo:_rssItemHandler name:@"pubDate" property:@"pubDateStr"];
	NSDictionary *dict = @{@"url": @"mediaUrl", @"length": @"mediaLengthStr", @"type": @"mediaType"};
	AttributeHandler *enclosureHandler = [[AttributeHandler alloc] initWithDictionary:dict];
	[_rssItemHandler setChildHandler:enclosureHandler forKey:@"enclosure"];
	[enclosureHandler setPropertyValueDelegate:_rssItemHandler];

	RdfArticleHandler *rfih = [[RdfArticleHandler alloc] initWithReader:self];
	[_rssRdfNodeHandler setChildHandler:rfih forKey:@"item"];
    [FeedReader addContentHandlerTo:rfih name:@"title" property:@"title"];
    [FeedReader addContentHandlerTo:rfih name:@"guid" property:@"guid"];
    [FeedReader addContentHandlerTo:rfih name:@"link" property:@"link"];
    [FeedReader addContentHandlerTo:rfih name:@"description" property:@"body"];
	[FeedReader addContentHandlerTo:rfih name:@"dc:date" property:@"pubDateStr"];
	
    //setup atom handlers
    _atomItemHandler = [[AtomArticleHandler alloc] initWithReader:self];
    [_atomFeedHandler setChildHandler:_atomItemHandler forKey:@"entry"];
    [FeedReader addContentHandlerTo:_atomItemHandler name:@"title" property:@"title"];
    [FeedReader addContentHandlerTo:_atomItemHandler name:@"id" property:@"guid"];
    [FeedReader addContentHandlerTo:_atomItemHandler name:@"summary" property:@"body"];
    [FeedReader addContentHandlerTo:_atomItemHandler name:@"content" property:@"body"];
    [FeedReader addContentHandlerTo:_atomItemHandler name:@"updated" property:@"pubDateStr"];
    //news & observer uses a straight link tag for some reason
    [FeedReader addContentHandlerTo:_atomItemHandler name:@"link" property:@"link"];
    AttributeHandler *atomLinkHandler = [[AttributeHandler alloc] initWithAttributeName:@"href" property:@"link"];
    [_atomItemHandler setChildHandler:atomLinkHandler forKey:@"link"];
    [atomLinkHandler setPropertyValueDelegate:_atomItemHandler];

    return self;
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (![_feed.completedFirstUpdate boolValue]) {
        _feed.earliestArticleDate = [_feed earliestFeedDateWithContext:_ctx];
    }

    _feed.completedFirstUpdate = @YES;
    _feed.createDate = [NSDate date];
    
    //needs to happen before the new item count b/c if this is the first update, some new items may already get deleted
    [_feed permanentlyDeleteOldItemsInContext:_ctx];

    [_feed countNewItemsInContext:_ctx];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [super parser:parser parseErrorOccurred:parseError];
    _feed.lastUpdateFailed = @(YES);
    [[M sharedInstance] saveContext:_ctx];
}

- (NSManagedObjectContext *)context
{
    return _ctx;
}

- (Feed *)feed
{
    return _feed;
}

- (NSObject<UpdateQueueListener> *)updateQueueListener
{
    return _updateQueue.delegate;
}

- (void)main
{
    _ctx = [[M sharedInstance] newManagedObjectContext];

    _feed = (Feed *)[_ctx objectWithID:_fid];

    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:_data];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    [[M sharedInstance] saveContext:_ctx];

    [[UpdateQueue sharedInstance] performSelectorOnMainThread:@selector(finishedUpdating:)
                                                   withObject:_feed.objectID
                                                waitUntilDone:NO];
}

@end

