//
//  Article+Logic.m
//  XReader
//
//  Created by Pablo Collins on 12/31/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import "Article+Logic.h"
#import "M.h"
#import "PodcastStatusFetcher.h"
#import "Player.h"
#import "Feed+Logic.h"

@implementation Article (Article_Logic)

+ (NSString *)fmtSecs:(int)s
{
    int minutes = s / 60;
    int secs = s % 60;
    NSString *out = [NSString stringWithFormat:@"%d:%.2d", minutes, secs];
    return out;
}

+ (NSString *)extension:(NSString *)s
{
    NSArray *a = [s componentsSeparatedByString:@"."];
    NSString *ext = [a lastObject];
    return ext;
}

+ (NSArray *)itemsWithEnclosuresEligibleForAutoDownload
{
    NSMutableArray *out = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *feeds = [Feed feedsOrderedByUpdateTime];
    
    for (Feed *f in feeds) {
        NSArray *articles = [f recentPodcastsNeedingDownload];
        if (articles.count) {
            [out addObjectsFromArray:articles];
        }
    }
    
    return out;
}

- (BOOL)guidExists:(NSManagedObjectContext *)ctx
{
    NSEntityDescription *d = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:d];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"guid == %@", self.guid];
    //poor performance, not using the index?
    //NSPredicate *p = [NSPredicate predicateWithFormat:@"guid == %@ AND feed == %@", self.guid, self.feed];
    [req setPredicate:p];
	NSError *e;
    NSUInteger out = [ctx countForFetchRequest:req error:&e];
	return out > 1;
}

- (void)setMediaLengthStr:(NSString *)str
{
	self.mediaLength = [[[NSNumberFormatter alloc] init] numberFromString:str];
}

- (NSString *)mediaFname
{
    if (self.mediaUrl == nil) return nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSManagedObjectID *id = [self objectID];
    NSURL *u = [NSURL URLWithString:self.mediaUrl];
    NSString *ext = [[self class] extension:[u lastPathComponent]];
    return [NSString stringWithFormat:@"%@/%@.%@", documentsDirectory, [[id URIRepresentation] lastPathComponent], ext];
}

- (NSURL *)fileURL
{
    return [NSURL fileURLWithPath:[self mediaFname]];
}

- (float)podcastStatus
{
    float f = NO_PODCAST;
    if (self.mediaUrl && [self hasPlayableMediaType]) {
        if ([self.downloaded boolValue]) {
            if ([[[Player sharedInstance] articleIdPlaying] isEqual:self.objectID]) {
                f = PODCAST_IS_PLAYING;
            } else {
                f = [self.playedLength floatValue] / [self.mediaLength floatValue];
            }
        } else {
            f = PODCAST_NOT_DOWNLOADED;
        }
    }
    return f;
}

- (BOOL)hasMediaFile
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self mediaFname]];
}

- (void)deleteMediaFile
{
    NSString *path = [self mediaFname];
    if (path != nil) {
        //NSLog(@"deleteMediaFile: %@", path);
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (void)prepareForDeletion
{
    [self deleteMediaFile];
}

- (BOOL)hasPlayableMediaType
{
    return [self.mediaType isEqualToString:@"audio/mpeg"];
}

@end
