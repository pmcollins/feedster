//
//  CFeedSettings.m
//  XReader
//
//  Created by Pablo Collins on 1/28/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "CFeedSettings.h"
#import "TableViewSection.h"
#import "M.h"
#import "DailyRepeatSubview.h"
#import "COptionSelector.h"
#import "CFolders.h"

#define NAME_TEXTFIELD 0

@implementation CFeedSettings

@synthesize repeatControl, tableView, nameField;

#pragma mark - Stuff

- (void)setOpener:(CArticleTable *)opener
{
    articleTable = opener;
}

- (void)saveTitle
{
    NSString *title = nameField.text;
    feed.title = title;
    [[M sharedInstance] saveMainContext];
}

- (void)done
{
    [self saveTitle];
    [articleTable dismissModalViewControllerAnimated:YES];
}

- (void)setFeed:(Feed *)f
{
    feed = f;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    self.title = @"Feed Settings";
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                       target:self
                                                       action:@selector(done)];
    [repeatControl addTarget:self
                      action:@selector(repeatControlUpdated)
            forControlEvents:UIControlEventValueChanged];
    
    nameField.text = feed.title;
    _urlTextView.text = feed.url;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_categoryButton setTitle:feed.folder.name forState:UIControlStateNormal];
    [_updatePeriodButton setTitle:[NSString stringWithFormat:@"%@ minutes", feed.refreshPeriod] forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == NAME_TEXTFIELD) {
        [self saveTitle];
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Stuff

- (IBAction)openCategoriesForm:(id)sender
{
    CFolders *root = [[CFolders alloc] initWithNibName:@"CFolders" bundle:nil];
    CFoldersClosingCallback cb = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
    [root setCallback:[cb copy]];
    [root setFeed:feed];
    UINavigationController *c = [[UINavigationController alloc] initWithRootViewController:root];
    c.navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:c animated:YES];
}

- (IBAction)openPeriodSelector:(id)sender
{
    COptionSelector *c = [[COptionSelector alloc] initWithOptions:@[
        @[@"Auto", @0],
        @[@"5 minutes", @5],
        @[@"15 minutes", @15],
        @[@"60 minutes", @60],
        @[@"240 minutes", @240]
    ] selected:feed.refreshPeriod feed:feed];
    CallbackAction ca = ^{
        [[M sharedInstance] saveMainContext];
        [self dismissModalViewControllerAnimated:YES];
    };
    c.action = [ca copy];
    [self presentModalViewController:c animated:YES];
}

- (void)viewDidUnload
{
    [self setCategoryButton:nil];
    [self setUrlTextView:nil];
    [self setUpdatePeriodButton:nil];
    [super viewDidUnload];
}

@end
