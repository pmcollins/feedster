//
//  RssArticle.h
//  XReader
//
//  Created by Pablo Collins on 11/11/10.
//

#import <Foundation/Foundation.h>
#import "NodeHandler.h"
#import "Article.h"
#import "PropertyValueDelegate.h"
#import "Feed.h"
#import "UpdateQueueListener.h"

@class FeedReader;

@interface ArticleHandler : NodeHandler <PropertyValueDelegate> {
    Article *article;
    NSDate *now;
    int itemCounter;
    NSDateFormatter *dateFormatter, *dateFormatter2;
    FeedReader *_feedReader;
}

- (id)initWithReader:(FeedReader *)reader;
- (void)setDateFormat;

@end
