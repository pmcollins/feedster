//
//  PodcastStatusFetcher.m
//  XReader
//
//  Created by Pablo Collins on 6/16/12.
//

#import "PodcastStatusFetcher.h"
#import "Feed+Logic.h"
#import "M.h"
#import "PodcastStatusIconView.h"

@interface PodcastStatusFetcher() {
    NSManagedObjectID *_fid;
    id<PodcastStatusDelegate> _delegate;
    BOOL _isReady;
    NSArray *_status;
    NSUInteger _calculatedRefreshPeriod;
}
@end

@implementation PodcastStatusFetcher

static NSOperationQueue *_q;

- (id)initWithFeedId:(NSManagedObjectID *)fid
            delegate:(id<PodcastStatusDelegate>)delegate
{
    self = [super init];
    _fid = fid;
    _delegate = delegate;
    _isReady = NO;
    if (_q == nil) {
        _q = [[NSOperationQueue alloc] init];
        [_q setMaxConcurrentOperationCount:1];
    }
    
    [self fetch];

    return self;
}

- (void)fetch
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *ctx = [[M sharedInstance] newManagedObjectContext];
        Feed *feed = (Feed *)[ctx objectWithID:_fid];
        _status = [feed getRecentPodcastsStatus:ctx];
        _calculatedRefreshPeriod = [feed calculatedRefreshPeriodWithContext:ctx];
        feed.calculatedRefreshPeriod = @(_calculatedRefreshPeriod);
        feed.calculatedRefreshPeriodDate = [NSDate date];
        _isReady = YES;

        [[M sharedInstance] saveContext:ctx];
        [self performSelectorOnMainThread:@selector(callDelegate) withObject:nil waitUntilDone:NO];
    }];
    [op setThreadPriority:0];
    [_q addOperation:op];
}

- (void)callDelegate
{
    [_delegate gotPodcastStatus:_status
                  refreshPeriod:_calculatedRefreshPeriod
                      forFeedId:_fid];
}

- (NSUInteger)refreshPeriod
{
    return _calculatedRefreshPeriod;
}

- (BOOL)statusIsReady
{
    return _isReady;
}

- (NSArray *)status
{
    return _status;
}

@end
