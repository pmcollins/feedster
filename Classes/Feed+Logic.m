//
//  Feed+Logic.m
//  XReader
//
//  Created by Pablo Collins on 12/20/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import "Feed+Logic.h"

#import "Article.h"
#import "Article+Logic.h"
#import "FeedReader.h"
#import "M.h"
#import "Folder.h"

@implementation Feed (Feed_Logic)

#pragma mark -
#pragma mark Class Methods

+ (NSDictionary *)feedsInFolders
{
    NSArray *feeds = [Feed orderedFeeds];
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    for (Feed *f in feeds) {
        id<NSCopying> key = f.folder == nil ? [NSNull null] : f.folder.objectID;
        NSMutableArray *a = d[key];
        if (a == nil) {
            a = [[NSMutableArray alloc] init];
            d[key] = a;
        }
        [a addObject:f];
    }
    return d;
}

+ (NSArray *)selectFeeds:(BOOL)sorted {
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
	if (sorted) {
		NSSortDescriptor *folderSort = [[NSSortDescriptor alloc] initWithKey:@"folder.name" ascending:YES];
		NSSortDescriptor *titleSort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
		[req setSortDescriptors:@[folderSort, titleSort]];
	}
    NSError *e;

    return [ctx executeFetchRequest:req error:&e];
}

+ (NSArray *)feedsOrderedByUpdateTime
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateTime" ascending:YES];
    [req setSortDescriptors:@[sort]];
    
    return [ctx executeFetchRequest:req error:nil];
}

+ (NSArray *)orderedFeeds {
	return [Feed selectFeeds:YES];
}

+ (NSArray *)unorderedFeeds {
	return [Feed selectFeeds:NO];
}

+ (void)setArticlesAsSeen:(NSArray *)articles
{
    for (Article *article in articles) {
        article.seen = @YES;
    }
}

+ (NSUInteger)ffCount
{
    int out = 0;
    for (Feed *f in [Feed orderedFeeds]) {
        if ([f.newItemCount intValue]) {
            out += 1;
        }
    }
    return out;
}

+ (Feed *)firstFeedWithUnreadItems
{
    NSArray *feeds = [Feed orderedFeeds];
    for (Feed *f in feeds) {
        if ([[f newItemCount] intValue]) {
            return f;
        }
    }
    return nil;
}

#pragma mark - Instance Methods

- (Feed *)nextFeedWithUnreadItems
{
    NSArray *feeds = [Feed orderedFeeds];
    NSUInteger size = feeds.count;
    if (size < 2) {
        return nil;
    }
    BOOL foundSelf = NO;
    int foundIdx = 0;
    for (int i = 0; i < size + foundIdx; i++) {
        Feed *curr = feeds[i%size];
        if (!foundSelf) {
            if (curr == self) {
                foundSelf = YES;
                foundIdx = i;
            }
        } else if ([[curr newItemCount] intValue]) {
            return curr;
        }
    }
    return nil;
}

- (void)countNewItemsInContext:(NSManagedObjectContext *)ctx
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (deleted == 0) AND (seen == 0)", self];
    [req setPredicate:p];
    self.newItemCount = [NSNumber numberWithUnsignedInteger:[ctx countForFetchRequest:req error:nil]];
}

- (BOOL)hasAnyMedia {
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (mediaUrl != NULL)", self];
    [req setPredicate:p];
    NSError *e;

    NSUInteger count = [ctx countForFetchRequest:req error:&e];
    return count > 0;
}

- (Article *)firstUpdateArticleNeedingDownload {
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (deleted == 0) AND (fromFirstUpdate == TRUE) AND (mediaUrl != NULL)", self];
    [req setPredicate:p];
    [req setFetchLimit:1];
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];
    NSError *e;
    NSArray *a;

    a = [ctx executeFetchRequest:req error:&e];
    
    if ([a count] == 0) {
        return nil;
    } else {
        Article *article = a[0];
        if (article.mediaUrl && !article.downloaded) {
            return article;
        } else {
            return nil;
        }
    }
}

