//
//  SummaryPopover.m
//  XReader
//
//  Created by Pablo Collins on 11/17/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import "SummaryPopover.h"

#define kPopoverMargin 190
#define kPopoverOffset 84

@interface SummaryPopover ()
@end

@implementation SummaryPopover

- (id)init
{
    float screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;

    self = [super init];
    [self resizeForPortrait];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 200, 44)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:_titleLabel];
    
    _downloadPlayButton = [[GradientButton alloc] initWithFrame:CGRectMake(232, 8, 60, 40)];
    _downloadPlayButton.enabled = NO;
    _downloadPlayButton.hidden = YES;
    [self addSubview:_downloadPlayButton];
    
    _pctDownloadedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, 50, 20)];
    _pctDownloadedLabel.font = [UIFont systemFontOfSize:14];
    _pctDownloadedLabel.textColor = [UIColor whiteColor];
    _pctDownloadedLabel.text = @"0%";
    _pctDownloadedLabel.hidden = YES;
    _pctDownloadedLabel.backgroundColor = [UIColor clearColor];
    _pctDownloadedLabel.textAlignment = NSTextAlignmentCenter;
    [_downloadPlayButton addSubview:_pctDownloadedLabel];
    
    _downloadProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(5, 26, 50, 10)];
    _downloadProgress.progressViewStyle = UIProgressViewStyleBar;
    
    [_downloadPlayButton addSubview:_downloadProgress];
    
    _popupWebView = [[UIWebView alloc] initWithFrame:CGRectMake(8, 56, 284, screenHeight - kPopoverMargin - 76)];
    _popupWebView.layer.cornerRadius = 8;
    _popupWebView.clipsToBounds = YES;
    _popupWebView.delegate = self;
    
    [self addSubview:_popupWebView];
    
    return self;
}

- (void)resizeForLandscapeMini
{
    [self setFrame:CGRectMake(10, [[UIScreen mainScreen] applicationFrame].size.height - 176, 300, 80)];
    _popupWebView.hidden = YES;
}

- (void)resizeForPortraitMini
{
    [self setFrame:CGRectMake(10, [[UIScreen mainScreen] applicationFrame].size.height - 170, 300, 80)];
    _popupWebView.hidden = YES;
}

- (void)resizeForLandscape
{
    [self setFrame:CGRectMake(10, [[UIScreen mainScreen] applicationFrame].size.width - 150, 300, 80)];
    _popupWebView.hidden = YES;
}

- (void)resizeForPortrait
{
    [self setFrame:CGRectMake(10, kPopoverMargin - kPopoverOffset, 300, [[UIScreen mainScreen] applicationFrame].size.height - kPopoverMargin)];
    _popupWebView.hidden = NO;
}

- (void)showCloseButton
{
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

@end
