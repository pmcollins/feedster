//
//  Player.m
//  XReader
//
//  Created by Pablo Collins on 2/17/11.
//

#import "Player.h"
#import "M.h"
#import "Feed+Logic.h"

@interface Player()
{
    AVPlayerItem *_playerItem;
    AVPlayer *_avPlayer;
    AVAudioSession *_audioSession;
    id _timeObserver;
    NSNumber *_startTime;
    NSManagedObjectID *_currentArticleId;
    NSMutableSet *_playerDelegateSet;
    float _duration, _elapsed, _progress;
    NSString *_articleTitle, *_feedTitle;
    NSArray *_images;
    BOOL _interrupted;
}
@end

@implementation Player

static Player *me;

+ (Player *)sharedInstance
{
    if (me == nil) {
        me = [[Player alloc] init];
    }
    return me;
}

- (id)init
{
    self = [super init];
    _playerDelegateSet = [[NSMutableSet alloc] initWithCapacity:4];
    _interrupted = NO;
    return self;
}

- (void)addPlayerDelegate:(id<PlayerDelegate>)delegate
{
    [delegate updateTimeElapsed:_elapsed progress:_progress];
    [_playerDelegateSet addObject:delegate];
}

- (void)removePlayerDelegate:(id<PlayerDelegate>)delegate
{
    [_playerDelegateSet removeObject:delegate];
}

- (BOOL)hasMedia
{
    return _currentArticleId != nil;
}

- (void)clear
{
    assert(![self isPlaying]);
    _currentArticleId = nil;
    _playerItem = nil;
    _avPlayer = nil;
    _audioSession = nil;
    _timeObserver = nil;
    _startTime = nil;
    _currentArticleId = nil;
    _playerDelegateSet = nil;
    _duration = _elapsed = _progress = 0;
    _articleTitle = _feedTitle = nil;
    _images = nil;
}

- (void)playMediaForArticle:(Article *)newArticle
{
    if (_currentArticleId) {
        if ([_currentArticleId isEqual:newArticle.objectID]) {
            [_avPlayer play];
            [self playerStarted];
            return;
        } else {
            //[self savePlayedLength];
        }
    }
    
    if ([self isPlaying]) {
        [self pause];
    }
    
    _startTime = newArticle.playedLength;
    
    _currentArticleId = newArticle.objectID;
    _duration = [newArticle.mediaLength floatValue];
    _articleTitle = newArticle.title;
    NSString *ft = newArticle.feed.title;
    _feedTitle = ft;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[newArticle fileURL]
                                                options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @NO}];
    static const NSString *ItemStatusContext;
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks", @"commonMetadata"]
                         completionHandler:^{
                             NSError *e;
                             NSInteger status = [asset statusOfValueForKey:@"tracks" error:&e];
                             if (status != AVKeyValueStatusLoaded) return;
                             CMTime duration2;
                             float durationSeconds;
                             Player *player = [Player sharedInstance];
                             duration2 = asset.duration;
                             durationSeconds = duration2.value/(float)duration2.timescale;
                             _playerItem = [AVPlayerItem playerItemWithAsset:asset];
                             [_playerItem addObserver:self
                                           forKeyPath:@"status"
                                              options:0
                                              context:&ItemStatusContext];
                             _avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
                             
                             _timeObserver = [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(5, 10)
                                                                                     queue:NULL
                                                                                usingBlock:^(CMTime t) {
                                                                                    float elapsed = t.value / (float)t.timescale;
                                                                                    [player updateTimeElapsed:elapsed progress:elapsed/durationSeconds];
                                                                                    [newArticle performSelectorOnMainThread:@selector(setPlayedLength:)
                                                                                                                  withObject:@(elapsed)
                                                                                                               waitUntilDone:NO];
                                                                                }];

                             NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                                withKey:AVMetadataCommonKeyArtwork
                                                                               keySpace:AVMetadataKeySpaceCommon];
                             
                             NSMutableArray *artworkImages = [NSMutableArray array];
                             for (AVMetadataItem *i in artworks)
                             {
                                 NSString *keySpace = i.keySpace;
                                 UIImage *im = nil;
                                 
                                 if ([keySpace isEqualToString:AVMetadataKeySpaceID3])
                                 {
                                     NSDictionary *d = [i.value copyWithZone:nil];
                                     im = [UIImage imageWithData:d[@"data"]];
                                 }
                                 else if ([keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                                     im = [UIImage imageWithData:[i.value copyWithZone:nil]];
                                 
                                 if (im)
                                     [artworkImages addObject:im];
                             }
                             
                             [player setImages:artworkImages];
                             
                             [self playerStarted];
                         }];
}

