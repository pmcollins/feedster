//
//  Player.h
//  XReader
//
//  Created by Pablo Collins on 2/17/11.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import "PlayerDelegate.h"
#import "Article.h"
#import "Article+Logic.h"

@interface Player : NSObject<AVAudioSessionDelegate>

+ (Player *)sharedInstance;

- (void)playMediaForArticle:(Article *)article;
- (void)pause;
- (void)resume;
- (float)currentTime;
- (void)addPlayerDelegate:(id<PlayerDelegate>)delegate;
- (void)removePlayerDelegate:(id<PlayerDelegate>)delegate;
//- (void)savePlayedLength;
- (BOOL)isPlaying;
- (NSManagedObjectID *)articleIdPlaying;
- (void)updateTimeElapsed:(float)elapsed progress:(float)progress;
- (void)seekToTime:(float)time;
- (float)duration;
- (void)togglePlayedState;
- (NSString *)articleTitle;
- (NSArray *)getImages;
- (void)ffwd:(NSInteger)n;
- (void)rwd:(NSInteger)n;
- (NSString *)feedTitle;
- (void)applicationDidBecomeActive;
- (BOOL)hasMedia;
- (void)clear;

void audioRouteChangeListenerCallback(void *inUserData,
                                      AudioSessionPropertyID inPropertyID,
                                      UInt32 inPropertyValueSize,
                                      const void *inPropertyValue);

@end

