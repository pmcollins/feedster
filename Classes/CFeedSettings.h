//
//  CFeedSettings.h
//  XReader
//
//  Created by Pablo Collins on 1/28/11.
//

#import <UIKit/UIKit.h>
#import "CDaySelector.h"
#import "CArticleTable.h"
#import "TableViewData.h"

@interface CFeedSettings : UIViewController <UITextFieldDelegate> {
    Feed *feed;
    CArticleTable *articleTable;
    UITextField *nameField;
}

@property (nonatomic, strong) IBOutlet UISegmentedControl *repeatControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIButton *categoryButton;
@property (strong, nonatomic) IBOutlet UIButton *updatePeriodButton;
@property (strong, nonatomic) IBOutlet UITextView *urlTextView;

- (IBAction)openCategoriesForm:(id)sender;
- (IBAction)openPeriodSelector:(id)sender;
- (void)setFeed:(Feed *)f;
- (void)setOpener:(CArticleTable *)opener;

@end
