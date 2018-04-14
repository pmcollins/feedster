//
//  CFolders.h
//  XReader
//
//  Created by Pablo Collins on 12/23/10.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

typedef void (^CFoldersClosingCallback)(void);

@interface CFolders : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    CFoldersClosingCallback callback;
    Folder *_newFolder;
}

@property (nonatomic, strong) NSArray * folders;
@property (nonatomic, strong) Feed * feed;
@property (nonatomic, strong) IBOutlet UITableView * tableView;

- (void)setCallback:(CFoldersClosingCallback)c;
- (IBAction)close:(id)sender;
- (IBAction)newFolder:(id)sender;
- (void)loadData;
- (IBAction)editTouched:(id)sender;
- (void)newFolderCreated:(Folder *)f;

@end
