//
//  Article.h
//  XReader
//
//  Created by Pablo Collins on 2/2/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Feed;

@interface Article : NSManagedObject
{
    NSUInteger order;
}

@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSString * pubDateStr;
@property (nonatomic, strong) NSDate * insertDate;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSDate * pubDate;
@property (nonatomic, strong) NSDate * mediaDownloadDate;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * deleted;
@property (nonatomic, strong) NSNumber * downloaded;
@property (nonatomic, strong) NSNumber * insertOrder;
@property (nonatomic, strong) NSString * mediaUrl;
@property (nonatomic, strong) NSString * guid;
@property (nonatomic, strong) NSString * mediaType;
@property (nonatomic, strong) NSNumber * mediaLength;
@property (nonatomic, strong) NSNumber * playedLength;
@property (nonatomic, strong) NSNumber * unread;
@property (nonatomic, strong) NSNumber * seen;
@property (nonatomic, strong) NSNumber * starred;
@property (nonatomic, strong) NSNumber *fromFirstUpdate;
@property (nonatomic, strong) Feed * feed;
@property (nonatomic, strong) NSNumber * downloadRecognized;

@end
