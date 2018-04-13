//
//  DownloadQueue.m
//  XReader
//
//  Created by Pablo Collins on 2/8/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "DownloadQueue.h"
#import "Article+Logic.h"
#import "M.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "Feed+Logic.h"
#import "M.h"

@interface DownloadQueue() {
    NSMutableDictionary *_currDownloadMap;
    NSMutableArray *_queuedArticles;
    NSMutableSet *_manualDownloads;
    BOOL _isRunning;
}
@end

@implementation DownloadQueue

+ (DownloadQueue *)sharedInstance
{
    static DownloadQueue *me;
    if (me == nil) {
        me = [[DownloadQueue alloc] init];
    }
    return me;
}

- (id)init
{
    self = [super init];
    _currDownloadMap = [[NSMutableDictionary alloc] init];
    _queuedArticles = [[NSMutableArray alloc] init];
    _manualDownloads = [[NSMutableSet alloc] init];
    _isRunning = NO;
    return self;
}

- (void)setDelegate:(NSObject<DownloadListener> *)delegate
{
    _delegate = delegate;
    for (NSManagedObjectID *articleId in [_currDownloadMap allKeys]) {
        DQEnclosureDownload *fileDownload = _currDownloadMap[articleId];
        [_delegate downloadReachedCompletionRatio:[fileDownload completionRatio] forArticleId:articleId];
    }
}

- (BOOL)isRunning
{
    return _isRunning;
}

- (void)startDownloadForArticle:(NSManagedObjectID *)fiId isManualDownload:(BOOL)isManualDownload
{
    _isRunning = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    DQEnclosureDownload *fileDownload = [[DQEnclosureDownload alloc] initWithArticleId:fiId allowCellular:isManualDownload];
    [fileDownload setDownloadQueue:self];
    _currDownloadMap[fiId] = fileDownload;
    [fileDownload start];
}

- (void)downloadNext
{
    if ([_currDownloadMap count] >= NUM_DOWNLOAD_THREADS) {
        return;
    }
    if ([_queuedArticles count] == 0) {
        _isRunning = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        return;
    }
    
    NSManagedObjectID *oId = [_queuedArticles lastObject];
    [_queuedArticles removeLastObject];
    
    BOOL isManualDownload = [_manualDownloads containsObject:oId];
    if (isManualDownload) {
        [_manualDownloads removeObject:oId];
    }
    
    [self startDownloadForArticle:oId isManualDownload:isManualDownload];
}

- (void)enqueueDownloadsForFeedId:(NSManagedObjectID *)fid
{
    Feed *feed = (Feed *)[[[M sharedInstance] mainManagedObjectContext] objectWithID:fid];
    [self enqueueDownloadsForFeed:feed];
    [_delegate downloadQueuedForArticleId:fid];
}

- (void)enqueueDownloadsForFeed:(Feed *)f
{
    NSArray *articles = [f allArticlesNeedingDownload];
    @synchronized(self) {
        for (Article *article in articles) {
            [_queuedArticles addObject:[article objectID]];
        }
        [self downloadNext];
    }
}

- (void)enqueueDownloadForArticle:(Article *)article manualRequest:(BOOL)manualRequest
{
    @synchronized(self) {
        [_queuedArticles addObject:article.objectID];
        if (manualRequest) {
            [_manualDownloads addObject:article.objectID];
        }
        [self downloadNext];
    }
}

- (BOOL)isQueued:(NSManagedObjectID *)feedId
{
    return [_queuedArticles containsObject:feedId];
}

- (BOOL)isDownloading:(NSManagedObjectID *)feedId
{
    return _currDownloadMap[feedId] != nil;
}

//called by FileDownload - connectionDidFinishLoading:
- (void)downloadFinished:(DQEnclosureDownload *)d error:(NSError *)errorOrNil
{
    @synchronized(self) {
        [_currDownloadMap removeObjectForKey:d.articleId];
        [self downloadNext];
    }
    if (errorOrNil) {
        return;
    }
    static NSString *TRACKS_KEY = @"tracks";
    NSManagedObjectContext *ctx = [[M sharedInstance] newManagedObjectContext];
    Article *article = (Article *)[ctx objectWithID:d.articleId];
    article.downloaded = @YES;
    article.downloadRecognized = @NO;
    [[M sharedInstance] saveContext:ctx];

    AVURLAsset *asset =
    [[AVURLAsset alloc] initWithURL:[article fileURL]
                            options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @NO}];
    [asset loadValuesAsynchronouslyForKeys:@[TRACKS_KEY]
                         completionHandler:^{
                             float mediaLen = asset.duration.value/(float)asset.duration.timescale;
                             if (mediaLen == 0) { // assume the d/l failed
                                 //NSLog(@"mediaLen == 0: bailing out");
                                 return;
                             }
                             
                             NSManagedObjectContext *blockCtx = [[M sharedInstance] newManagedObjectContext];
                             NSNotificationCenter *defaultNotificationCenter = [NSNotificationCenter defaultCenter];
                             [defaultNotificationCenter addObserver:[M sharedInstance]
                                                           selector:@selector(contextDidSave:)
                                                               name:NSManagedObjectContextDidSaveNotification
                                                             object:blockCtx];
                             
                             Article *f = (Article *)[blockCtx objectWithID:d.articleId];
                             f.mediaDownloadDate = [NSDate date];
                             f.playedLength = @0.0f;
                             f.mediaLength = @(mediaLen);
                             f.downloadRecognized = @YES;
                             [[M sharedInstance] saveContext:blockCtx];
                             
                             [defaultNotificationCenter removeObserver:[M sharedInstance]
                                                                  name:NSManagedObjectContextDidSaveNotification
                                                                object:blockCtx];
                             [_delegate assetLoaded:asset forArticleId:f.objectID feedId:f.feed.objectID];
                         }];
}

- (NSUInteger)currDownloadCount
{
    return [_currDownloadMap count];
}

- (void)autoDownloadPodcasts
{
    NSArray *items = [Article itemsWithEnclosuresEligibleForAutoDownload];
    for (Article *article in items) {
        [self enqueueDownloadForArticle:article manualRequest:NO];
    }
    [self downloadNext];
}

- (void)updateQueueHasNothingLeftToUpdate
{
    [self autoDownloadPodcasts];
}

#pragma mark - pseudo-DownloadListener

- (void)downloadStartedForArticleId:(NSManagedObjectID *)articleId
{
    [_delegate downloadStartedForArticleId:articleId];
}

- (void)downloadReachedCompletionRatio:(float)completionRatio
                         forArticleId:(NSManagedObjectID *)articleId
{
    [_delegate downloadReachedCompletionRatio:completionRatio forArticleId:articleId];
}

- (void)downloadCompletedForArticleId:(NSManagedObjectID *)articleId
{
    [_delegate downloadCompletedForArticleId:articleId];
}

@end
