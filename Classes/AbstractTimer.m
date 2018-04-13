//
//  AbstractTimer.m
//  
//
//  Created by Pablo Collins on 3/13/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "AbstractTimer.h"

@implementation AbstractTimer

- (id)initWithWakePeriod:(NSTimeInterval)wakePeriod
{
    self = [super init];
    cal =  [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    nsTimer = [NSTimer scheduledTimerWithTimeInterval:wakePeriod
                                               target:self
                                             selector:@selector(timerPing:)
                                             userInfo:nil
                                              repeats:YES];
    return self;
}

- (NSDateComponents *)dateComponents
{
    return [cal components:(NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
}

- (void)timerPing:(NSTimer *)t
{
}

@end
