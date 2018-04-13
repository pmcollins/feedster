//
//  CArticle.m
//  XReader
//
//  Created by Pablo Collins on 11/21/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "CArticle.h"
#import "M.h"
#import "CArticleDetail.h"
#import "Article+Logic.h"
#import "CModalPlayer.h"
#import "GradientButton.h"
#import "SummaryPopover.h"

#define HTTP_TIMEOUT 16
#define kArticleInstructionsDisplayedKey @"ArticleInstructionsDisplayed"

#import <QuartzCore/QuartzCore.h>

@interface CArticle() {
    Article *_article;
    NSArray *_articles, *_defaultItems;
    NSUInteger _feedIndex, _itemCount;
    NSUInteger _itemsToLoad, _itemsLoaded;
    UISegmentedControl *_prevNextControl, *_fwdBackControl;
    UIActionSheet *_actionSheet;
    Player *_player;
    BOOL _loadWebViewOnDemand;
    UIAlertView *_alertView;
    UISegmentedControl *_tabBar;
    UIView *_bodySubView;
    SummaryPopover *_summary;
} @end

@implementation CArticle

#define IMG_DOWNLOAD_PNG    @"download-inbox-white.png"
#define IMG_PLAY_PNG        @"play-white.png"
#define IMG_PLAYING_PNG     @"pause-white.png"
#define IMG_UNKNOWN_PNG     @"puzzle-piece.png"
#define IMG_QUEUED_PNG      @"11-clock"

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progressBar.progress = 0;
    
    _summary = [[SummaryPopover alloc] init];
    
    [_summary.downloadPlayButton addTarget:self
                                    action:@selector(downloadPlayButtonTouched:)
                          forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_summary];
    
    _itemsToLoad = _itemsLoaded = 0;
    _itemCount = [_articles count];

    _player = [Player sharedInstance];
    
    [self showPlayerButton];

    [self setupDynamicContent];
    
    [_tabBar addTarget:self action:@selector(showTab:) forControlEvents:UIControlEventValueChanged];
    _loadWebViewOnDemand = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self checkMediaStateAndUpdateButton];
    
    [DownloadQueue sharedInstance].delegate = self;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kArticleInstructionsDisplayedKey]) {
        [[[UIAlertView alloc] initWithTitle:@"Article preview"
                                    message:@"While your article loads in the background, an article preview is displayed in a popover. To dismiss the popover, touch the 'Preview' button at the bottom left."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kArticleInstructionsDisplayedKey];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    //this should help with podcast statuses displaying correctly -- otherwise they're not saved
    [[M sharedInstance] saveMainContext];
    [super viewDidDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [_summary resizeForPortrait];
    } else {
        [_summary resizeForLandscape];
    }
    [_summary setNeedsDisplay];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)e
{
    if (e.type == UIEventTypeRemoteControl && e.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
        [self togglePlayback];
    }
}

#pragma mark - Dynamic Content

- (void)setupDynamicContent
{
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    titleView.lineBreakMode = NSLineBreakByTruncatingTail;
    titleView.numberOfLines = 2;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = [UIColor whiteColor];
    titleView.font = [UIFont boldSystemFontOfSize:13];
    titleView.text = _article.title;
    self.navigationItem.titleView = titleView;
    
    _summary.titleLabel.text = _article.title;
    if ([_article.unread boolValue]) {
        _article.unread = @NO;
        [[M sharedInstance] saveMainContext];
    }
    NSString *htmlBody = _article.body;
    if (htmlBody == nil || htmlBody.length == 0) {
        [_summary resizeForPortraitMini];
    } else {
        [_summary.popupWebView loadHTMLString:htmlBody baseURL:nil];
        _summary.popupWebView.scalesPageToFit = NO;
    }
    if (_article.link) {
        NSURL *url = [NSURL URLWithString:_article.link];
        if (url == nil) {
            NSString *urlStr = [_article.link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            url = [NSURL URLWithString:urlStr];
        }
        [_webView loadRequest:[NSURLRequest requestWithURL:url
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:HTTP_TIMEOUT]];
    } else {
        [_webView loadHTMLString:@"<html><body style=\"background-color:black\"><i>No link</i></body></html>" baseURL:nil];
        _progressBar.hidden = YES;
    }
    if (_defaultItems == nil) {
        _defaultItems = _toolBar.items;
    }
}

#pragma mark - Media Play/Download

- (void)startPlayback
{
    [self showPlayerButton];
    [self showPlayer];
    [_player playMediaForArticle:_article];
}

- (void)togglePlayback
{
    if (_player.isPlaying) {
        [_player pause];
    } else {
        [self startPlayback];
    }
}

- (void)downloadMedia
{
    [[DownloadQueue sharedInstance] enqueueDownloadForArticle:_article manualRequest:YES];
}

#pragma mark - Actions

- (void)downloadPlayButtonTouched:(id)sender
{
    if ([_article.downloaded boolValue]) {
        if ([[_player articleIdPlaying] isEqual:[_article objectID]]) {
            [_player pause];
        } else {
            [self startPlayback];
        }
    } else {
        [self downloadMedia];
    }
    [self checkMediaStateAndUpdateButton];
}

- (void)showPreview
{
    [UIView beginAnimations:@"showPreview" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2f];
    _summary.alpha = 1;
    [UIView commitAnimations];
}

- (void)hidePreview
{
    [UIView beginAnimations:@"hidePreview" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2f];
    _summary.alpha = 0;
    [UIView commitAnimations];
}

- (void)showProgressBar
{
    self.progressBar.alpha = 1;
    _fwdBackControl.alpha = 0;
}

- (void)hideProgressBar
{
    self.progressBar.alpha = 0;
    _fwdBackControl.alpha = 1;
}

- (IBAction)previewButtonTouched:(id)sender
{
    if (_summary.alpha == 0) {
        [self showPreview];
    } else {
        [self hidePreview];
    }
}

#pragma mark - Stuff

- (void)loadArticleLink
{
    NSURL *url = [NSURL URLWithString:_article.link];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"]; //this is ignored by the API for some reason
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSString *mimeType = response.MIMEType;
       //NSLog(@"mimeType: %@", mimeType);
       if ([mimeType isEqualToString:@"text/html"] && !_article.mediaUrl) {
           [_webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_TIMEOUT]];
       } else {
           if ([_tabBar selectedSegmentIndex] == 1) {
               //webview already selected!
               [_webView loadRequest:[NSURLRequest requestWithURL:url]];
           } else {
               //NSLog(@"loadWebViewOnDemand = YES");
               _loadWebViewOnDemand = YES;
           }
       }
   }];
}

