//
//  WebPageStripper.h
//  XReader
//
//  Created by Pablo Collins on 6/2/13.
//  Copyright (c) 2013 Trickbot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebPageStripper : NSObject <NSXMLParserDelegate>

- (id)initWithUrl:(NSString *)url;

@end
