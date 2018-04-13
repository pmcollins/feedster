//
//  PlayedStatusView.m
//  XReader
//
//  Created by Pablo Collins on 1/12/13.
//  Copyright (c) 2013 Trickbot. All rights reserved.
//

#import "PodcastStatusIconView.h"
#import "Article+Logic.h"

@interface PodcastStatusIconView () {
    UIImageView *_playableOutline, *_playableFilling, *_download, *_playing;
} @end

@implementation PodcastStatusIconView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    [self setFrame:frame];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void)setup
{
    _playableOutline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle-play-outline"]];
    _playableOutline.contentMode = UIViewContentModeScaleAspectFit;
    _playableOutline.hidden = YES;
    [self addSubview:_playableOutline];
    
    _playableFilling = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle-play"]];
    _playableFilling.contentMode = UIViewContentModeScaleAspectFit;
    _playableFilling.hidden = YES;
    [self addSubview:_playableFilling];
    
    _download = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download"]];
    _download.contentMode = UIViewContentModeScaleAspectFit;
    _download.hidden = YES;
    [self addSubview:_download];
    
    _playing = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speaker"]];
    _playing.contentMode = UIViewContentModeScaleAspectFit;
    _playing.hidden = YES;
    [self addSubview:_playing];
    
    CGRect subFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _playableOutline.frame = subFrame;
    _playableFilling.frame = subFrame;
    _download.frame = subFrame;
    _playing.frame = subFrame;
}

- (void)setStatus:(float)f
{
    if (f == NO_PODCAST) {
        self.hidden = YES;
    } else if (f == PODCAST_NOT_DOWNLOADED) {
        //38x48
        [self showDownloadable];
    } else if (f == PODCAST_IS_PLAYING) {
        [self showPlaying];
    } else if (f >= 0.0) {
        [self showPlayable:f];
    }
}

- (void)showPlaying
{
    self.hidden = NO;
    
    _playableFilling.hidden = YES;
    _playableOutline.hidden = YES;
    _download.hidden = YES;
    _playing.hidden = NO;
}

- (void)showPlayable:(float)f
{
    self.hidden = NO;

    _download.hidden = YES;
    _playing.hidden = YES;

    _playableFilling.hidden = NO;
    _playableOutline.hidden = NO;
    
    _playableFilling.alpha = 1.0 - f;
    _playableOutline.alpha = 1.0 - (f / 2);
}

- (void)showDownloadable
{
    self.hidden = NO;
    
    _playableFilling.hidden = YES;
    _playableOutline.hidden = YES;
    _download.hidden = NO;
    _playing.hidden = YES;
}

@end
