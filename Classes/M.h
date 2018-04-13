//
//  M.h
//  RC4
//
//  Created by Pablo Collins on 8/29/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#define NUM_DOWNLOAD_THREADS 1

@interface M : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *mainManagedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (atomic) BOOL deletionLocked;

+ (M *)sharedInstance;

- (void)registerForContextSavesOnMainThread;
- (NSManagedObjectContext *)mainManagedObjectContext;
- (NSManagedObjectContext *)newManagedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSArray *)findAll:(NSString *)name;
- (id)insert:(NSString *)name;
- (id)insert:(NSString *)name context:(NSManagedObjectContext *)ctx;
- (BOOL)saveMainContext;
- (BOOL)saveContext:(NSManagedObjectContext *)ctx;
- (NSManagedObject *)fetchObject:(NSManagedObject *)o
                            name:(NSString *)name
                       inContext:(NSManagedObjectContext *)ctx;
- (BOOL)save:(NSManagedObject *)o;

@end
