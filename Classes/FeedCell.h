//
//  FeedCell.h
//  XReader
//
//  Created by Pablo Collins on 12/10/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "PodcastStatusIconView.h"

@interface FeedCell : UITableViewCell {
    Feed *feed;
    UIActivityIndicatorView *activityIndicator;
    UILabel *feedName, *unreadCount, *lastUpdated;
    UIImageView *favicon;
    NSArray *statusImages;
}

@property (nonatomic, strong) Feed *feed;
@property (nonatomic, strong) IBOutlet UILabel *feedName, *unreadCount, *lastUpdated;
@property (nonatomic, strong) IBOutlet UIImageView *favicon, *pendingImg;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *queuedImg;

@property (strong, nonatomic) IBOutlet PodcastStatusIconView *statusImg1;
@property (strong, nonatomic) IBOutlet PodcastStatusIconView *statusImg2;
@property (strong, nonatomic) IBOutlet PodcastStatusIconView *statusImg3;
@property (strong, nonatomic) IBOutlet PodcastStatusIconView *statusImg4;
@property (strong, nonatomic) IBOutlet PodcastStatusIconView *statusImg5;

- (void)setPodcastStatus:(NSArray *)podcastStatus;
- (void)setRefreshPeriod:(NSUInteger)refreshPeriod;
- (void)startAnimating;
- (void)stopAnimating;
- (void)render;
- (void)setup;
- (void)showQueued;

@end