- (NSArray *)articlesWithMediaDownloaded:(BOOL)downloaded filterDeleted:(BOOL)filterDeleted
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    
    NSPredicate *p;
    if (filterDeleted) {
        p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (deleted == 0) AND (fromFirstUpdate == FALSE) AND (mediaUrl != NULL) AND (downloaded == %@)",
             self, @(downloaded)];
    } else {
        p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (fromFirstUpdate == FALSE) AND (mediaUrl != NULL) AND (downloaded == %@)",
             self, @(downloaded)];
    }
    [req setPredicate:p];

    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];
    NSError *e;

    return [ctx executeFetchRequest:req error:&e];
}

- (NSArray *)articlesNeedingDownload {
    return [self articlesWithMediaDownloaded:NO filterDeleted:YES];
}

- (NSArray *)recentPodcastsNeedingDownload
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (mediaUrl != NULL) and (mediaType == \"audio/mpeg\")", self];
    [req setPredicate:p];
    
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];
    [req setFetchLimit:3];
    NSArray *threeMostRecentPcs;

    threeMostRecentPcs = [ctx executeFetchRequest:req error:nil];
    
    NSMutableArray *out = [[NSMutableArray alloc] initWithCapacity:3];
    for (Article *article in threeMostRecentPcs) {
        BOOL downloaded = [article.downloaded boolValue];
        if (!downloaded) {
            [out addObject:article];
        }
    }
    return out;
}

- (NSArray *)allArticlesNeedingDownload {
    if (![self hasAnyMedia])
        return nil;
    
    Article *firstUpdateArticle = [self firstUpdateArticleNeedingDownload];
    if (firstUpdateArticle != nil)
        return @[firstUpdateArticle];
    
    return [self articlesNeedingDownload];
}

- (NSArray *)recentArticlesWithFetchLimit:(NSUInteger)fetchLimit moc:(NSManagedObjectContext *)ctx
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];

    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    [req setFetchLimit:fetchLimit];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (deleted == 0)", self];
    [req setPredicate:p];
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];

    return [ctx executeFetchRequest:req error:nil];
    
}

- (NSArray *)newArticles {
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (deleted == 0) AND (seen == 0)", self];
    [req setPredicate:p];
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];
    
    return [ctx executeFetchRequest:req error:nil];
}

- (NSArray *)previousArticles:(NSUInteger)fetchLimit inContext:(NSManagedObjectContext *)ctx
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    [req setFetchLimit:fetchLimit];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (deleted == 0) AND (seen == 1)", self];
    [req setPredicate:p];
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];
    
    return [ctx executeFetchRequest:req error:nil];
}

- (NSArray *)deletedArticlesInContext:(NSManagedObjectContext *)ctx
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];

    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (deleted == 1)", self];
    [req setPredicate:p];
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];
    
    return [ctx executeFetchRequest:req error:nil];
}

- (NSArray *)allArticlesInContext:(NSManagedObjectContext *)ctx
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@)", self];
    [req setPredicate:p];
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [req setSortDescriptors:@[pubDateSort]];

    return [ctx executeFetchRequest:req error:nil];
}

- (NSArray *)previousArticles:(NSUInteger)count
{
    return [self previousArticles:count inContext:[[M sharedInstance] mainManagedObjectContext]];
}

- (NSFetchRequest *)activeItemRequest:(NSString *)predicates {
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
	NSPredicate *p;
    NSString *fmt = [NSString stringWithFormat:@"(feed == %%@) AND (deleted == 0) %@", predicates];
    p = [NSPredicate predicateWithFormat:fmt, self];
    [req setPredicate:p];
	return req;
}

- (NSUInteger)activeItemCount:(NSString *)predicates {
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSError *e;

    return [ctx countForFetchRequest:[self activeItemRequest:predicates] error:&e];
}

