//
//  CSubscriptionTable.h
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateQueueListener.h"
#import "FeedCell.h"
#import "Folder.h"
#import "PodcastStatusFetcher.h"
#import "DownloadListener.h"
#import "AbstractAdViewController.h"

@interface CFeedList : AbstractAdViewController <UITableViewDelegate, UITableViewDataSource, UpdateQueueListener, PodcastStatusDelegate, UIScrollViewDelegate, DownloadListener>

@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet FeedCell *tmpCell;
@property (weak, nonatomic) IBOutlet UILabel *updatingFeedLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updatingFeedSpinner;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *ffButton;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)fetchAllFeeds:(id)sender;
- (void)addFeed:(id)sender;
- (FeedCell *)visibleCellForFeedId:(NSManagedObjectID *)fid;
- (void)reloadRowForFeed:(Feed *)f;
- (IBAction)fastForward:(id)sender;
- (void)setLastFeedSeen:(Feed *)feed;
- (void)scrollToFeed:(Feed *)f;
- (void)updatePodcastStatusForFeedId:(NSManagedObjectID *)fid;
- (void)resetPodcastStatusFetcherMap;

@end
