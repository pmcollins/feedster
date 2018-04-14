//
//  FeedExplorerDelegate.h
//  XReader
//
//  Created by Pablo Collins on 11/26/10.
//

#import <UIKit/UIKit.h>

@protocol FeedExplorerDelegate

- (void)explorerFoundFeed:(Feed *)f;
- (void)explorerFoundFeedUrls:(NSArray *)a;
- (void)explorerExploded:(NSString *)e;
- (void)explorerCompleted;

@end
