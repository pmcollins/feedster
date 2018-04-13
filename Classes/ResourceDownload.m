//
//  ResourceDownload.m
//  XReader
//
//  Created by Pablo Collins on 3/20/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "ResourceDownload.h"

@interface ResourceDownload () {
    NSURLConnection *_connection;
    NSMutableData *_data;
    id<ResourceDownloadDelegate> _delegate;
    NSURLResponse *_response;
    NSURL *_url, *_finalURL;
} @end

@implementation ResourceDownload

- (id)initWithUrl:(NSURL *)u delegate:(id<ResourceDownloadDelegate>)fe
{
    self = [super init];
    _delegate = fe;
    _url = u;
    return self;
}

- (void)run
{
    _data = [[NSMutableData alloc] init];
    NSURLRequest *req = [NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:8];
    _connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
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
    [_delegate resourceDownloadFinished:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_delegate download:self failedWithError:error];
}

- (NSString *)asString
{
    NSString *out;
    if ((out = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding])) {
        return out;
    }
    if ((out = [[NSString alloc] initWithData:_data encoding:NSASCIIStringEncoding])) {
        return out;
    }
    return nil;
}


@end