- (void)setImages:(NSArray *)a
{
    _images = a;
}

- (NSArray *)getImages
{
    return _images;
}

- (float)duration
{
    return _duration;
}

- (NSString *)feedTitle
{
    return _feedTitle;
}

- (NSString *)articleTitle
{
    return _articleTitle;
}

- (void)updateTimeElapsed:(float)elapsed progress:(float)progress
{
    _elapsed = elapsed;
    _progress = progress;
    for (id<PlayerDelegate> d in _playerDelegateSet) {
        [d updateTimeElapsed:elapsed progress:progress];
    }
}

- (void)ffwd:(NSInteger)n
{
    [_avPlayer seekToTime:CMTimeAdd(_avPlayer.currentTime, CMTimeMake(n, 1))];
}

- (void)rwd:(NSInteger)n
{
    [_avPlayer seekToTime:CMTimeSubtract(_avPlayer.currentTime, CMTimeMake(n, 1))];
}

//playeritem status
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (_startTime) {
        [_playerItem seekToTime:CMTimeMake([_startTime intValue], 1)];
        _startTime = nil;
    }
    _audioSession = [AVAudioSession sharedInstance];
    _audioSession.delegate = self;
    [_audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_audioSession setActive:YES error:nil];
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, (__bridge void *)(self));
    [_avPlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidPlayToEndTime)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
}

- (void)playerDidPlayToEndTime
{
    //NSLog(@"playerDidPlayToEndTime");
    //[self savePlayedLength];
    [self playerStopped];
}

- (float)currentTime
{
    if (_avPlayer) {
        CMTime t = [_avPlayer currentTime];
        return t.value/(float)t.timescale;
    } else {
        return 0.0;
    }
}

- (BOOL)isPlaying
{
    //NSLog(@"avPlayer.rate: %f", avPlayer.rate);
    return _avPlayer.rate > 0;
}

- (void)seekToTime:(float)time
{
    [_avPlayer seekToTime:CMTimeMakeWithSeconds(time, 1)];
}

//- (void)savePlayedLength
//{
//    currentArticle.playedLength = [NSNumber numberWithFloat:[self currentTime]];
//    [[M sharedInstance] save];
//}

- (NSManagedObjectID *)articleIdPlaying
{
    return [self isPlaying] ? _currentArticleId : nil;
}

- (void)pause
{
    //[self savePlayedLength];
    [_avPlayer pause];
}

- (void)resume
{
    [_avPlayer play];
}

- (void)dealloc
{
    [_avPlayer removeTimeObserver:_timeObserver]; //slavish adherence to documentation
}

- (void)togglePlayedState
{
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self resume];
    }
}

#pragma mark - AVAudioSessionDelegate

- (void)playerStopped
{
    for (id<PlayerDelegate> d in _playerDelegateSet) {
        [d playerStopped];
    }
}

- (void)playerStarted
{
    for (id<PlayerDelegate> d in _playerDelegateSet) {
        [d playerStartedForArticleId:_currentArticleId];
    }
}

#pragma mark - AVAudioSessionDelegate

- (void)beginInterruption
{
    if ([self isPlaying]) {
        _interrupted = YES;
        [self playerStopped];
    }
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
//    NSLog(@"endInterruptionWithFlags: %d", flags);
    if (_interrupted) {
        _interrupted = NO;
        [self playerStarted];
        [self resume];
    }
}

- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
}

- (void)applicationDidBecomeActive
{
    for (id<PlayerDelegate> d in _playerDelegateSet) {
        [d applicationDidBecomeActive];
    }
}

//called when headphones unplugged
void audioRouteChangeListenerCallback(void *inUserData, AudioSessionPropertyID inPropertyID,
                                      UInt32 inPropertyValueSize, const void *inPropertyValue)
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    Player *self = (__bridge Player *)inUserData;
    
    CFDictionaryRef routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary,
                                                            CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        [self beginInterruption];
    }
}

@end
