//
//  CFolders.m
//  XReader
//
//  Created by Pablo Collins on 12/23/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import "CFolders.h"
#import "M.h"
#import "Folder.h"
#import "CNewFolder.h"
#import "Folder+Logic.h"

@implementation CFolders

@synthesize folders, feed, tableView;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    self.title = feed.title;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (feed) {
        tableView.allowsSelection = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    } else {
        tableView.allowsSelection = NO; //settings mode
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Feed Categories";
    [self loadData];
    [tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (feed && _newFolder) {
        NSUInteger idx = [folders indexOfObject:_newFolder];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:idx inSection:0];
        [tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:tableView didSelectRowAtIndexPath:ip];
    }
    [super viewDidAppear:animated];
}

#pragma mark - Stuff

- (void)cancel
{
    callback();
}

- (void)done
{
    callback();
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [tableView setEditing:editing animated:animated];
}

- (void)loadData
{
    self.folders = [Folder orderedFolders];
}

- (IBAction)editTouched:(id)sender
{
    [tableView setEditing:YES animated:YES];
}

#pragma mark -

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    [self loadData];
    [tableView reloadData];
    [super dismissModalViewControllerAnimated:animated];
}

#pragma mark - Table Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [folders count];
}

- (Folder *)folderAtIndexPath:(NSIndexPath *)ip
{
    return folders[[ip row]];
}
    
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier];
    }
    Folder *folder = [self folderAtIndexPath:indexPath];
    cell.accessoryType = [feed.folder isEqual:folder] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = folder.name;
    cell.showsReorderControl = YES;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([self.folders count] >= 2) {
        return @"Touch 'Edit' to reorder or delete categories";
    } else if ([self.folders count] == 1) {
        return @"Touch the feed category to select it";
    } else {
        return @"Touch 'New Category' below to add a feed category";
    }
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!feed) {
        return;
    }
    Folder *f = [self folderAtIndexPath:indexPath];
    feed.folder = f;
     [[M sharedInstance] saveMainContext];
    [tv reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self close:nil];
}

- (void)tableView:(UITableView *)tv
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Folder *f = [self folderAtIndexPath:indexPath];
        if ([f numberOfFeeds]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"That category has feeds in it"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
            [av show];
        } else {
            [[[M sharedInstance] mainManagedObjectContext] deleteObject:f];
            [[M sharedInstance] saveMainContext];
            [self loadData];
            [tv deleteRowsAtIndexPaths:@[indexPath]
                      withRowAnimation:UITableViewRowAnimationFade];

        }
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Folder *sourceFolder = folders[[sourceIndexPath row]];
    Folder *destinationFolder = folders[[destinationIndexPath row]];
    
    NSNumber *destinationNumber = destinationFolder.orderValue;
    destinationFolder.orderValue = sourceFolder.orderValue;
    sourceFolder.orderValue = destinationNumber;
    
    [[M sharedInstance] saveMainContext];
    [self loadData];
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

#pragma mark -

- (void)setCallback:(CFoldersClosingCallback)c
{
    callback = c;
}

- (IBAction)close:(id)sender
{
    if (callback) {
        callback();
    }
}

- (void)newFolderCreated:(Folder *)f
{
    _newFolder = f;
}

- (IBAction)newFolder:(id)sender
{
    CNewFolder *f = [[CNewFolder alloc] initWithNibName:@"CNewFolder" bundle:nil];
    [f setCFolders:self];
    [self.navigationController pushViewController:f animated:YES];
}

@end
