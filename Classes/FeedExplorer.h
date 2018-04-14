//
//  RssTitleReader.h
//  XReader
//
//  Created by Pablo Collins on 11/14/10.
//

#import <Foundation/Foundation.h>
#import "AbstractFeedReader.h"
#import "Feed.h"
#import "ContentHandler.h"
#import "ValueDelegate.h"
#import "ResourceDownload.h"

@class ResourceDownload;

@interface FeedExplorer : AbstractFeedReader <PropertyValueDelegate, ValueDelegate, ResourceDownloadDelegate> {
    Feed *feed;
}

+ (NSString *)fixupFeedUrl:(NSString *)urlString;
+ (BOOL)documentAppearsToBeAFeed:(NSString *)doc;

- (void)loadUrl:(NSURL *)url findLinks:(BOOL)findLinks;

@end