#pragma mark - Playback Download Buttons

- (void)checkMediaStateAndUpdateButton
{
    if (!_article.mediaUrl || ![_article hasPlayableMediaType]) {
        _summary.titleLabel.frame = CGRectMake(_summary.titleLabel.frame.origin.x,
                                               _summary.titleLabel.frame.origin.y,
                                               280,
                                               _summary.titleLabel.frame.size.height);
    } else {
        NSNumber *downloaded = _article.downloaded;
        BOOL bDownloaded = [downloaded boolValue];
        if (bDownloaded) {
            _summary.downloadPlayButton.enabled = YES;
            _summary.downloadProgress.hidden = _summary.pctDownloadedLabel.hidden = YES;
            if (![[_article downloadRecognized] boolValue]) {
                _summary.downloadPlayButton.hidden = NO;
                _summary.downloadPlayButton.enabled = NO;
                _summary.downloadProgress.hidden = YES;
                [_summary.downloadPlayButton setImage:[UIImage imageNamed:IMG_UNKNOWN_PNG] forState:UIControlStateNormal];
                return;
            } else if ([[_player articleIdPlaying] isEqual:[_article objectID]]) {
                [_summary.downloadPlayButton setImage:[UIImage imageNamed:IMG_PLAYING_PNG] forState:UIControlStateNormal];
            } else {
                [_summary.downloadPlayButton setImage:[UIImage imageNamed:IMG_PLAY_PNG] forState:UIControlStateNormal];
            }
        } else {
            BOOL isQueued = [[DownloadQueue sharedInstance] isQueued:[_article objectID]];
            BOOL isDownloading = [[DownloadQueue sharedInstance] isDownloading:[_article objectID]];
            _summary.pctDownloadedLabel.hidden = _summary.downloadPlayButton.enabled = _summary.downloadProgress.hidden = !isDownloading;
            UIImage *img;
            if (isQueued) {
                img = [UIImage imageNamed:IMG_QUEUED_PNG];
                _summary.downloadPlayButton.enabled = NO;
            } else if (isDownloading) {
                img = nil;
                _summary.downloadPlayButton.enabled = NO;
            } else {
                img = [UIImage imageNamed:IMG_DOWNLOAD_PNG];
            }
            [_summary.downloadPlayButton setImage:img forState:UIControlStateNormal];
        }
        _summary.downloadPlayButton.hidden = NO;        
    }
}

