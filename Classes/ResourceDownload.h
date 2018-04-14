//
//  DocumentDownload.h
//  XReader
//
//  Created by Pablo Collins on 3/20/11.
//

#import <Foundation/Foundation.h>

@class ResourceDownload;

@protocol ResourceDownloadDelegate <NSObject>
- (void)resourceDownloadFinished:(ResourceDownload *)d;
- (void)download:(ResourceDownload *)d failedWithError:(NSError *)error;
@end

@interface ResourceDownload : NSObject <NSURLConnectionDelegate>

- (id)initWithUrl:(NSURL *)u delegate:(id<ResourceDownloadDelegate>)fe;
- (NSString *)asString;
- (void)run;
- (NSURL *)finalURL;

@end
