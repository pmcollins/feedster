//
//  CDaySelector.h
//  XReader
//
//  Created by Pablo Collins on 1/29/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface CDaySelector : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	NSArray *weekdays;
	NSMutableSet *selectedDays;
	Feed *feed;
}

@end
