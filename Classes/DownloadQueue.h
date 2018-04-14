//
//  DownloadQueue.h
//  XReader
//
//  Created by Pablo Collins on 2/8/11.
//

#import <Foundation/Foundation.h>
#import "DQEnclosureDownload.h"
#import "Article.h"
#import "DownloadListener.h"

@interface DownloadQueue : NSObject

@property (nonatomic, weak) NSObject<DownloadListener> * delegate;

+ (DownloadQueue *)sharedInstance;

- (BOOL)isRunning;
- (void)downloadFinished:(DQEnclosureDownload *)d
                   error:(NSError *)errorOrNil;

- (void)enqueueDownloadForArticle:(Article *)article manualRequest:(BOOL)manualRequest;

- (NSUInteger)currDownloadCount;

- (void)autoDownloadPodcasts;

- (void)downloadStartedForArticleId:(NSManagedObjectID *)articleId;

- (void)downloadReachedCompletionRatio:(float)completionRatio forArticleId:(NSManagedObjectID *)articleId;

- (void)downloadCompletedForArticleId:(NSManagedObjectID *)articleId;

- (BOOL)isQueued:(NSManagedObjectID *)feedId;

- (BOOL)isDownloading:(NSManagedObjectID *)feedId;

- (void)updateQueueHasNothingLeftToUpdate;

@end
