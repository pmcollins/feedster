//
//  AbstractTimer.h
//  
//
//  Created by Pablo Collins on 3/13/11.
//

@interface AbstractTimer : NSObject {
    NSTimer *nsTimer;
    NSCalendar *cal;
}

- (id)initWithWakePeriod:(NSTimeInterval)wakePeriod;
- (NSDateComponents *)dateComponents;
- (void)timerPing:(NSTimer *)t;

@end
