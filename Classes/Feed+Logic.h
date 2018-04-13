//
//  Feed+Logic.h
//  XReader
//
//  Created by Pablo Collins on 12/20/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import "Feed.h"

#define kOldArticleCutoffDaysAgo 10
#define kMinUndeletableFeeds 100

@interface Feed (Feed_Logic)

+ (NSDictionary *)feedsInFolders;
+ (NSArray *)orderedFeeds;
+ (NSArray *)unorderedFeeds;
+ (void)setArticlesAsSeen:(NSArray *)articles;
+ (NSUInteger)ffCount;
+ (Feed *)firstFeedWithUnreadItems;
+ (NSArray *)feedsOrderedByUpdateTime;

- (void)countNewItemsInContext:(NSManagedObjectContext *)ctx;
- (Feed *)nextFeedWithUnreadItems;

- (NSArray *)allArticlesNeedingDownload;
- (NSArray *)recentPodcastsNeedingDownload;

- (NSArray *)newArticles;
- (NSArray *)previousArticles:(NSUInteger)count;
- (NSUInteger)unreadItemCount;
- (NSUInteger)itemCount;

- (void)deleteAllItems;
- (void)deleteReadItems;

- (void)markAllAsRead;
- (void)markAllAsUnread;

- (NSString *)updatedAgo;
- (UIImage *)faviconImage;

- (void)permanentlyDeleteOldItemsInContext:(NSManagedObjectContext *)ctx;

- (NSArray *)getRecentPodcastsStatus:(NSManagedObjectContext *)ctx;
- (void)deleteExpiredDownloads;

- (NSUInteger)calculatedRefreshPeriodWithContext:(NSManagedObjectContext *)ctx;
- (NSDate *)earliestFeedDateWithContext:(NSManagedObjectContext *)ctx;
- (NSInteger)effectiveRefreshPeriod;

@end
