//
//  PodcastStatusFetcher.h
//  XReader
//
//  Created by Pablo Collins on 6/16/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@protocol PodcastStatusDelegate <NSObject>

- (void)gotPodcastStatus:(NSArray *)s refreshPeriod:(NSUInteger)refresh forFeedId:(NSManagedObjectID *)fid;

@end

@interface PodcastStatusFetcher : NSObject

- (id)initWithFeedId:(NSManagedObjectID *)fid delegate:(id<PodcastStatusDelegate>)delegate;
- (BOOL)statusIsReady;
- (NSArray *)status;
- (NSUInteger)refreshPeriod;
- (void)fetch;

@end
