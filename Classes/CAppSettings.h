//
//  CAppSettings.h
//  XReader
//
//  Created by Pablo Collins on 3/5/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFeedList.h"
#import "TableViewData.h"
#import "PodcastStatusFetcher.h"

@interface CAppSettings : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithOpener:(CFeedList *)o;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
