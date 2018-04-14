//
//  FormatUtil.h
//  XReader
//
//  Created by Pablo Collins on 5/4/13.
//

#import <Foundation/Foundation.h>

@interface FormatUtil : NSObject

+ (FormatUtil *)sharedInstance;

@property NSDateFormatter * rssDateFormat1;
@property NSDateFormatter * rssDateFormat2;

@property NSDateFormatter * atomDateFormat1;
@property NSDateFormatter * atomDateFormat2;

@property NSDateFormatter * rdfDateFormat;

@property NSDateFormatter * cellFormatter;

@end
