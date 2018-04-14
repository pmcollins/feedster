//
//  RdfArticleHandler.m
//  XReader
//
//  Created by Pablo Collins on 1/26/11.
//

#import "RdfArticleHandler.h"
#import "FormatUtil.h"

@implementation RdfArticleHandler

- (void)setDateFormat {
    dateFormatter = [FormatUtil sharedInstance].rdfDateFormat;
}

@end
