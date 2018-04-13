//
//  CModalPlayer.m
//  XReader
//
//  Created by Pablo Collins on 9/26/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import "CModalPlayer.h"
#import "M.h"

@interface CModalPlayer () {
    Player *_player;
    float _durationSeconds;
} @end

@implementation CModalPlayer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[M sharedInstance] saveMainContext];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setPodcastImageView:nil];
    [self setSlider:nil];
    [self setCurrTimeLabel:nil];
    [self setTotalTimeLabel:nil];
    [self setPlayPauseBtn:nil];
    [self setControlPanel:nil];
    [self setNavBar:nil];
    [self setTitleLabel:nil];
    [self setRwdButton:nil];
    [self setFfwdBtn:nil];
    [self setRwdLabel:nil];
    [self setFfwdLabel:nil];
    [super viewDidUnload];
}

#pragma stuffs

- (void)setup
{
    _player = [Player sharedInstance];

    [_player addPlayerDelegate:self];
    
    if ([_player hasMedia]) {
        [self setDuration:[_player duration]];
        [self setNavbarTitle:[_player feedTitle]];
        _titleLabel.text = [_player articleTitle];
        
        if ([_player isPlaying]) {
            [self showPauseButton];
        } else {
            [self showPlayButton];
        }
    } else {
        _titleLabel.text = @"No media loaded. To play a podcast, touch its play button.";
        _slider.hidden = _currTimeLabel.hidden = _totalTimeLabel.hidden = _playPauseBtn.hidden = _rwdButton.hidden = _rwdLabel.hidden = _ffwdBtn.hidden = _ffwdLabel.hidden = YES;
    }
    [self showPodcastImage];
}

- (void)removeAsPlayerDelegate
{
    [_player removePlayerDelegate:self];
}

- (IBAction)rwdTouched
{
    [_player rwd:30];
}

- (IBAction)ffwdTouched
{
    [_player ffwd:30];
}

- (void)checkPlayerStateAndShowButton
{
    if ([_player isPlaying]) {
        [self showPauseButton];
    } else {
        [self showPlayButton];
    }
}

- (IBAction)buttonTouched:(id)sender
{
    if ([_player isPlaying]) {
        [_player pause];
        [self showPlayButton];
    } else {
        [_player resume];
        [self showPauseButton];
    }
}

- (void)setNavbarTitle:(NSString *)title
{
    self.navBar.topItem.title = title;
}

- (void)setDurationTime:(CMTime)t
{
    float f = t.value / (float)t.timescale;
    [self setDuration:f];
}

- (void)setDuration:(float)duration
{
    _durationSeconds = duration;
    self.totalTimeLabel.text = [Article fmtSecs:duration];
}

- (IBAction)sliderMoved
{
    float t = self.slider.value * _durationSeconds;
    //NSLog(@"sliderMoved: seekToTime: [%f]", t);
    [_player seekToTime:t];
}

- (IBAction)hide:(id)sender
{
    [self removeAsPlayerDelegate];
    [self.opener dismissModalViewControllerAnimated:YES];
}

- (void)showNoButton
{
    self.playPauseBtn.hidden = YES;
}

- (void)showCorrectSliders:(BOOL)downloaded
{
    self.slider.hidden = !downloaded;
}

- (void)showPlayButton
{
    [self.playPauseBtn setImage:[UIImage imageNamed:@"play-white.png"] forState:UIControlStateNormal];
    self.playPauseBtn.hidden = NO;
}

- (void)showPauseButton
{
    [self.playPauseBtn setImage:[UIImage imageNamed:@"pause-white.png"] forState:UIControlStateNormal];
    self.playPauseBtn.hidden = NO;
}

- (void)showPodcastImage
{
    NSArray *imgs = [_player getImages];
    if (imgs != nil && [imgs count]) {
        self.podcastImageView.image = imgs[0];
    } else {
        self.podcastImageView.image = [UIImage imageNamed:@"icon-full.png"];
    }
}

- (void)downloadStarted
{
    //NSLog(@"downloadStarted");
}

- (void)showPlayingStuff
{
    _slider.hidden = _currTimeLabel.hidden = _totalTimeLabel.hidden = _playPauseBtn.hidden = _rwdButton.hidden = _rwdLabel.hidden = _ffwdBtn.hidden = _ffwdLabel.hidden = NO;
    
    [self showPodcastImage];
    [self showPauseButton];
    
    [self setDuration:[_player duration]];
    [self setNavbarTitle:[_player feedTitle]];
    _titleLabel.text = [_player articleTitle];
}

#pragma mark - PlayerDelegate

- (void)updateTimeElapsed:(float)timeElapsed progress:(float)progress
{
    if (progress >= 0.0) {
        self.slider.value = progress;
        self.currTimeLabel.text = [Article fmtSecs:timeElapsed];
    }
}

- (void)playerStartedForArticleId:(NSManagedObjectID *)articleId
{
    [self performSelectorOnMainThread:@selector(showPlayingStuff) withObject:nil waitUntilDone:NO];
}

- (void)playerStopped
{
    [self showPlayButton];
}

- (void)applicationDidBecomeActive
{
    [self checkPlayerStateAndShowButton];
}

@end
