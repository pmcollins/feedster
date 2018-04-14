//
//  CAppSettings.h
//  XReader
//
//  Created by Pablo Collins on 3/5/11.
//

#import <UIKit/UIKit.h>
#import "CFeedList.h"
#import "TableViewData.h"
#import "PodcastStatusFetcher.h"

@interface CAppSettings : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithOpener:(CFeedList *)o;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
