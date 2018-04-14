//
//  AttributeHandler.m
//  XReader
//
//  Created by Pablo Collins on 11/26/10.
//

#import "AttributeHandler.h"

@implementation AttributeHandler

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    propertyDict = dict;
    return self;
}

- (id)initWithAttributeName:(NSString *)n property:(NSString *)p {
    self = [super init];
    propertyDict = @{n: p};
    return self;
}

- (void)tagStartedWithAttributes:(NSDictionary *)tagAttributes {
    [propertyDict enumerateKeysAndObjectsUsingBlock:^(id attributeName, id property, BOOL *stop) {
        NSString *value = tagAttributes[attributeName];
        [propertyValueDelegate handlerFoundValue:value forName:attributeName property:property];
    }];
}

@end
