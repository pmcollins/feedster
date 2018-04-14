//
//  FeedDownloader.m
//  XReader
//
//  Created by Pablo Collins on 2/9/13.
//

#import "FeedDownloader.h"
#import "Feed.h"
#import "FeedReader.h"

@interface FeedDownloader () {
    Feed *_feed;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSURLResponse *_response;
    NSURL *_url, *_finalURL;
    UpdateQueue *_updateQueue;
} @end

@implementation FeedDownloader

- (id)initWithFeed:(Feed *)feed url:(NSURL *)url updateQueue:(UpdateQueue *)q
{
    self = [super init];

    _feed = feed;
    _url = url;
    _updateQueue = q;
    
    return self;
}

- (void)start
{
    assert([NSThread isMainThread]);

    [_updateQueue.delegate feedDidStartUpdating:_feed.objectID];
    
    _data = [[NSMutableData alloc] init];
    NSURLRequest *req = [NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:8];
    _connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

#pragma mark - NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    _finalURL = request.URL;
    return request;
}

- (NSURL *)finalURL
{
    return _finalURL;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)res
{
    _response = res;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    [_data appendData:d];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    FeedReader *op = [[FeedReader alloc] initWithFeedId:_feed.objectID
                                            updateQueue:_updateQueue
                                                   data:_data];
    [op setThreadPriority:0];
    [[[UpdateQueue sharedInstance] q] addOperation:op];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [[UpdateQueue sharedInstance] finishedUpdating:_feed.objectID
                                         withError:error];
}

@end
