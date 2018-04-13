//
//  DownloadListener.h
//  XReader
//
//  Created by Pablo Collins on 5/6/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import "Article.h"
#import <AVFoundation/AVFoundation.h>

@protocol DownloadListener <NSObject>

- (void)downloadQueuedForArticleId:(NSManagedObjectID *)articleId;

- (void)downloadStartedForArticleId:(NSManagedObjectID *)articleId;

- (void)downloadReachedCompletionRatio:(float)completionRatio
                         forArticleId:(NSManagedObjectID *)articleId;

- (void)downloadCompletedForArticleId:(NSManagedObjectID *)articleId;

- (void)assetLoaded:(AVAsset *)asset
      forArticleId:(NSManagedObjectID *)articleId
             feedId:(NSManagedObjectID *)fid;

@end
