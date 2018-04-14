//
//  SummaryPopover.h
//  XReader
//
//  Created by Pablo Collins on 11/17/12.
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"
#import "Popover.h"

@interface SummaryPopover : Popover <UIWebViewDelegate>

@property GradientButton * downloadPlayButton;
@property UILabel * titleLabel;
@property UILabel * pctDownloadedLabel;
@property UIWebView * popupWebView;
@property UIProgressView * downloadProgress;

- (void)resizeForLandscapeMini;
- (void)resizeForPortraitMini;
- (void)showCloseButton;
- (void)resizeForLandscape;
- (void)resizeForPortrait;

@end
