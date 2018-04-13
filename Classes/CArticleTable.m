//
//  CArticleTable.m
//  XReader
//
//  Created by Pablo Collins on 11/18/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import "CArticleTable.h"
#import "Article.h"
#import "CArticle.h"
#import "M.h"
#import "Feed+Logic.h"
#import "CFolders.h"
#import "UpdateQueue.h"
#import "CFeedSettings.h"
#import "ArticleCell.h"
#import "FFBadge.h"
#import "CModalPlayer.h"
#import "LoadingCell.h"
#import "WebPageStripper.h"

#import <iAd/iAd.h>

#define kAdViewDefaultOffset 138
#define kAdViewDefaultHiddenOffset 44

@interface CArticleTable() {
    Feed *_feed;
    NSMutableArray *_newArticles;
    NSMutableArray *_prevArticles;
	CFeedList *_cFeedList;
	ArticleTitleView *_titleView;
    Player *_player;
    FFBadge *_badge;
    NSUInteger _prevItemCount;
    BOOL _needsExpansion;
    UIRefreshControl *_refreshControl;
    NSMutableDictionary *_cellMap;
} @end

@implementation CArticleTable

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _prevItemCount = 30;
    _needsExpansion = NO;
    _cellMap = [[NSMutableDictionary alloc] initWithCapacity:30];
    return self;
}

#pragma mark -

- (void)expand
{
    if (_needsExpansion) {
        _prevItemCount *= 2;
        [self loadArticles];
        [self.tableView reloadData];
        _needsExpansion = NO;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv
{
    if ([self allItemsAlreadyLoaded]) {
        return;
    }
    [self expand];
}

- (void)scrollViewDidScroll:(UIScrollView *)sv
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self expand];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self loadArticles];
    _player = [Player sharedInstance];
    
    _badge = [[FFBadge alloc] initWithFrame:CGRectMake(30, 2, 20, 20)];
    [_toolBar addSubview:_badge];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)e
{
    if (e.type == UIEventTypeRemoteControl && e.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedIp = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData]; //need this
    [self.tableView selectRowAtIndexPath:selectedIp animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView deselectRowAtIndexPath:selectedIp animated:YES];

    [UpdateQueue sharedInstance].delegate = self;
    _titleView.titleLabel.text = _feed.title;
    
    [self showPlayerButton];
    
    [_badge hideFFCountBadge:YES];
    
    [DownloadQueue sharedInstance].delegate = self;
        
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setUpFFBadge];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UpdateQueue sharedInstance].delegate = nil;

    [_badge hideFFCountBadge:YES];

    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self setFeedsAsSeen];
        [_cFeedList setLastFeedSeen:_feed];
        [_cFeedList resetPodcastStatusFetcherMap];
    }
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
	self.navigationItem.titleView = nil;
}

#pragma mark - Activity Indicator Management

- (void)startActivityIndicator
{
    [_titleView startAnimating];
}

- (void)stopActivityIndicator
{
    [_titleView stopAnimating];
}

#pragma mark - Actions

- (void)handleRefresh:(id)thing
{
	[[UpdateQueue sharedInstance] enqueueFeed:_feed];
    [[UpdateQueue sharedInstance] checkForUpdatesAndStartNewThread];
	[self startActivityIndicator];
    [_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.5];
}

- (IBAction)showSettings
{
	CFeedSettings *f = [[CFeedSettings alloc] initWithNibName:@"CFeedSettings" bundle:nil];
	[f setFeed:_feed];
	[f setOpener:self];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:f];
    nav.navigationBar.tintColor = [UIColor blackColor];
	nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:nav animated:YES];
}

- (IBAction)fastForward:(id)sender
{
    Feed *next = [_feed nextFeedWithUnreadItems];
    if (next) {
        [_badge hideFFCountBadge:YES];
        [self setFeedsAsSeen];
        [self setFeed:next];
        [self loadArticles];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
        [self setUpFFBadge];
        //NSLog(@"fastForward: end");
    }
}

- (IBAction)showMarkAsReadDialog
{
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
													   delegate:self
											  cancelButtonTitle:@"Cancel"
										 destructiveButtonTitle:@"Mark all as Read"
											  otherButtonTitles:@"Mark all as Unread", nil];
	sheet.tag = 1;
	[sheet showInView:self.view];
}

