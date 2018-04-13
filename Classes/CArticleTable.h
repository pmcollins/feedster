//
//  CArticleTable.h
//  XReader
//
//  Created by Pablo Collins on 11/18/10.
//  Copyright 2010 Trickbot. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ArticleCell.h"
#import "Feed.h"
#import "UpdateQueueListener.h"
#import "CFeedList.h"
#import "ArticleTitleView.h"
#import "Player.h"
#import "DownloadListener.h"
#import "AbstractAdViewController.h"

@interface CArticleTable : AbstractAdViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UpdateQueueListener, UINavigationBarDelegate, UITextFieldDelegate, DownloadListener>

@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ffButton;

- (void)setFeed:(Feed *)f;
- (void)loadArticles;
- (IBAction)showMarkAsReadDialog;
- (IBAction)trash;
- (void)setCFeedList:(CFeedList *)f;
- (IBAction)showSettings;
- (IBAction)fastForward:(id)sender;

@end
