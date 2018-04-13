//
//  CSubscriptionTable.m
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "CFeedList.h"
#import "CNewFeedForm.h"
#import "M.h"
#import "CArticleTable.h"
#import "UpdateQueue.h"
#import "FeedCell.h"
#import "Feed+Logic.h"
#import "Folder.h"
#import "Folder+Logic.h"
#import "CAppSettings.h"
#import "PodcastStatusFetcher.h"
#import "CModalPlayer.h"
#import "FFBadge.h"
#import "DownloadQueue.h"
#import "XReaderAppDelegate.h"

@interface CFeedList() {
    NSDictionary *_feedsInFolders;
    NSArray *_folders;
    NSMutableDictionary *_podcastStatusFetcherMap;
    FFBadge *_badge;
    UIRefreshControl *_refreshControl;
    Feed *_lastFeedSeen;
//    UILabel *_noFeedsLabel;
} @end

@implementation CFeedList

#pragma mark - View lifecycle

#define kFeedListInstructionsDisplayedKey @"FeedListInstructionsDisplayed"
#define kFeedAddedMessageDisplayedKey @"FeedAddedMessageDisplayed"

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.tableView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showSettings)];
    
    _updatingFeedSpinner.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    _badge = [[FFBadge alloc] initWithFrame:CGRectMake(30, 2, 20, 20)];
    [_toolBar addSubview:_badge];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    self.title = @"Feedster";
    
    [self resetPodcastStatusFetcherMap];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFeedListInstructionsDisplayedKey]) {
        [self performSelector:@selector(showFeedListInstructions) withObject:nil afterDelay:0.5];
    }
}

- (void)showFeedListInstructions
{
    [[[UIAlertView alloc] initWithTitle:@"Welcome to Feedster"
                                message:@"To add a feed or podcast, touch the '+' button at the bottom right."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFeedListInstructionsDisplayedKey];
}

- (void)resetPodcastStatusFetcherMap
{
    _podcastStatusFetcherMap = [[NSMutableDictionary alloc] initWithCapacity:30];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //clear this in case the user navigated away before the last d/l completed
    _updatingFeedLabel.text = nil;
    
    [UpdateQueue sharedInstance].delegate = self;
    [DownloadQueue sharedInstance].delegate = self;
    
    _feedsInFolders = [Feed feedsInFolders];
    _folders = [Folder orderedFoldersInSet:[_feedsInFolders allKeys]];
    
    NSIndexPath *selectedIp;
    if (_lastFeedSeen) {
        selectedIp = [self indexPathForFeed:_lastFeedSeen];
    }
    [self.tableView reloadData];
    if (selectedIp) {
        [self.tableView selectRowAtIndexPath:selectedIp animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self.tableView deselectRowAtIndexPath:selectedIp animated:YES];
    }

    [self showPlayerButton];

    [self showCurrentUpdatingFeed];
    
    [self setUpFFBadge];
    
    [self hideUpdateQueueProgress];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFeedAddedMessageDisplayedKey] && _feedsInFolders.count) {
        [[[UIAlertView alloc] initWithTitle:@"Feed Added"
                                    message:@"Feedster will update this feed automatically, with a frequency determined by the feed's current activity."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFeedAddedMessageDisplayedKey];
    }
    
//    if (!_feedsInFolders.count) {
//        _noFeedsLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, ([[UIScreen mainScreen] applicationFrame].size.height / 2) - 91, 180, 30)];
//        _noFeedsLabel.textAlignment = NSTextAlignmentCenter;
//        _noFeedsLabel.textColor = [UIColor whiteColor];
//        _noFeedsLabel.font = [UIFont boldSystemFontOfSize:16];
//        _noFeedsLabel.layer.cornerRadius = 8;
//        _noFeedsLabel.text = @"Tap '+' to add a feed";
//        _noFeedsLabel.backgroundColor = [UIColor grayColor];
//        [self.tableView addSubview:_noFeedsLabel];
//    } else if (_noFeedsLabel) {
//        [_noFeedsLabel removeFromSuperview];
//    }
}

- (void)viewDidUnload
{
    [self setUpdatingFeedLabel:nil];
    [self setUpdatingFeedSpinner:nil];
    [self setFfButton:nil];
    [self setProgressView:nil];
    [super viewDidUnload];
}

#pragma mark -

- (void)setLastFeedSeen:(Feed *)feed
{
    _lastFeedSeen = feed;
}

