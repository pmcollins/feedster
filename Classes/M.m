//
//  M.m
//  RC4
//
//  Created by Pablo Collins on 8/29/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "M.h"

@implementation M

+ (id)sharedInstance
{
    static M *me;
    if (me == nil) {
        me = [[M alloc] init];
    }
    return me;
}

- (void)registerForContextSavesOnMainThread
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

- (NSManagedObjectContext *)newManagedObjectContext
{
    NSManagedObjectContext *ctx = [NSManagedObjectContext new];
    [ctx setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [ctx setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    return ctx;
}

- (NSManagedObjectContext *)mainManagedObjectContext
{
    assert([NSThread isMainThread]);
    if (mainManagedObjectContext == nil) {
        mainManagedObjectContext = [self newManagedObjectContext];
    }
    return mainManagedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator == nil) {
        NSURL *storeUrl =
            [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                                    stringByAppendingPathComponent:@"model.sqlite"]];
        NSError *error = nil;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeUrl
                                                       options:nil
                                                         error:&error];
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel == nil) {
        managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return managedObjectModel;
}

- (NSArray *)findAll:(NSString *)name
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:[self mainManagedObjectContext]];
    [req setEntity:entity];
    NSArray *out = [[self mainManagedObjectContext] executeFetchRequest:req error:nil];
    return out;
}

- (NSManagedObject *)fetchObject:(NSManagedObject *)o
                            name:(NSString *)name
                       inContext:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:ctx];
    [req setEntity:entity];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"self == %@", o];
    [req setPredicate:p];
    NSArray *out = [ctx executeFetchRequest:req error:nil];
    return out[0];
}

- (BOOL)saveContext:(NSManagedObjectContext *)ctx
{
    NSError *e;
    BOOL ok = [ctx save:&e];
    if (!ok) {
        NSLog(@"M: saveContext: failed: %@", e);
    }
    return ok;
}

- (BOOL)saveMainContext
{
    return [self saveContext:[self mainManagedObjectContext]];
}

- (BOOL)save:(NSManagedObject *)o
{
    return [self saveContext:[o managedObjectContext]];
}

- (id)insert:(NSString *)name
     context:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:ctx];
}

- (id)insert:(NSString *)name {
    return [self insert:name context:[self mainManagedObjectContext]];
}

- (void)contextDidSave:(NSNotification *)n
{
    [mainManagedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                               withObject:n
                                            waitUntilDone:YES];
}

@end
