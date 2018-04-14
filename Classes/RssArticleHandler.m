//
//  RssArticleHandler.m
//  XReader
//
//  Created by Pablo Collins on 1/23/11.
//

#import "RssArticleHandler.h"
#import "FormatUtil.h"

@implementation RssArticleHandler

- (void)setDateFormat {
    dateFormatter = [FormatUtil sharedInstance].rssDateFormat1;
    dateFormatter2 = [FormatUtil sharedInstance].rssDateFormat2;
}

@end
