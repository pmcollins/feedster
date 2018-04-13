//
//  Feed.h
//  XReader
//
//  Created by Pablo Collins on 2/2/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Article;
@class Folder;

@interface Feed : NSManagedObject  
{
}

@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSNumber *refreshPeriod;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSData *favicon;
@property (nonatomic, strong) NSNumber *refreshWeekDays;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *dailyRefreshTime;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) Folder *folder;
@property (nonatomic, strong) NSSet *articles;
@property (nonatomic, strong) NSSet *feedUpdates;
@property (nonatomic, strong) NSNumber *updateTime;
@property (nonatomic, strong) NSNumber *newItemCount;
@property (nonatomic, strong) NSNumber *isUpdatedHourly;
@property (nonatomic, strong) NSNumber *completedFirstUpdate;
@property (nonatomic, strong) NSString *siteUrl;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSNumber *lastUpdateFailed;
@property (nonatomic, strong) NSNumber *downloadPodcasts;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *earliestArticleDate;
@property (nonatomic, strong) NSNumber *calculatedRefreshPeriod;
@property (nonatomic, strong) NSDate *calculatedRefreshPeriodDate;
@property (nonatomic, strong) NSDate *lastDeletedArticlePubDate;
@end

@interface Feed (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(Article *)value;
- (void)removeArticlesObject:(Article *)value;
- (void)addArticles:(NSSet *)value;
- (void)removeArticles:(NSSet *)value;

- (void)addFeedUpdatesObject:(NSManagedObject *)value;
- (void)removeFeedUpdatesObject:(NSManagedObject *)value;
- (void)addFeedUpdates:(NSSet *)value;
- (void)removeFeedUpdates:(NSSet *)value;

@end
