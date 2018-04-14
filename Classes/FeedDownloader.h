//
//  FeedDownloader.h
//  XReader
//
//  Created by Pablo Collins on 2/9/13.
//

#import <Foundation/Foundation.h>
#import "UpdateQueueListener.h"
#import "UpdateQueue.h"

@interface FeedDownloader : NSObject

- (id)initWithFeed:(Feed *)feed
               url:(NSURL *)url
       updateQueue:(UpdateQueue *)q;

- (void)start;

@end
