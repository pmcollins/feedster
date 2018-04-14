//
//  FeedCell.m
//  XReader
//
//  Created by Pablo Collins on 12/10/10.
//

#import "FeedCell.h"
#import "Feed+Logic.h"
#import "PodcastStatusFetcher.h"
#import <QuartzCore/QuartzCore.h>
#import "Article+Logic.h"

@implementation FeedCell
@synthesize statusImg1;
@synthesize statusImg2;
@synthesize statusImg3;
@synthesize statusImg4;
@synthesize statusImg5;

@synthesize feed, feedName, unreadCount, favicon, activityIndicator, lastUpdated;

- (void)setup
{
    statusImages = @[statusImg1, statusImg2, statusImg3, statusImg4, statusImg5];
}

- (void)showQueued
{
    favicon.hidden = YES;
    activityIndicator.hidden = YES;
    self.queuedImg.hidden = NO;
}

- (void)startAnimating
{
    favicon.hidden = YES;
    activityIndicator.hidden = NO;
    self.queuedImg.hidden = YES;
    [activityIndicator startAnimating];
}

- (void)stopAnimating
{
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
    favicon.hidden = NO;
}

- (void)setPodcastStatus:(NSArray *)podcastStatus
{
    for (int i = 0; i < 3; i++) {
        PodcastStatusIconView *icon = statusImages[i];
        if (podcastStatus == nil) {
            icon.hidden = YES;
        } else {
            NSNumber *n = i < [podcastStatus count] ? podcastStatus[i] : nil;
            float f = n == nil ? NO_PODCAST : [n floatValue];
            [icon setStatus:f];
        }
    }
}

- (void)setRefreshPeriod:(NSUInteger)refreshPeriod
{
    self.lastUpdated.text = refreshPeriod == 0 ? @"" : [NSString stringWithFormat:@"%lu min", (unsigned long)refreshPeriod];
}

- (void)render
{
    int new = [feed.newItemCount intValue];
    self.unreadCount.text = new ? [NSString stringWithFormat:@"%i", new] : nil;
    if (new == 0) {
        self.unreadCount.hidden = YES;
    } else {
        self.unreadCount.hidden = NO;
        self.unreadCount.text = [NSString stringWithFormat:@"%i", new];
    }
    self.feedName.text = feed.title;
    favicon.image = feed.faviconImage;
    
    self.activityIndicator.hidden = YES;
    self.queuedImg.hidden = YES;
    
//    favicon.layer.shadowOffset = CGSizeMake(1, 1);
//    favicon.layer.shadowRadius = 1;
//    favicon.layer.shadowOpacity = 0.8;
//    favicon.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.favicon.bounds].CGPath;
}

@end