#pragma mark -

- (void)showTab:(id)sender
{
    UISegmentedControl *c = sender;
    if (c.selectedSegmentIndex == 0) {
        _webView.hidden = YES;
    } else {
        if (_loadWebViewOnDemand && _article.link) {
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_article.link]]];
            _loadWebViewOnDemand = NO;
        }
        _webView.hidden = NO;
    }
}

- (void)resetTabBar
{
//    tabBar.selectedSegmentIndex = 0;
//    webView.hidden = YES;
//    bodyViewContainer.hidden = NO;
}

//prev next
- (void)segAction:(id)sender
{
    UISegmentedControl *c = sender;
    if (c.selectedSegmentIndex) {
        if (_feedIndex < [_articles count]-1) {
            _article = _articles[++_feedIndex];
        } else {
            return;
        }
    } else {
        if (_feedIndex > 0) {
            _article = _articles[--_feedIndex];
        } else {
            return;
        }
    }
    [self resetTabBar];
    [self resetLoadingProgress];
    [_webView stopLoading];
    [self setupDynamicContent];
}

- (IBAction)actionButtonTouched:(id)stuff {
    NSURL *url = [NSURL URLWithString:_article.link];
    if (url == nil) {
        NSString *urlStr = [_article.link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [NSURL URLWithString:urlStr];
    }
    
    NSString *msg = [NSString stringWithFormat:@"%@", url];
    
    // social
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[msg] applicationActivities:nil];
    [self presentModalViewController:activityViewController animated:YES];
}

- (void)setArticles:(NSArray *)article index:(NSUInteger)index
{
    _articles = article;
    _feedIndex = index;
    _article = article[index];
}

- (IBAction)curlPage
{
    CArticleDetail *cItemDetail = [[CArticleDetail alloc] initWithNibName:@"CArticleDetail" bundle:nil];
    cItemDetail.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [cItemDetail setArticle:_article];
    [self presentModalViewController:cItemDetail animated:YES];
}

- (IBAction)trash:(id)sender
{
}

- (void)resetLoadingProgress
{
    [self stopAnimating];
    _itemsLoaded = _itemsToLoad = 0;
}

#pragma mark - PlaybackPanel

- (void)showPlayer
{
    CModalPlayer *c = [[CModalPlayer alloc] initWithNibName:@"CModalPlayer" bundle:nil];
    c.opener = self;
    [self presentModalViewController:c animated:YES];
}

- (void)showPlayerButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"headphones-white"]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(showPlayer)];
}

- (void)updateWebNavButtons
{
    if (_webView.canGoBack || _webView.canGoForward) {
        if (_fwdBackControl == nil) {
            _fwdBackControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"09-arrow-west"], [UIImage imageNamed:@"02-arrow-east"]]];
            _fwdBackControl.momentary = YES;
            _fwdBackControl.frame = CGRectMake(104, [[UIScreen mainScreen] applicationFrame].size.height - 80, 140, 30);
            _fwdBackControl.tintColor = [UIColor blackColor];
            _fwdBackControl.segmentedControlStyle = UISegmentedControlStyleBar;
            [_fwdBackControl addTarget:self action:@selector(fwdBackTouched:) forControlEvents:UIControlEventValueChanged];
            
            [self.view addSubview:_fwdBackControl];
        }
        [self setFwdBackControlButtons];
    } else {
        [_fwdBackControl removeFromSuperview];
        _fwdBackControl = nil;
    }
}

