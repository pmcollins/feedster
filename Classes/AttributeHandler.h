//
//  AttributeHandler.h
//  XReader
//
//  Created by Pablo Collins on 11/26/10.
//

#import <Foundation/Foundation.h>
#import "NodeHandler.h"

@interface AttributeHandler : NodeHandler {
    NSDictionary *propertyDict;
}

- (id)initWithAttributeName:(NSString *)n property:(NSString *)p;
- (id)initWithDictionary:(NSDictionary *)dict;

@end
