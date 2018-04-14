//
//  UpdateQueue.m
//  XReader
//
//  Created by Pablo Collins on 3/6/11.
//

#import "UpdateQueue.h"
#import "Article.h"
#import "Feed+Logic.h"
#import "FeedReader.h"
#import "M.h"
#import "DownloadQueue.h"
#import "FeedDownloader.h"

#define MAX_CONCURRENT_UPDATES 1

@interface UpdateQueue () {
    BOOL _paused;
    NSMutableSet *_updating;
    NSOperationQueue *_opQ;
    NSMutableDictionary *_feedDictionary;
    NSMutableArray *_feeds;
    int _updatesEnqueued;
} @end

@implementation UpdateQueue

@synthesize paused, delegate;

+ (UpdateQueue *)sharedInstance
{
    static UpdateQueue *me;
    if (me == nil) {
        me = [[UpdateQueue alloc] init];
    }
    return me;
}

- (id)init
{
    self = [super init];
    _paused = NO;
    _opQ = [[NSOperationQueue alloc] init];
    _updating = [[NSMutableSet alloc] init];
    _feedDictionary = [[NSMutableDictionary alloc] init];
    _feeds = [[NSMutableArray alloc] init];
    _updatesEnqueued = 0;
    return self;
}

- (BOOL)isRunning
{
    return _feeds.count > 0;
}

- (NSOperationQueue *)q
{
    return _opQ;
}

//public
- (BOOL)isFeedQueued:(Feed *)f
{
    return _feedDictionary[[f objectID]] != nil;
}

//public
- (BOOL)isFeedUpdating:(Feed *)f
{
    return [_updating containsObject:[f objectID]];
}

//public
- (void)enqueueFeed:(Feed *)feed
{
    assert([NSThread isMainThread]);
    _updatesEnqueued += 1;
    NSManagedObjectID *fid = [feed objectID];
    [self.delegate feedEnqueued:fid];
    _feedDictionary[fid] = feed;
    [_feeds addObject:feed];
}

//public
- (float)completionRatio
{
    return _updatesEnqueued == 0 ? 1.0 : 1.0 - ((float)_feeds.count/_updatesEnqueued);
}

- (void)checkForUpdatesAndStartNewThread
{
    Feed *newDownload = nil;
    for (Feed *feed in _feeds) {
        if (![_updating containsObject:feed.objectID]) {
            newDownload = feed;
            break;
        }
    }
    if (newDownload == nil) {
        _updatesEnqueued = 0;
        [self.delegate nothingLeftToUpdate];
        [[DownloadQueue sharedInstance] updateQueueHasNothingLeftToUpdate];
        return;
    }
    [_updating addObject:newDownload.objectID];
    [self startUpdating:newDownload];
}

- (void)updateNext
{
    if ([_updating count] >= MAX_CONCURRENT_UPDATES) {
        return;
    }
    [self checkForUpdatesAndStartNewThread];
}

- (NSSet *)updating
{
    return _updating;
}

//private
- (void)startUpdating:(Feed *)feed
{
    feed.lastUpdated = [NSDate date];
    FeedDownloader *dl = [[FeedDownloader alloc] initWithFeed:feed
                                                          url:[NSURL URLWithString:feed.url]
                                                  updateQueue:self];
    [dl start];
}

//public
- (void)finishedUpdating:(NSManagedObjectID *)fid
               withError:(NSError *)e
{
    assert([NSThread isMainThread]);
    
    [_updating removeObject:fid];
    Feed *feed = _feedDictionary[fid];
    
    if (e) {
        feed.lastUpdateFailed = @(YES);
    } else {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:feed.lastUpdated];
        feed.updateTime = @(interval);
    }

    [[M sharedInstance] saveMainContext];
    
    [_feeds removeObject:feed];
    [_feedDictionary removeObjectForKey:fid];
    
    [delegate feedDidFinishUpdating:fid];
    
    [self updateNext];
}

//public
- (void)finishedUpdating:(NSManagedObjectID *)fid
{
    [self finishedUpdating:fid withError:nil];
}

@end
