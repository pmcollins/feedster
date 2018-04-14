//
//  Folder+Logic.m
//  XReader
//
//  Created by Pablo Collins on 12/29/10.
//

#import "Folder+Logic.h"
#import "Feed+Logic.h"
#import "M.h"

@implementation Folder (Folder_Logic)

+ (Folder *)insertFolderWithName:(NSString *)name
{
    Folder *f = [[M sharedInstance] insert:@"Folder"];
    f.name = name;
    NSUInteger highestIndex = [self highestIndex];
    f.orderValue = @(highestIndex + 1);
    return f;
}

+ (NSUInteger)highestIndex
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
    NSSortDescriptor *titleSort = [[NSSortDescriptor alloc] initWithKey:@"orderValue" ascending:NO];
    [req setSortDescriptors:@[titleSort]];
    NSArray *a = [ctx executeFetchRequest:req error:nil];
    if ([a count]) {
        Folder *f = a[0];
        return [f.orderValue intValue];
    } else {
        return 0;
    }
}

+ (NSArray *)orderedFoldersInSet:(NSArray *)ids
{
    NSMutableArray *out = [[NSMutableArray alloc] init];
    
    for (Folder *f in [Folder orderedFolders])
        if ([ids containsObject:f.objectID])
            [out addObject:f];

    if ([ids containsObject:[NSNull null]])
        [out addObject:[NSNull null]];
    
    return out;
}

+ (NSArray *)orderedFolders
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
    NSSortDescriptor *titleSort = [[NSSortDescriptor alloc] initWithKey:@"orderValue" ascending:YES];
    [req setSortDescriptors:@[titleSort]];
    NSError *e;
    NSArray *out = [ctx executeFetchRequest:req error:&e];
    return out;
}

+ (NSArray *)feedsForFolder:(Folder *)f
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
    [req setPredicate:[NSPredicate predicateWithFormat:@"folder == %@", f]];
    NSSortDescriptor *titleSort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [req setSortDescriptors:@[titleSort]];
    NSError *e;
    NSArray *out = [ctx executeFetchRequest:req error:&e];
    return out;
}

+ (NSArray *)unclassifiedFeeds
{
    return [Folder feedsForFolder:nil];
}

- (NSArray *)orderedFeeds
{
    return [Folder feedsForFolder:self];
}

- (NSUInteger)unreadCount
{
    __block NSUInteger out = 0;
    [self.feeds enumerateObjectsUsingBlock:^(id feed, BOOL *stop) {
        out += [feed unreadItemCount];
    }];
    return out;
}

- (NSUInteger)numberOfFeeds
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
    [req setPredicate:[NSPredicate predicateWithFormat:@"folder == %@", self]];
    return [ctx countForFetchRequest:req error:nil];
}

@end
