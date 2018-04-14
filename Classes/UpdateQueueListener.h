//
//  UpdateQueueListener.h
//  XReader
//
//  Created by Pablo Collins on 12/10/10.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@protocol UpdateQueueListener

- (void)feedEnqueued:(NSManagedObjectID *)feedId;
- (void)feedDidStartUpdating:(NSManagedObjectID *)feedId;
- (void)foundNewItemWithId:(NSManagedObjectID *)articleId;
- (void)discardingExistingItem;
- (void)feedDidFinishUpdating:(NSManagedObjectID *)feedId;
- (void)nothingLeftToUpdate;

@end
