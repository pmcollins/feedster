//
//  WebPageStripper.h
//  XReader
//
//  Created by Pablo Collins on 6/2/13.
//

#import <Foundation/Foundation.h>

@interface WebPageStripper : NSObject <NSXMLParserDelegate>

- (id)initWithUrl:(NSString *)url;

@end
