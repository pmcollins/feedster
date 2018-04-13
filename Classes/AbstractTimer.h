//
//  AbstractTimer.h
//  
//
//  Created by Pablo Collins on 3/13/11.
//  Copyright 2011 trickbot. All rights reserved.
//

@interface AbstractTimer : NSObject {
    NSTimer *nsTimer;
    NSCalendar *cal;
}

- (id)initWithWakePeriod:(NSTimeInterval)wakePeriod;
- (NSDateComponents *)dateComponents;
- (void)timerPing:(NSTimer *)t;

@end
