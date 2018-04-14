//
//  EnclosureDownload.m
//  XReader
//
//  Created by Pablo Collins on 2/6/11.
//

#import "DQEnclosureDownload.h"
#import "DownloadQueue.h"
#import "Article+Logic.h"
#import "Feed+Logic.h"
#import "M.h"

@interface DQEnclosureDownload() {
    DownloadQueue *_queue;
    NSURLConnection *_conn;
    NSFileHandle *_fh;
    Article *_article;
    long long _contentLength;
    long long _bytesReceived;
    NSManagedObjectContext *_ctx;
    float _completionRatio;
}
@end

@implementation DQEnclosureDownload

- (id)initWithArticleId:(NSManagedObjectID *)fiId allowCellular:(BOOL)allowCellular
{
    self = [super init];
    _articleId = fiId;
    _ctx = [[M sharedInstance] newManagedObjectContext];
    _bytesReceived = 0;
    _article = (Article *)[_ctx objectWithID:fiId];
    _completionRatio = 0;
    
    [self deleteExtraneousFiles];
    [[M sharedInstance] saveContext:_ctx];
    
    NSString *urlString = _article.mediaUrl;

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:8];
    [req setAllowsCellularAccess:allowCellular];
    
    _conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    NSString *fname = [_article mediaFname];
    _fh = [NSFileHandle fileHandleForWritingAtPath:fname];
    if (_fh == nil) {
        [[NSFileManager defaultManager] createFileAtPath:fname contents:nil attributes:nil];
        _fh = [NSFileHandle fileHandleForWritingAtPath:fname];
    }
    return self;
}

- (void)deleteExtraneousFiles
{
    Feed *feed = _article.feed;
    [feed deleteExpiredDownloads];
}

- (void)start
{
    [_conn start];
}

- (void)setDownloadQueue:(DownloadQueue *)q
{
    _queue = q;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _contentLength = [response expectedContentLength];
//    NSLog(@"response.MIMEType: %@", response.MIMEType);
    _mimeType = response.MIMEType;
    [_queue downloadStartedForArticleId:_articleId];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_fh writeData:data];
    _bytesReceived += [data length];
    _completionRatio = (float)_bytesReceived / (float)_contentLength;
    [_queue downloadReachedCompletionRatio:_completionRatio forArticleId:_articleId];
}

- (float)completionRatio
{
    return _completionRatio;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_fh synchronizeFile];
    [_fh closeFile];
    [_queue downloadCompletedForArticleId:_articleId];
    [_queue downloadFinished:self error:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_fh closeFile];
    [_queue downloadFinished:self error:error];
}

@end