- (NSArray *)activeItems:(NSString *)predicates {
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSError *e;

    return [ctx executeFetchRequest:[self activeItemRequest:predicates] error:&e];
}

- (NSUInteger)itemCount {
	return [self activeItemCount:@""];
}

- (NSUInteger)unreadItemCount {
	return [self activeItemCount:@"AND (unread == 1)"];
}

- (void)deleteAllItems {
    NSArray *items = [self activeItems:@""];
    for (Article *i in items) {
        i.deleted = @YES;
    }
    
    [[M sharedInstance] saveMainContext];
}

- (void)deleteReadItems {
    NSSet *items = [self articles];
    for (Article *i in items) {
        if (![i.unread boolValue]) {
            i.deleted = @YES;
        }
    }
    
    [[M sharedInstance] saveMainContext];
}

- (void)permanentlyDeleteOldItemsInContext:(NSManagedObjectContext *)ctx
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *cmp = [[NSDateComponents alloc] init];
    [cmp setDay:-(kOldArticleCutoffDaysAgo + 1)];
    NSDate *cutoffDate = [gregorian dateByAddingComponents:cmp toDate:[NSDate date] options:0];

    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];

    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    
    [req setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO]]];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@)", self];
    [req setPredicate:p];
    
    NSArray *a = [ctx executeFetchRequest:req error:nil];

    if (a.count > kMinUndeletableFeeds) {
        for (int i = kMinUndeletableFeeds; i < a.count; i++) {
            Article *article = a[i];
            if ([article.pubDate timeIntervalSinceDate:cutoffDate] < 0) {
                if (i == kMinUndeletableFeeds) {
                    self.lastDeletedArticlePubDate = article.pubDate;
                }
                [ctx deleteObject:article];
            }
        }
    }
    
    [[M sharedInstance] saveContext:ctx];
}

- (void)markAllAsRead {
	for (Article *article in [self activeItems:@"AND (unread == 1)"]) {
		article.unread = @(NO);
	}
	[[M sharedInstance] saveMainContext];
}

- (void)markAllAsUnread {
	for (Article *article in [self activeItems:@"AND (unread == 0)"]) {
		article.unread = @(YES);
	}
	[[M sharedInstance] saveMainContext];
}

- (NSString *)updatedAgo {
	NSDate *d = self.lastUpdated;
	if (d) {
		NSString *out;
		int minutes = -round([d timeIntervalSinceNow] / 60);
		if (minutes <= 1) {
			out = @"Updated just now";
		} else if (minutes <= 90) {
			out = [NSString stringWithFormat:@"Updated %d minutes ago", minutes];
		} else {
			int hours = round(minutes / 60);
			if (hours <= 48) {
				out = [NSString stringWithFormat:@"Updated %d hours ago", hours];
			} else {
				int days = round(hours / 24);
				out = [NSString stringWithFormat:@"Updated %d days ago", days];
			}
		}
		return out;
	} else {
		return @"";
	}
}

- (UIImage *)faviconImage {
	return self.favicon ? [UIImage imageWithData:self.favicon] : [UIImage imageNamed:@"feed-color.png"];
}

- (NSArray *)getRecentPodcastsStatus:(NSManagedObjectContext *)ctx
{
    NSMutableArray *out = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *recents = [self recentArticlesWithFetchLimit:5 moc:ctx];
    for (Article *article in recents) {
        [out addObject:@([article podcastStatus])];
    }
    return out;
}

