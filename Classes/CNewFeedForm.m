//
//  CNewFeedForm.m
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//

#import "CNewFeedForm.h"
#import "FeedExplorer.h"
#import "M.h"
#import "CFolders.h"
#import "Feed+Logic.h"
#import "CNewFeedWebBrowser.h"
#import <QuartzCore/QuartzCore.h>
#import "UpdateQueue.h"

#define URL_TEXTFIELD_TAG 0
#define TITLE_TEXTFIELD_TAG 1

@interface CNewFeedForm () {
} @end

@implementation CNewFeedForm

@synthesize titleTextField, categoryButton, saveButton, titleLabel, categoryLabel, navBar;

#pragma mark - View Lifecycle

#define kNewFeedFormInstructionsDisplayedKey @"NewFeedFormInstructionsDisplayed"

- (void)viewDidLoad
{
    [super viewDidLoad];

    _urlTextField.delegate = self;
    [_urlTextField becomeFirstResponder];
    titleTextField.delegate = self;
    saveButton.enabled = NO;

    navBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(close)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kNewFeedFormInstructionsDisplayedKey]) {
        [[[UIAlertView alloc] initWithTitle:@"Adding a feed"
                                    message:@"Enter a Web address here. The address can be a for a site (eg. 'example.com'), or it can be for a feed or podcast (eg. 'example.com/feed.rss')."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNewFeedFormInstructionsDisplayedKey];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark -

- (void)dismissKeyboard
{
    [titleTextField resignFirstResponder];
    [_urlTextField resignFirstResponder];
    navBar.topItem.rightBarButtonItem = nil;
}

- (void)setOpener:(CFeedList *)o
{
    cFeedList = o;
}

- (void)openModalActivityIndicator
{
    if (modalActivityIndicator != nil) {
        raise(0);
    }
    modalActivityIndicator = [[ModalActivityIndicator alloc] initWithFrame:CGRectMake(110, 190, 100, 100)];
    [self.view addSubview:modalActivityIndicator];
}

- (void)closeModalActivityIndicator
{
    if (!modalActivityIndicator) return;
    [modalActivityIndicator removeFromSuperview];
    modalActivityIndicator = nil;
}

- (void)loadTextFieldUrl
{
    [self loadUrl:_urlTextField.text];
    [self openModalActivityIndicator];
}

- (IBAction)continueButtonTouched
{
    [self loadTextFieldUrl2];
}

- (void)loadUrl:(NSString *)urlString
{
    if (![urlString length]) {
        return;
    }
    FeedExplorer *explorer = [[FeedExplorer alloc] init];
    [explorer setDelegate:self];
    [explorer loadUrl:[NSURL URLWithString:urlString] findLinks:NO];
}

- (void)cancelUrlEntry {
    [_urlTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag) {
        case URL_TEXTFIELD_TAG:
            if (textField.text.length + string.length) {
                //        _continueButton.hidden = NO;
                _titleCategoryContainerView.hidden = YES;
                if (navBar.topItem.rightBarButtonItem == nil) {
                    navBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss"
                                                                                         style:UIBarButtonItemStyleBordered
                                                                                        target:self
                                                                                        action:@selector(dismissKeyboard)];
                }
            }
    }

    return YES;
}

- (void)loadTextFieldUrl2
{
    _continueButton.hidden = YES;
    _urlTextField.text = [FeedExplorer fixupFeedUrl:_urlTextField.text];
    [self loadUrl:_urlTextField.text];
    navBar.topItem.rightBarButtonItem = nil;
    [_urlTextField resignFirstResponder];
    [self openModalActivityIndicator];    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case URL_TEXTFIELD_TAG:
            if (textField.text.length == 0) {
                return NO;
            }
            [self loadTextFieldUrl2];
            return YES;
            break;
        case TITLE_TEXTFIELD_TAG:
            navBar.topItem.rightBarButtonItem = nil;
            [titleTextField resignFirstResponder];
            break;
        default:
            break;
    }
    return NO;
}

#pragma mark - FeedReaderDelegate

- (void)explorerFoundFeed:(Feed *)f
{
    [self closeModalActivityIndicator];

    _instructionLabel.hidden = YES;

    _titleCategoryContainerView.hidden = NO;
    
    saveButton.enabled = YES;
    titleTextField.text = f.title;
    feed = f;
    feed.url = _urlTextField.text;
    feed.refreshPeriod = @0;
    feed.newItemCount = @0;
    feed.isUpdatedHourly = @YES;
    feed.dailyRefreshTime = @600;
    feed.completedFirstUpdate = @NO;
}

- (void)explorerFoundFeedUrls:(NSArray *)a
{
    _urlTextField.text = a[0];
    [self loadUrl:a[0]];
}

- (void)explorerExploded:(NSString *)e
{
    [self closeModalActivityIndicator];
    saveButton.enabled = NO;
    
//    Warning: Attempt to dismiss from view controller <CNewFeedForm: 0xa0a0420> while a presentation or dismiss is in progress!
    [self showWebView];
}

- (void)explorerCompleted
{
}

- (void)alertView:(UIAlertView *)av
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

#pragma mark - actions

- (void)close
{
    [[[M sharedInstance] mainManagedObjectContext] rollback];
    [cFeedList dismissModalViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    feed.title = titleTextField.text;
    [[M sharedInstance] saveMainContext];
    
    //at this point, CFeedList: viewWillAppear runs and the feeds are reloaded
    [cFeedList dismissModalViewControllerAnimated:YES];

    [[UpdateQueue sharedInstance] enqueueFeed:feed];
    [[UpdateQueue sharedInstance] checkForUpdatesAndStartNewThread];
    
    [cFeedList scrollToFeed:feed];
}

- (IBAction)openCategoriesForm:(id)sender
{
    CFolders *root = [[CFolders alloc] initWithNibName:@"CFolders" bundle:nil];
    CFoldersClosingCallback cb = ^{
        [categoryButton setTitle:feed.folder.name forState:UIControlStateNormal];
        categoryButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        categoryButton.titleLabel.textColor = [UIColor blackColor];
        [self dismissModalViewControllerAnimated:YES];
    };
    [root setCallback:[cb copy]];
    [root setFeed:feed];
    UINavigationController *c = [[UINavigationController alloc] initWithRootViewController:root];
    c.navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:c animated:YES];
}

#pragma mark - browser

- (void)showWebView
{
    CNewFeedWebBrowser *c = [[CNewFeedWebBrowser alloc] initWithNibName:@"CNewFeedWebBrowser" bundle:nil];
    c.cNewFeedForm = self;
    c.startingUrl = _urlTextField.text;
    [self presentViewController:c animated:YES completion:^{
        [c exploreForEmbeddedFeedUrl:[NSURL URLWithString:_urlTextField.text]];
    }];
}

- (void)hideWebView
{
//    _webView.hidden = YES;
//    [_webView removeFromSuperview];
//    _webView = nil;
}

- (void)viewDidUnload
{
    [self setUrlTextField:nil];
    [self setInstructionLabel:nil];
    [self setContinueButton:nil];
    [self setTitleCategoryContainerView:nil];
    [super viewDidUnload];
}

@end