- (void)setFwdBackControlButtons
{
    [_fwdBackControl setEnabled:_webView.canGoBack forSegmentAtIndex:0];
    [_fwdBackControl setEnabled:_webView.canGoForward forSegmentAtIndex:1];    
}

- (void)fwdBackTouched:(id)a
{
    if (_fwdBackControl.selectedSegmentIndex == 0) {
        [_webView goBack];
    } else {
        [_webView goForward];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)startAnimating {
}

- (void)stopAnimating {
}

- (void)updateProgressBar
{
    if (self.progressBar.alpha != 1) {
        [self showProgressBar];
    }
    self.progressBar.progress = MAX(0.5, _itemsToLoad == 0 ? 0.0 : (float)_itemsLoaded / _itemsToLoad);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (_itemsToLoad == 0) {
        [self showProgressBar];
        [self startAnimating];
    }
    _itemsToLoad++;
    
    [self updateProgressBar];
}

- (void)incrementLoadedItems
{
    _itemsLoaded++;
    [self updateProgressBar];
    if (_itemsLoaded == _itemsToLoad) {
        [self stopAnimating];
        [self hideProgressBar];
        [self updateWebNavButtons];
        [_summary showCloseButton];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self incrementLoadedItems];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [self incrementLoadedItems];
    if (error.code == 204) {
        [wv stopLoading];
        [wv loadHTMLString:@"<html><body style='background-color:black'></body></html>" baseURL:[[NSBundle mainBundle] resourceURL]];
    }
}

#pragma mark - Download button stuffs

- (void)showDownloadQueued
{
    [_summary.downloadPlayButton setImage:[UIImage imageNamed:IMG_QUEUED_PNG] forState:UIControlStateNormal];
    _summary.downloadPlayButton.enabled = NO;
}

- (void)hideDownloadProgress
{
    _summary.pctDownloadedLabel.hidden = _summary.downloadProgress.hidden = YES;
}

- (void)showDownloadProgress
{
    _summary.pctDownloadedLabel.hidden = _summary.downloadProgress.hidden = NO;
    [_summary.downloadPlayButton setImage:nil forState:UIControlStateNormal];
    _summary.downloadPlayButton.enabled = NO;
}

- (void)setDownloadProgressPct:(NSNumber *)pct
{
    float f = [pct floatValue];
    _summary.downloadProgress.progress = f;
    _summary.pctDownloadedLabel.text = [NSString stringWithFormat:@"%.0f%%", f*100];
}

#pragma mark - DownloadListener

- (void)downloadQueuedForArticleId:(NSManagedObjectID *)articleId
{
    if ([articleId isEqual:_article.objectID]) {
        [self performSelectorOnMainThread:@selector(showDownloadQueued)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)downloadStartedForArticleId:(NSManagedObjectID *)articleId
{
    if ([articleId isEqual:_article.objectID]) {
        [self performSelectorOnMainThread:@selector(showDownloadProgress)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)downloadReachedCompletionRatio:(float)completionRatio
                         forArticleId:(NSManagedObjectID *)articleId
{
    if ([articleId isEqual:_article.objectID]) {
        [self performSelectorOnMainThread:@selector(setDownloadProgressPct:)
                               withObject:@(completionRatio)
                            waitUntilDone:NO];
    }
}

- (void)downloadCompletedForArticleId:(NSManagedObjectID *)articleId
{
    if ([articleId isEqual:_article.objectID]) {
        [self performSelectorOnMainThread:@selector(hideDownloadProgress)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)assetLoaded:(AVAsset *)asset
      forArticleId:(NSManagedObjectID *)articleId
             feedId:(NSManagedObjectID *)fid
{
    if ([articleId isEqual:_article.objectID]) {
        [self performSelectorOnMainThread:@selector(checkMediaStateAndUpdateButton)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)viewDidUnload
{
    [self setPreviewButton:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
}

@end