#pragma mark - IBActions and callbacks

- (void)handleRefresh:(id)thing
{
    [self fetchAllFeeds:nil];
    [_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
}

- (void)showSettings
{
    CAppSettings *s = [[CAppSettings alloc] initWithOpener:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:s];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    nav.navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:nav animated:YES];
}

- (void)addFeed:(id)sender
{
    BOOL isFullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefFullVersion];
    NSUInteger numFeeds = [Feed unorderedFeeds].count;
    
    if (!isFullVersion && numFeeds > 4) {
        [[[UIAlertView alloc] initWithTitle:@"Maximum Feeds Reached" message:@"Upgrade to premium for unlimited feeds and no ads. Touch the settings button at the top left to upgrade to premium." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else {
        CNewFeedForm *f = [[CNewFeedForm alloc] initWithNibName:@"CNewFeedForm" bundle:nil];
        [f setOpener:self];
        [self presentModalViewController:f animated:YES];        
    }
}

- (IBAction)fetchAllFeeds:(id)sender
{
    NSArray *feeds = [Feed feedsOrderedByUpdateTime];
    Feed *f;
    for (f in feeds) {
        [[UpdateQueue sharedInstance] enqueueFeed:f];
    }
    [[UpdateQueue sharedInstance] checkForUpdatesAndStartNewThread];
}

- (void)showCurrentUpdatingFeed
{
    NSSet *updating = [[UpdateQueue sharedInstance] updating];
    if ([updating count]) {
        NSManagedObjectID *fid = [updating anyObject];
        [self showUpdatingFeedId:fid];
    } else {
        [self hideUpdatingFeed];
    }
}

- (void)showUpdatingFeedId:(NSManagedObjectID *)fid
{
    Feed *feed = (Feed *)[[[M sharedInstance] mainManagedObjectContext] objectWithID:fid];

    _updatingFeedLabel.text = feed.title;
    _updatingFeedLabel.hidden = NO;
    [_updatingFeedSpinner startAnimating];
}

- (void)hideUpdatingFeed
{
    _updatingFeedLabel.text = nil;
    _updatingFeedLabel.hidden = YES;
    [_updatingFeedSpinner stopAnimating];
}

- (void)showUpdateQueueProgress
{
    _progressView.hidden = NO;
    _progressView.progress = [[UpdateQueue sharedInstance] completionRatio];
}

- (void)hideUpdateQueueProgress
{
    _progressView.hidden = YES;
    _progressView.progress = 0;
}

#pragma mark - Data Management

- (void)scrollToFeed:(Feed *)f
{
    NSIndexPath *ip = [self indexPathForFeed:f];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)reloadRowForFeed:(Feed *)f
{
    [self.tableView reloadData];
}

- (void)setUpFFBadge
{
    NSUInteger count = [Feed ffCount];
    if (count == 0) {
        self.ffButton.enabled = NO;
        [_badge hideFFCountBadge:YES];
    } else {
        self.ffButton.enabled = YES;
        [_badge hideFFCountBadge:NO];
        [_badge setFFCount:[NSString stringWithFormat:@"%lu", (unsigned long)count]];
    }
}

- (IBAction)fastForward:(id)sender
{
    Feed *f = [Feed firstFeedWithUnreadItems];
    CArticleTable *articleTable = [[CArticleTable alloc] initWithNibName:@"CArticleTable" bundle:nil];
    [articleTable setCFeedList:self];
    [articleTable setFeed:f];
    [self.navigationController pushViewController:articleTable animated:YES];

}

- (FeedCell *)visibleCellForFeedId:(NSManagedObjectID *)fid
{
    for (FeedCell *cell in [self.tableView visibleCells]) {
        if ([cell.feed.objectID isEqual:fid]) {
            return cell;
        }
    }
    return nil;
}

- (NSArray *)feedsInSection:(NSInteger)section
{
    id thing = _folders[section];
    return _feedsInFolders[thing == [NSNull null] ? [NSNull null] : ((Folder *)thing).objectID];
}

- (Feed *)feedAtIndexPath:(NSIndexPath *)ip
{
    NSArray *feeds = [self feedsInSection:[ip section]];
    return feeds[[ip row]];
}

- (NSIndexPath *)indexPathForFeed:(Feed *)feed
{
    id<NSCopying> folderId = feed.folder == nil ? [NSNull null] : feed.folder.objectID;
    NSArray *feeds = _feedsInFolders[folderId];
    NSUInteger folderIdx = [_folders indexOfObject:feed.folder == nil ? [NSNull null] : feed.folder];
    for (int i = 0; i < feeds.count; i++) {
        if ([feed isEqual:feeds[i]]) {
            return [NSIndexPath indexPathForRow:i inSection:folderIdx];
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_folders count];
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    id<NSCopying> thing = _folders[section];
    if (thing == [NSNull null]) {
        return @"Uncategorized";
    }
    Folder *f = (Folder *)thing;
    return f.name;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self feedsInSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCell";
        
    FeedCell *cell = (FeedCell *) [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:self options:nil];
        cell = _tmpCell;
        [cell setup];
        self.tmpCell = nil;
    }
    Feed *feed = [self feedAtIndexPath:indexPath];
    cell.feed = feed;
    [cell render];
    if ([[UpdateQueue sharedInstance] isFeedUpdating:feed]) {
        [cell startAnimating];
    } else if ([[UpdateQueue sharedInstance] isFeedQueued:feed]) {
        [cell showQueued];
    } else {
        [cell stopAnimating];
    }

    NSManagedObjectID *fid = [feed objectID];
    PodcastStatusFetcher *podcastStatusFetcher = _podcastStatusFetcherMap[fid];
    NSArray *status;
    NSUInteger calculatedRefreshPeriod = [feed.calculatedRefreshPeriod integerValue];
    if (podcastStatusFetcher == nil) {
        //if the table is not scrolling...
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            _podcastStatusFetcherMap[fid] = [[PodcastStatusFetcher alloc] initWithFeedId:fid delegate:self];
        }
    } else {
        if ([podcastStatusFetcher statusIsReady]) {
            status = [podcastStatusFetcher status];
            calculatedRefreshPeriod = [podcastStatusFetcher refreshPeriod];
        }
    }
    [cell setPodcastStatus:status];
    [cell setRefreshPeriod:calculatedRefreshPeriod];

    return cell;
}

- (void)tableView:(UITableView *)tv
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Feed *f = [self feedAtIndexPath:indexPath];
        
        NSManagedObjectID *aid = [[Player sharedInstance] articleIdPlaying];
        if (aid) {
            Article *articlePlaying = (Article *)[[[M sharedInstance] mainManagedObjectContext] objectWithID:aid];
            BOOL isFeedArticlePlaying = [articlePlaying.feed.objectID isEqual:f.objectID];
            if (isFeedArticlePlaying && [[Player sharedInstance] isPlaying]) {
                [[[UIAlertView alloc] initWithTitle:@"Feed in use" message:@"That feed has a podcast currently playing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
            
            //if the player is pointing to the feed but it's not playing
            if (isFeedArticlePlaying) {
                [[Player sharedInstance] clear];
            }
        }
        
        [[[M sharedInstance] mainManagedObjectContext] deleteObject:f];
        [[M sharedInstance] saveMainContext];

        NSInteger rows = [self tableView:tv numberOfRowsInSection:[indexPath section]];

        _feedsInFolders = [Feed feedsInFolders];
        _folders = [Folder orderedFoldersInSet:[_feedsInFolders allKeys]];

        if (rows == 1) {
            [tv deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tv deleteRowsAtIndexPaths:@[indexPath]
                      withRowAnimation:UITableViewRowAnimationFade];            
        }

    }
}

#pragma mark - Table view delegate

- (void)setEditing:(BOOL)editing
          animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CArticleTable *articleTable = [[CArticleTable alloc] initWithNibName:@"CArticleTable" bundle:nil];
    [articleTable setCFeedList:self];
    [articleTable setFeed:[self feedAtIndexPath:indexPath]];
    [self.navigationController pushViewController:articleTable animated:YES];
}

#pragma - Shizzle

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    //NSLog(@"willShowViewController");
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    //NSLog(@"didShowViewController");
}

- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        Feed *feed = [self feedAtIndexPath:indexPath];
        NSManagedObjectID *fid = [feed objectID];
        PodcastStatusFetcher *podcastStatusFetcher = _podcastStatusFetcherMap[fid];
        if (podcastStatusFetcher == nil) {
            _podcastStatusFetcherMap[fid] = [[PodcastStatusFetcher alloc] initWithFeedId:fid delegate:self];
        }
    }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"headphones-white"] style:UIBarButtonItemStyleBordered target:self action:@selector(showPlayer)];
}

#pragma mark - PodcastStatusDelegate

- (void)gotPodcastStatus:(NSArray *)s refreshPeriod:(NSUInteger)refresh forFeedId:(NSManagedObjectID *)fid
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        Feed *feed = [self feedAtIndexPath:indexPath];
        if ([[feed objectID] isEqual:fid]) {
            FeedCell *cell = (FeedCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell setPodcastStatus:s];
            [cell setRefreshPeriod:refresh];
            break;
        }
    }
}

//not a delegate method
- (void)updatePodcastStatusForFeedId:(NSManagedObjectID *)fid
{
    PodcastStatusFetcher *psf = _podcastStatusFetcherMap[fid];
    [psf fetch];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self loadImagesForOnscreenRows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark - FeedUpdateListener delegate

- (void)feedEnqueued:(NSManagedObjectID *)fid
{
    FeedCell *cell = [self visibleCellForFeedId:fid];
    [cell showQueued];
}

- (void)feedDidStartUpdating:(NSManagedObjectID *)fid
{
    FeedCell *cell = [self visibleCellForFeedId:fid];
    [cell startAnimating];
    [self showUpdatingFeedId:fid];
    [self showUpdateQueueProgress];
}

- (void)discardingExistingItem
{
}

- (void)foundNewItemWithId:(NSManagedObjectID *)articleId
{
}

- (void)feedDidFinishUpdating:(NSManagedObjectID *)fid
{
    NSManagedObjectContext *ctx = [[M sharedInstance] mainManagedObjectContext];
    Feed *feed = (Feed *)[ctx objectWithID:fid];
    [ctx refreshObject:feed mergeChanges:YES];
    FeedCell *cell = [self visibleCellForFeedId:feed.objectID];
    [cell stopAnimating];
    [cell render];
    
    [self updatePodcastStatusForFeedId:fid];
    
    if ([[UpdateQueue sharedInstance] isRunning]) {
        [self showUpdateQueueProgress];
    } else {
        [self hideUpdatingFeed];
        [self hideUpdateQueueProgress];
    }
    
    [self setUpFFBadge];
}

- (void)nothingLeftToUpdate
{
}

#pragma mark -

- (void)showDowloadStatusForArticleId:(NSManagedObjectID *)articleId
{
    if (_updatingFeedLabel.text == nil) {
        Article *a = (Article *)[[[M sharedInstance] mainManagedObjectContext] objectWithID:articleId];
        _updatingFeedLabel.text = [NSString stringWithFormat:@"Podcast: %@", a.title];
    }
    _updatingFeedLabel.hidden = NO;
    _updatingFeedSpinner.hidden = NO;
    _progressView.hidden = NO;    
}

#pragma mark - DownloadListener

- (void)downloadQueuedForArticleId:(NSManagedObjectID *)articleId
{
//    NSLog(@"downloadQueuedForArticleId: %@", articleId);
    [self showDowloadStatusForArticleId:articleId];
}

- (void)downloadStartedForArticleId:(NSManagedObjectID *)articleId
{
//    NSLog(@"downloadStartedForArticleId: %@", articleId);
    [self showDowloadStatusForArticleId:articleId];
    [_updatingFeedSpinner startAnimating];
}

- (void)downloadReachedCompletionRatio:(float)completionRatio
                          forArticleId:(NSManagedObjectID *)articleId
{
//    NSLog(@"downloadReachedCompletionRatio:%f forArticleId:%@", completionRatio, articleId);
    [self showDowloadStatusForArticleId:articleId];
    _progressView.progress = completionRatio;
    if (![_updatingFeedSpinner isAnimating]) {
        [_updatingFeedSpinner startAnimating];
    }
}

- (void)downloadCompletedForArticleId:(NSManagedObjectID *)articleId
{
//    NSLog(@"downloadCompletedForArticleId: %@", articleId);
    _updatingFeedLabel.text = nil;
    _updatingFeedLabel.hidden = YES;
    _updatingFeedSpinner.hidden = YES;
    _progressView.hidden = YES;
}

- (void)assetLoaded:(AVAsset *)asset
       forArticleId:(NSManagedObjectID *)articleId
             feedId:(NSManagedObjectID *)fid
{
    [self updatePodcastStatusForFeedId:fid];
}

@end
