//
//  ChannelAttributeNode.h
//  XReader
//
//  Created by Pablo Collins on 11/9/10.
//

#import <Foundation/Foundation.h>
#import "NodeHandler.h"
#import "Feed.h"
#import "PropertyValueDelegate.h"

@interface ContentHandler : NodeHandler {
    NSMutableString *tagContents;
    NSString *tagName, *property;
}

- (id)initWithTagName:(NSString *)n property:(NSString *)p;

@end
