//
//  RssArticlesReader.h
//  XReader
//
//  Created by Pablo Collins on 11/19/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractFeedReader.h"
#import "ArticleHandler.h"
#import "UpdateQueue.h"
#import "Feed+Logic.h"

@interface FeedReader : AbstractFeedReader <NSURLConnectionDelegate>

- (id)initWithFeedId:(NSManagedObjectID *)fid updateQueue:(UpdateQueue *)q  data:(NSData *)data;
- (NSManagedObjectContext *)context;
- (Feed *)feed;
- (NSObject<UpdateQueueListener> *)updateQueueListener;

@end
