//
//  CNewFolder.h
//  XReader
//
//  Created by Pablo Collins on 12/20/10.
//

#import <UIKit/UIKit.h>
#import "CFolders.h"

@interface CNewFolder : UIViewController <UITextFieldDelegate> {
}

@property (nonatomic, strong) IBOutlet UITextField *nameField;

- (void)setCFolders:(CFolders *)f;
- (IBAction)save:(id)sender;
- (IBAction)close:(id)sender;

@end
