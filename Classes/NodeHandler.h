//
//  CallbackNode.h
//  XReader
//
//  Created by Pablo Collins on 10/25/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyValueDelegate.h"

@class AbstractFeedReader;

@interface NodeHandler : NSObject {
    NSMutableDictionary *map;
    //FeedReader *delegate;
    id propertyValueDelegate;
}

- (id)init;
- (void)setChildHandler:(NodeHandler *)node forKey:(NSString *)key;
- (void)foundCharacters:(NSString *)string;
- (NodeHandler *)childForKey:(NSString *)key;
- (void)tagStartedWithAttributes:(NSDictionary *)attributeDict;
- (void)tagEnded;
- (void)setPropertyValueDelegate:(id <PropertyValueDelegate>)d;

@end
