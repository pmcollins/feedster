//
//  Folder.h
//  XReader
//
//  Created by Pablo Collins on 1/8/11.
//

#import <CoreData/CoreData.h>

@class Feed;

@interface Folder : NSManagedObject  
{
}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet* feeds;
@property (nonatomic, strong) NSNumber* orderValue;

@end


@interface Folder (CoreDataGeneratedAccessors)
- (void)addFeedsObject:(Feed *)value;
- (void)removeFeedsObject:(Feed *)value;
- (void)addFeeds:(NSSet *)value;
- (void)removeFeeds:(NSSet *)value;

@end

