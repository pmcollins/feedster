//
//  MediaPlaybackDelegate.h
//  XReader
//
//  Created by Pablo Collins on 2/19/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"

@protocol PlayerDelegate <NSObject>

- (void)updateTimeElapsed:(float)timeElapsed progress:(float)progress;
- (void)playerStopped;
- (void)playerStartedForArticleId:(NSManagedObjectID *)articleId;
- (void)applicationDidBecomeActive;

@end
