//
//  CNewFeedForm.h
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//

#import <UIKit/UIKit.h>
#import "CFeedList.h"
#import "AbstractFeedReader.h"
#import "ModalActivityIndicator.h"

@interface CNewFeedForm : UIViewController <UITextFieldDelegate, UITextViewDelegate, FeedExplorerDelegate> {
    CFeedList *cFeedList;
    Feed *feed;
    ModalActivityIndicator *modalActivityIndicator;
}

@property (nonatomic, strong) IBOutlet UITextField *titleTextField;
@property (nonatomic, strong) IBOutlet UIButton *categoryButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel, *categoryLabel;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIView *titleCategoryContainerView;

- (void)setOpener:(CFeedList *)o;
- (IBAction)save:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)openCategoriesForm:(id)sender;
- (void)cancelUrlEntry;
- (void)loadTextFieldUrl;
- (IBAction)continueButtonTouched;

@end