- (void)deleteExpiredDownloads
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *cmp = [[NSDateComponents alloc] init];
    [cmp setDay:-3];
    NSDate *cutoffDate = [gregorian dateByAddingComponents:cmp toDate:[NSDate date] options:0];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (fromFirstUpdate == FALSE) AND (mediaUrl != NULL) AND (downloaded == %@) AND (mediaDownloadDate < %@)",
             self, @YES, cutoffDate];
    [req setPredicate:p];
    
    NSSortDescriptor *mediaDownloadDateSort = [[NSSortDescriptor alloc] initWithKey:@"mediaDownloadDate" ascending:NO];
    [req setSortDescriptors:@[mediaDownloadDateSort]];
    NSArray *feeds;

    feeds = [ctx executeFetchRequest:req error:nil];

    int recentFeedCount = 0;
    static NSUInteger numberOfFilesToKeep = 5; //TODO DEFINE
    for (Article *article in feeds) {
        if ([article hasMediaFile]) {
            recentFeedCount += 1;
            if (recentFeedCount > numberOfFilesToKeep) {
                [article deleteMediaFile];
                article.downloaded = @NO;
            }
        }
    }
}

- (NSUInteger)calculatedRefreshPeriodWithContext:(NSManagedObjectContext *)ctx
{
    if ([self.refreshPeriod integerValue] != 0) {
        return [self.refreshPeriod integerValue];
    }

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDate *earliestArticleDate = self.earliestArticleDate;
    
    if (earliestArticleDate == nil) return 60;

    NSDateComponents *earliestArticleDateDaysAgo = [gregorian components:NSDayCalendarUnit
                                                                fromDate:earliestArticleDate
                                                                  toDate:[NSDate date]
                                                                 options:0];

    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article"
                                          inManagedObjectContext:ctx];

    NSDate *now = [NSDate date];

    static NSUInteger kOversampling = 4;
    static NSUInteger kHourRadius = 1;

    if ([earliestArticleDateDaysAgo day] < 7) {
        // this is a new feed
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:ed];
        
        NSDateComponents *yesterdayCmp = [[NSDateComponents alloc] init];
        [yesterdayCmp setHour:-(24 + kHourRadius)];
        
        NSDate *yesterday = [gregorian dateByAddingComponents:yesterdayCmp toDate:now options:0];
        NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) and (pubDate > %@)", self, yesterday];
        [req setPredicate:p];
        
        NSInteger numArticles = [ctx countForFetchRequest:req error:nil];
        if (numArticles == 0) return 60;
        
        float hourlyUpdateFreq = (float) numArticles / 24;

        // we double the oversampling to account for both lack of overnight activity and likely lack of recent feed updates
        return 60 / (hourlyUpdateFreq * kOversampling * 2);
    } else {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:ed];
        
        NSDateComponents *startCmp = [[NSDateComponents alloc] init];
        [startCmp setDay:-7];
        [startCmp setHour:-kHourRadius];
        NSDate *startDate = [gregorian dateByAddingComponents:startCmp toDate:now options:0];
        
        NSDateComponents *endCmp = [[NSDateComponents alloc] init];
        [endCmp setDay:-7];
        [endCmp setHour:kHourRadius];
        NSDate *endDate = [gregorian dateByAddingComponents:endCmp toDate:now options:0];
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) and (pubDate > %@) and (pubDate < %@)", self, startDate, endDate];
        [req setPredicate:p];
        
        NSInteger numArticles = [ctx countForFetchRequest:req error:nil];
        
        float hourlyUpdateFreq = (float) numArticles / (kHourRadius * 2);
        
        if (numArticles == 0) {
            return 60;
        } else {
            return 60 / (hourlyUpdateFreq * kOversampling);
        }        
    }
    
}

- (NSDate *)earliestFeedDateWithContext:(NSManagedObjectContext *)ctx
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:ed];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(feed == %@) AND (fromFirstUpdate == TRUE)", self];
    [req setPredicate:p];
    [req setFetchLimit:1];
    NSSortDescriptor *pubDateSort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:YES];
    [req setSortDescriptors:@[pubDateSort]];
    
    NSArray *articles = [ctx executeFetchRequest:req error:nil];
    if (articles.count) {
        Article *f = articles[0];
        return f.pubDate;
    } else {
        return nil;
    }
}

- (NSInteger)effectiveRefreshPeriod
{
    return [self.refreshPeriod intValue] == 0 ? [self.calculatedRefreshPeriod intValue] : [self.refreshPeriod intValue];
}

@end


