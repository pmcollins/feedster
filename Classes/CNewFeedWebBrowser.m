//
//  CNewFeedWebBrowser.m
//  XReader
//
//  Created by Pablo Collins on 10/22/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import "CNewFeedWebBrowser.h"
#import <QuartzCore/QuartzCore.h>
#import "FeedExplorer.h"

#define kFeedBrowserInstructionsDisplayedKey1 @"FeedBrowserInstructionsDisplayed1"
#define kFeedBrowserInstructionsDisplayedKey2 @"FeedBrowserInstructionsDisplayed2"

@interface CNewFeedWebBrowser () {
    NSMutableSet *_urls;
    NSString *_foundUrl;
    UIActionSheet *_sheet;
    BOOL _blockActionSheet;
    UIAlertView *_alertView;
}
@end

@implementation CNewFeedWebBrowser

- (IBAction)cancelTouched:(id)sender {
    [_cNewFeedForm dismissModalViewControllerAnimated:YES];
}

- (IBAction)segControlValueChanged:(id)sender {
    if (_segControl.selectedSegmentIndex == 0) {
        [_webView goBack];
    } else {
        [_webView goForward];
    }
}

- (void)viewDidLoad
{
//    NSLog(@"CNewFeedWebBrowser: viewDidLoad: _startingUrl: %@", _startingUrl);
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startingUrl]]];
    _urls = [[NSMutableSet alloc] init];
    _blockActionSheet = NO;
    
    //setting these in ib results in too much bigness
    [_segControl setImage:[UIImage imageNamed:@"09-arrow-west"] forSegmentAtIndex:0];
    [_segControl setImage:[UIImage imageNamed:@"02-arrow-east"] forSegmentAtIndex:1];

    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _blockActionSheet = YES;
    [super viewWillDisappear:animated];
}

- (void)showFeedBrowserInstructions
{
    // if we've already shown the embedded feed instructions, don't show these ones
    if (_alertView || _blockActionSheet) return;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFeedBrowserInstructionsDisplayedKey1]) {
        [[[UIAlertView alloc] initWithTitle:@"No feeds embedded"
                                    message:@"Feedster will now detect when you touch a feed or podcast link (feeds are often recognizable by their feed icon). Tip 1: If you're looking for a podcast, don't select 'Add to iTunes' links; select 'RSS' Podcast links instead. Tip 2: Mobile versions of Web sites tend to not display feed and podcast links; browse the 'Full Site' for better results if one is offered (often at the bottom of the page)."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFeedBrowserInstructionsDisplayedKey1];
    }
}

- (void)setupWebNavButtons
{
    [_segControl setEnabled:[_webView canGoBack]    forSegmentAtIndex:0];
    [_segControl setEnabled:[_webView canGoForward] forSegmentAtIndex:1];
}

#pragma mark -

- (void)exploreForEmbeddedFeedUrl:(NSURL *)url
{
    NSLog(@"CNewFeedWebBrowser: exploreForEmbeddedFeedUrl: thread: %@, url: %@", [NSThread currentThread], url);
    FeedExplorer *explorer = [[FeedExplorer alloc] init];
    [explorer setDelegate:self];
    [explorer loadUrl:url findLinks:YES];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    NSLog(@"CNewFeedWebBrowser: webViewDidStartLoad");
    [_activityIndicator startAnimating];
    if (_sheet) {
        //this means the action sheet is currently up
        //ignore this finding
        return;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSLog(@"CNewFeedWebBrowser: webViewDidFinishLoad: %@", webView.request.URL);
    if (!_webView.loading) {
        [_activityIndicator stopAnimating];
    }
    [self setupWebNavButtons];
    NSURL *url = webView.request.URL;
    if ([_urls containsObject:url]) {
        NSLog(@"webViewDidFinishLoad: [_urls containsObject:url]: url: %@", url);
    } else {
        NSLog(@"webViewDidFinishLoad: ![_urls containsObject:url]: url: %@", url);
        [self exploreForEmbeddedFeedUrl:url];
        [_urls addObject:url];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    NSLog(@"CNewFeedWebBrowser: didFailLoadWithError: %@", error);
    if (error.code == 101 || error.code == 102) {
        NSString *url = (error.userInfo)[NSURLErrorFailingURLStringErrorKey];
        [self selectUrl:url];
    }
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setSegControl:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

#pragma mark -

- (void)selectUrl:(NSString *)url
{
    _cNewFeedForm.urlTextField.text = [FeedExplorer fixupFeedUrl:url];
    [_cNewFeedForm loadTextFieldUrl];
    [_cNewFeedForm dismissModalViewControllerAnimated:YES];
}

#pragma mark - FeedExplorerDelegate

- (void)explorerFoundFeed:(Feed *)f
{
}

- (void)explorerFoundFeedUrls:(NSArray *)a
{
    NSLog(@"explorerFoundFeedUrls: %@", a);
    [self performSelectorOnMainThread:@selector(openActionSheetForFeedUrls:) withObject:a waitUntilDone:NO];
}

- (void)explorerExploded:(NSString *)e
{
    //no links found
    [self performSelectorOnMainThread:@selector(showFeedBrowserInstructions) withObject:nil waitUntilDone:NO];    
}

- (void)explorerCompleted
{
    NSLog(@"explorerCompleted");
}

#pragma mark - main thread

- (void)showActionSheet
{
    _sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Found embedded feed: %@", _foundUrl]
                                         delegate:self
                                cancelButtonTitle:@"Continue browsing"
                           destructiveButtonTitle:nil
                                otherButtonTitles:@"Select this feed", nil];
    
    [_sheet showInView:self.view];
}

- (void)openActionSheetForFeedUrls:(NSArray *)a
{
    if (_blockActionSheet) {
        return;
    } else {
        _blockActionSheet = YES;
    }
    
    _foundUrl = a[0];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFeedBrowserInstructionsDisplayedKey2]) {
        _alertView = [[UIAlertView alloc] initWithTitle:@"Embedded feed detected"
                                    message:@"This page has an embedded feed. You may either select it (recommended) or continue browsing. If you continue browsing, touch a feed link on the page to select it."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil];
        [_alertView show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFeedBrowserInstructionsDisplayedKey2];
    } else {
        [self showActionSheet];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(showActionSheet) withObject:nil afterDelay:0.5];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //"select this feed"
        [self selectUrl:_foundUrl];
        //_blockActionSheet is YES, so leave it;
    } else {
        _blockActionSheet = NO;
    }
    _sheet = nil;
}

@end
