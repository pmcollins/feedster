//
//  FeedExplorerDelegate.h
//  XReader
//
//  Created by Pablo Collins on 11/26/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedExplorerDelegate

- (void)explorerFoundFeed:(Feed *)f;
- (void)explorerFoundFeedUrls:(NSArray *)a;
- (void)explorerExploded:(NSString *)e;
- (void)explorerCompleted;

@end
