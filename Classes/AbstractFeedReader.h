//
//  FeedParser.h
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//

#import <Foundation/Foundation.h>
#import "NodeHandler.h"
#import "Feed.h"
#import "FeedExplorerDelegate.h"

@interface AbstractFeedReader : NSOperation <NSXMLParserDelegate> {
    BOOL _errorOccurred;
    NodeHandler *_currNodeHandler, *_rootNodeHandler, *_channelHandler, *_rssRdfNodeHandler, *_atomFeedHandler;
    NSMutableArray *_nodeStack;
    AbstractFeedReader *_parent;
    int _unchartedDepth;
    id<FeedExplorerDelegate> _delegate;
}

- (void)setDelegate:(id<FeedExplorerDelegate>)d;
- (void)loadDocument:(NSString *)doc;
- (BOOL)errorOccurred;

@end
