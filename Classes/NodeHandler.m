//
//  CallbackNode.m
//  XReader
//
//  Created by Pablo Collins on 10/25/10.
//

#import "NodeHandler.h"

@implementation NodeHandler

- (id)init {
    self = [super init];
    map = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)setPropertyValueDelegate:(id <PropertyValueDelegate>)d {
    propertyValueDelegate = d;
}

- (void)setChildHandler:(NodeHandler *)node forKey:(NSString *)key {
    map[key] = node;
}

- (NodeHandler *)childForKey:(NSString *)key {
    return map[key];
}

- (void)tagStartedWithAttributes:(NSDictionary *)attributeDict {
}

- (void)foundCharacters:(NSString *)string {
}

- (void)tagEnded {
}


@end
