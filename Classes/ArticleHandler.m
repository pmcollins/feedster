//
//  RssArticle.m
//  XReader
//
//  Created by Pablo Collins on 11/11/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "ArticleHandler.h"
#import "M.h"
#import "Article+Logic.h"
#import "DownloadQueue.h"
#import "FeedReader.h"

@interface ArticleHandler () {
//    NSDate *_oldArticleCutoffDate;
} @end

@implementation ArticleHandler

- (id)initWithReader:(FeedReader *)reader
{
    self = [super init];
    
    _feedReader = reader;
    
    now = [NSDate date];

//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *cmp = [[NSDateComponents alloc] init];
//    [cmp setDay:-(kOldArticleCutoffDaysAgo)];
//    _oldArticleCutoffDate = [gregorian dateByAddingComponents:cmp toDate:[NSDate date] options:0];

    itemCounter = 0;

	[self setDateFormat];

    return self;
}

- (void)setDateFormat {
}

- (void)tagStartedWithAttributes:(NSDictionary *)attributeDict {
    article = [[M sharedInstance] insert:@"Article" context:[_feedReader context]];
    article.insertDate = now;
    article.feed = [_feedReader feed];
    article.insertOrder = @(itemCounter++);
    article.starred = @NO;
    article.seen = @NO;
}

- (void)handlerFoundValue:(NSString *)value forName:(NSString *)name property:(NSString *)property {
    [article setValue:value forKey:property];
}

- (void)tagEnded {
	if (article.guid == nil) {
		article.guid = article.link;
        if (article.guid == nil) {
            article.guid = article.mediaUrl;
        }
        if (article.guid == nil) {
            article.guid = [NSString stringWithFormat:@"%@%@%@", [_feedReader feed].title, article.title, article.pubDateStr];
        }
	}
    
    NSString *pubDateStr = article.pubDateStr;
    article.pubDate = [dateFormatter dateFromString:pubDateStr];
    if (article.pubDate == nil && dateFormatter2 != nil) {
        article.pubDate = [dateFormatter2 dateFromString:pubDateStr];
    }
    if (article.pubDate == nil) {
        article.pubDate = [NSDate date];
    }
    
    NSDate *lastDeletedArticlePubDate = [_feedReader feed].lastDeletedArticlePubDate;
    if ([article guidExists:[_feedReader context]] ||
        (lastDeletedArticlePubDate && [article.pubDate timeIntervalSinceDate:lastDeletedArticlePubDate] < 0))
    {
        [[_feedReader context] deleteObject:article];
        [(NSObject *)[_feedReader updateQueueListener] performSelectorOnMainThread:@selector(discardingExistingItem)
                                                          withObject:nil
                                                       waitUntilDone:NO];
    } else {
        article.fromFirstUpdate = @(![[_feedReader feed].completedFirstUpdate boolValue]);
        article.mediaLength = @0.0f;

        //we have to save here or foundNewItemWithId will load a nil article
        [[M sharedInstance] saveContext:[_feedReader context]];

        [(NSObject *)[_feedReader updateQueueListener] performSelectorOnMainThread:@selector(foundNewItemWithId:)
                                                                        withObject:article.objectID
                                                                     waitUntilDone:NO];
    }
    article = nil;
}

@end
