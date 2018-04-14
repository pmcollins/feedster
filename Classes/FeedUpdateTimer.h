//
//  Timer.h
//  XReader
//
//  Created by Pablo Collins on 3/11/11.
//

#import <Foundation/Foundation.h>

#import "AbstractTimer.h"

@interface FeedUpdateTimer : AbstractTimer {
}

+ (FeedUpdateTimer *)sharedInstance;

@end
