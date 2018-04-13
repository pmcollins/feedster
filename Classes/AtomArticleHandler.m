//
//  AtomArticleHandler.m
//  XReader
//
//  Created by Pablo Collins on 1/23/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "AtomArticleHandler.h"
#import "FormatUtil.h"

@implementation AtomArticleHandler

- (void)setDateFormat {
    dateFormatter = [FormatUtil sharedInstance].atomDateFormat1;
    dateFormatter2 = [FormatUtil sharedInstance].atomDateFormat2;
}

@end
