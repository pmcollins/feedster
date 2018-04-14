//
//  AtomArticleHandler.m
//  XReader
//
//  Created by Pablo Collins on 1/23/11.
//

#import "AtomArticleHandler.h"
#import "FormatUtil.h"

@implementation AtomArticleHandler

- (void)setDateFormat {
    dateFormatter = [FormatUtil sharedInstance].atomDateFormat1;
    dateFormatter2 = [FormatUtil sharedInstance].atomDateFormat2;
}

@end
