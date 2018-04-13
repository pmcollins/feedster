//
//  Folder+Logic.h
//  XReader
//
//  Created by Pablo Collins on 12/29/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import "Folder.h"

@interface Folder (Folder_Logic)

+ (NSArray *)orderedFoldersInSet:(NSArray *)ids;
+ (NSArray *)orderedFolders;
+ (NSArray *)unclassifiedFeeds;
+ (Folder *)insertFolderWithName:(NSString *)name;

- (NSArray *)orderedFeeds;
- (NSUInteger)unreadCount;
- (NSUInteger)numberOfFeeds;

@end