- (IBAction)trash
{
    UIActionSheet *as =[[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete All"
                                          otherButtonTitles:@"Delete Read", nil];
	as.tag = 0;
    [as showInView:self.tableView];
}

- (void)setUpFFBadge
{
    NSUInteger count = [Feed ffCount];
    BOOL thisFeedHasNewItems = [_feed.newItemCount intValue] > 0;
    if (thisFeedHasNewItems) {
        count -= 1;
    }
    if (count == 0) {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.ffButton.enabled = NO;
        [_badge hideFFCountBadge:YES];
    } else {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.ffButton.enabled = YES;
        [_badge hideFFCountBadge:NO];
        [_badge setFFCount:[NSString stringWithFormat:@"%lu", (unsigned long)count]];
    }
}

#pragma mark - UIActionSheetDelegate and related

- (void)handleTrashActionSheet:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [_feed deleteAllItems];
    } else if (buttonIndex == 1) {
        [_feed deleteReadItems];
    } else {
        return;
    }
    [self loadArticles];
    [self.tableView reloadData];
    [self setEditing:NO animated:YES];
}

- (void)handleMarkAsReadActionSheet:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[_feed markAllAsRead];
	} else if (buttonIndex == 1) {
		[_feed markAllAsUnread];
	}
	[self.tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (actionSheet.tag) {
		case 0:
			[self handleTrashActionSheet:buttonIndex];
			break;
		case 1:
			[self handleMarkAsReadActionSheet:buttonIndex];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark UpdateQueueListener Delegate

- (void)feedEnqueued:(NSManagedObjectID *)feedId
{
}

- (void)feedDidStartUpdating:(NSManagedObjectID *)fid
{
    if ([fid isEqual:[_feed objectID]]) {
        [self startActivityIndicator];
    }
}

- (void)discardingExistingItem
{
    //NSLog(@"discardingExistingItem");
}

- (void)foundNewItemWithId:(NSManagedObjectID *)articleId
{
    Article *article = (Article *)[[[M sharedInstance] mainManagedObjectContext] objectWithID:articleId];
    
    Feed *af = article.feed;
    NSManagedObjectID *afid = af.objectID;
    if (![afid isEqual:_feed.objectID]) {
        return;
    }
    
    [self.tableView beginUpdates];
    if ([_newArticles count] == 0) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                      withRowAnimation:UITableViewRowAnimationTop];

    [_newArticles insertObject:article atIndex:0];
    
    [self.tableView endUpdates];
}

- (void)setSubtitle
{
    _titleView.subtitleLabel.text = [NSString stringWithFormat:@"%ld min", (long)[_feed effectiveRefreshPeriod]];
}

- (void)feedDidFinishUpdating:(NSManagedObjectID *)fid
{
    if ([fid isEqual:[_feed objectID]]) {
        [self stopActivityIndicator];
        [self setSubtitle];
    }
    [self setUpFFBadge];
}

- (void)nothingLeftToUpdate
{
}

#pragma mark - Data Management

- (void)setCFeedList:(CFeedList *)f
{
	_cFeedList = f;
}

- (void)setFeed:(Feed *)f
{
    _feed = f;
	self.navigationItem.titleView = _titleView = [[ArticleTitleView alloc] initWithFrame:CGRectMake(0, 0, 190, 32)];
	self.title = _titleView.titleLabel.text = _feed.title;

    [self setSubtitle];
    
	_titleView.faviconView.image = _feed.faviconImage;
}

- (void)setFeedsAsSeen
{
    [Feed setArticlesAsSeen:_newArticles];
    _feed.newItemCount = @0;
}

- (void)loadArticles
{
	[[[M sharedInstance] mainManagedObjectContext] refreshObject:_feed mergeChanges:NO];
    _newArticles = [NSMutableArray arrayWithArray:[_feed newArticles]];
    _prevArticles = [NSMutableArray arrayWithArray:[_feed previousArticles:_prevItemCount]];
}

- (Article *)articleAtIndexPath:(NSIndexPath *)ip
{
    NSInteger numSections = [self numberOfSectionsInTableView:nil];
    NSArray *source;
    if (numSections == 1) {
        source = [_prevArticles count] ? _prevArticles : _newArticles;
    } else {
        NSInteger section = [ip section];
        source = section == 0 ? _newArticles : _prevArticles;
    }
    NSInteger row = [ip row];
    if (row >= [source count]) {
        return nil;
    }
    return source[row];
}

#pragma mark - Helpers

- (BOOL)allItemsAlreadyLoaded
{
    return [_prevArticles count] < _prevItemCount;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    NSInteger out = 0;
    
    if (_newArticles.count) out += 1;
    if (_prevArticles.count) out += 1;
        
    return out;
}

- (NSString *)tableView:(UITableView *)tv
titleForHeaderInSection:(NSInteger)section
{
    NSInteger numSections = [self numberOfSectionsInTableView:nil];
    if (numSections == 1) {
        return [_newArticles count] ? @"New items" : @"Current Items";
    } else {
        return section == 0 ? [NSString stringWithFormat:@"New Items (%lu)", (unsigned long)[_newArticles count]] : @"Previous Items";
    }
}

- (NSInteger)tableView:(UITableView *)tv
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger numSections = [self numberOfSectionsInTableView:tv];
    NSInteger out;
    
    int loadingRow = [self allItemsAlreadyLoaded] ? 0 : 1;

    if (numSections == 1) {
        if ([_prevArticles count]) {
            out = [_prevArticles count] + loadingRow;
        } else {
            out = [_newArticles count];
        }
    } else {
        out = section == 0 ? [_newArticles count] : [_prevArticles count] + loadingRow;
    }
        
    return out;
}

