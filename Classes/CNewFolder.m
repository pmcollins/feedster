//
//  CNewFolder.m
//  XReader
//
//  Created by Pablo Collins on 12/20/10.
//

#import "CNewFolder.h"
#import "Folder+Logic.h"
#import "M.h"

@interface CNewFolder () {
    CFolders *_cFolders;
    Folder *_folder;
} @end

@implementation CNewFolder

@synthesize nameField;

- (void)viewWillAppear:(BOOL)animated
{
    [nameField becomeFirstResponder];
}

- (void)setCFolders:(CFolders *)f {
    _cFolders = f;
}

- (void)close {
    [_cFolders newFolderCreated:_folder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    NSString *name = nameField.text;
    if ([name length]) {
        _folder = [Folder insertFolderWithName:name];
        [[M sharedInstance] saveMainContext];
    }
    [self close];
}

- (IBAction)close:(id)sender {
    [self close];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [nameField resignFirstResponder];
    return YES;
}

@end
