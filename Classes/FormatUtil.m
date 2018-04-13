//
//  FormatUtil.m
//  XReader
//
//  Created by Pablo Collins on 5/4/13.
//  Copyright (c) 2013 Trickbot. All rights reserved.
//

#import "FormatUtil.h"

@implementation FormatUtil

+ (FormatUtil *)sharedInstance
{
    static FormatUtil *me;
    if (me == nil) {
        me = [[FormatUtil alloc] init];
        [me setup];
    }
    return me;
}

- (void)setup
{
     _rssDateFormat1 = [[NSDateFormatter alloc] init];
    [_rssDateFormat1 setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];

     _rssDateFormat2 = [[NSDateFormatter alloc] init];
    [_rssDateFormat2 setDateFormat:@"dd MMM yyyy HH:mm:ss zzz"];
    
    //2011-01-23T14:45:45Z
     _atomDateFormat1 = [[NSDateFormatter alloc] init];
    [_atomDateFormat1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [_atomDateFormat1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    //2010-11-12T04:25:06.325-08:00
     _atomDateFormat2 = [[NSDateFormatter alloc] init];
    [_atomDateFormat2 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSzzz:00"];
    [_atomDateFormat2 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
     _rdfDateFormat = [[NSDateFormatter alloc] init];
    [_rdfDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz:00"];
    
     _cellFormatter = [[NSDateFormatter alloc] init];
    [_cellFormatter setDateFormat:@"h:mm a"];
}

@end
