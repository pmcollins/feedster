//
//  ChannelAttributeNode.m
//  XReader
//
//  Created by Pablo Collins on 11/9/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "ContentHandler.h"

@implementation ContentHandler

- (id)initWithTagName:(NSString *)n property:(NSString *)p {
    self = [super init];
    tagName = n;
    property = p;
    return self;
}

- (void)tagStartedWithAttributes:(NSDictionary *)attributeDict {
    tagContents = [[NSMutableString alloc] init];
}

- (void)foundCharacters:(NSString *)string {
    [tagContents appendString:string];
}

- (void)tagEnded {
    NSString *trimmed = [tagContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [propertyValueDelegate handlerFoundValue:trimmed forName:tagName property:property];
    tagContents = nil;
}

@end
