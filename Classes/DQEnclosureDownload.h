//
//  EnclosureDownload.h
//  XReader
//
//  Created by Pablo Collins on 2/6/11.
//

#import "Article.h"
#import "DownloadListener.h"

@class DownloadQueue;

@interface DQEnclosureDownload : NSObject

@property (strong, readonly) NSManagedObjectID * articleId;
@property (strong, readonly) NSString * mimeType;

- (id)initWithArticleId:(NSManagedObjectID *)fiId allowCellular:(BOOL)allowCellular;
- (void)setDownloadQueue:(DownloadQueue *)q;
- (void)start;
- (float)completionRatio;

@end
