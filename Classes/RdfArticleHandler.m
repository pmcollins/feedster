//
//  RdfArticleHandler.m
//  XReader
//
//  Created by Pablo Collins on 1/26/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "RdfArticleHandler.h"
#import "FormatUtil.h"

@implementation RdfArticleHandler

- (void)setDateFormat {
    dateFormatter = [FormatUtil sharedInstance].rdfDateFormat;
}

@end
