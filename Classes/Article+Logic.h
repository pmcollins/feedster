//
//  Article+Logic.h
//  XReader
//
//  Created by Pablo Collins on 12/31/10.
//

#import "Article.h"

#define NO_PODCAST -2.0
#define PODCAST_NOT_DOWNLOADED -1.0
#define PODCAST_IS_PLAYING -3.0

@interface Article (Article_Logic)

+ (NSArray *)itemsWithEnclosuresEligibleForAutoDownload;
+ (NSString *)fmtSecs:(int)s;
- (BOOL)guidExists:(NSManagedObjectContext *)ctx;
- (void)setMediaLengthStr:(NSString *)str;
- (NSString *)mediaFname;
- (NSURL *)fileURL;
- (void)deleteMediaFile;
- (float)podcastStatus;
- (BOOL)hasMediaFile;
- (BOOL)hasPlayableMediaType;

@end
