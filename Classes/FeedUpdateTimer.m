//
//  Timer.m
//  XReader
//
//  Created by Pablo Collins on 3/11/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "FeedUpdateTimer.h"
#import "Feed.h"
#import "Feed+Logic.h"
#import "UpdateQueue.h"
#import "XReaderAppDelegate.h"
#import "DownloadQueue.h"
#import "M.h"

@implementation FeedUpdateTimer

+ (FeedUpdateTimer *)sharedInstance
{
    static FeedUpdateTimer *me;
    if (me == nil) {
        me = [[FeedUpdateTimer alloc] initWithWakePeriod:60];
    }
    return me;
}

- (void)timerPing:(NSTimer *)t
{
    BOOL autoUpdateFeeds = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefFeedAutoUpdates];
    if (!autoUpdateFeeds) {
        BOOL autoDownloadPodcasts = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefPodcastAutoDownloads];
        if (![[DownloadQueue sharedInstance] isRunning] && autoDownloadPodcasts) {
            [[DownloadQueue sharedInstance] autoDownloadPodcasts];
        }
        return;
    }
    if ([[UpdateQueue sharedInstance] isRunning] || [[DownloadQueue sharedInstance] isRunning]) {
//        NSLog(@"timerPing: UpdateQueue or DownloadQueue running: bailing out");
        return;
    }
    NSArray *feeds = [Feed feedsOrderedByUpdateTime];
    Feed *f;
    for (f in feeds) {
        NSUInteger rp;
        if ([f.refreshPeriod intValue] == 0) { //auto
            NSNumber *cached = f.calculatedRefreshPeriod;
            if (cached == nil) {
//                NSLog(@"why is f.calculatedRefreshPeriod nil?");
                rp = 60;
            } else {
                rp = [cached intValue];
            }
        } else {
            rp = [f.refreshPeriod intValue];
        }
        NSTimeInterval ti = -[f.lastUpdated timeIntervalSinceNow];
        NSInteger minutes = ti / 60;
        if (minutes > rp) {
            [[UpdateQueue sharedInstance] enqueueFeed:f];
        }
    }
    [[UpdateQueue sharedInstance] updateNext];
}

@end
