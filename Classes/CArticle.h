//
//  CArticle.h
//  XReader
//
//  Created by Pablo Collins on 11/21/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "Player.h"
#import "DownloadQueue.h"

@interface CArticle : UIViewController <UIWebViewDelegate, DownloadListener>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previewButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

- (void)setArticles:(NSArray *)articles index:(NSUInteger)index;

@end
