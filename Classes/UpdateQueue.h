//
//  UpdateQueue.h
//  XReader
//
//  Created by Pablo Collins on 3/6/11.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "UpdateQueueListener.h"

@interface UpdateQueue : NSObject

@property (atomic, weak) NSObject<UpdateQueueListener> *delegate;
@property (assign) BOOL paused;

+ (UpdateQueue *)sharedInstance;

- (NSOperationQueue *)q;
- (BOOL)isRunning;
- (void)enqueueFeed:(Feed *)feed;
- (void)startUpdating:(Feed *)feed;
- (void)finishedUpdating:(NSManagedObjectID *)fid withError:(NSError *)e;
- (void)finishedUpdating:(NSManagedObjectID *)fid;
- (void)updateNext;
- (BOOL)isFeedQueued:(Feed *)f;
- (BOOL)isFeedUpdating:(Feed *)f;
- (NSSet *)updating;
- (void)checkForUpdatesAndStartNewThread;
- (float)completionRatio;

@end