- (UITableViewCell *)tableView:(UITableView*)tv
         cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    Article *article = [self articleAtIndexPath:indexPath];
    
    UITableViewCell *cell;
    if (article == nil) {
        cell = [[LoadingCell alloc] init];
        [((LoadingCell *)cell).activityIndicator startAnimating];
        _needsExpansion = YES;
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ArticleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        }
        [(ArticleCell *)cell setArticle:article];
        _cellMap[article.objectID] = cell;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article = [self articleAtIndexPath:indexPath];
    if (cell.class == ArticleCell.class) {
        [(ArticleCell *)cell setIsUnread:[article.unread boolValue]];
    }
}

- (void)tableView:(UITableView *)tv
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger prevArticleCount = _prevArticles.count;
    NSUInteger newArticleCount = _newArticles.count;
    
    BOOL isPrevDeleted = indexPath.section == 1 || (indexPath.section == 0 && newArticleCount == 0);

    Article *article = [self articleAtIndexPath:indexPath];
    article.deleted = @YES;
    [article deleteMediaFile];
    
    [[M sharedInstance] saveMainContext];
    
    [self loadArticles];
    
    [tv beginUpdates];
    [tv deleteRowsAtIndexPaths:@[indexPath]
              withRowAnimation:UITableViewRowAnimationFade];
    
    if (isPrevDeleted) {
        // previous article deleted
        if (prevArticleCount == _prevItemCount) {
            int section = newArticleCount ? 1 : 0;
            [tv insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevArticleCount-1 inSection:section]]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (prevArticleCount == 1) {
            [tv deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]]
              withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if (newArticleCount == 1) {
        // the only new article was deleted
        [tv deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]]
          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [tv endUpdates];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Article *article = [self articleAtIndexPath:indexPath];
    
    if (article == nil) {
        _prevItemCount += 30;
        [self loadArticles];
        [self.tableView reloadData];
    } else {
        CArticle *cArticle = [[CArticle alloc] initWithNibName:@"CArticle" bundle:nil];
        NSArray *allArticles = [_newArticles arrayByAddingObjectsFromArray:_prevArticles];
        [cArticle setArticles:allArticles index:[allArticles indexOfObject:article]];
        [self.navigationController pushViewController:cArticle animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Article *article = [self articleAtIndexPath:indexPath];
	return [ArticleCell heightForArticle:article];
}

#pragma mark - stuff

- (void)updateCellForArticle:(NSManagedObjectID *)articleId
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        Article *article = [self articleAtIndexPath:indexPath];
        if ([article.objectID isEqual:articleId]) {
            ArticleCell *cell = _cellMap[articleId];
            [cell setAssetLoaded];
            return;
        }
    }
}

#pragma mark - DownloadListener

- (void)downloadQueuedForArticleId:(NSManagedObjectID *)articleId
{
}

- (void)downloadStartedForArticleId:(NSManagedObjectID *)articleId
{
}

- (void)downloadReachedCompletionRatio:(float)completionRatio
                         forArticleId:(NSManagedObjectID *)articleId
{
}

- (void)downloadCompletedForArticleId:(NSManagedObjectID *)articleId
{
}

- (void)assetLoaded:(AVAsset *)asset
      forArticleId:(NSManagedObjectID *)articleId
             feedId:(NSManagedObjectID *)fid
{
    [self performSelectorOnMainThread:@selector(updateCellForArticle:) withObject:articleId waitUntilDone:NO];
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

- (void)viewDidUnload
{
    [self setFfButton:nil];
    [super viewDidUnload];
}

@end

