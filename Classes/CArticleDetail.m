//
//  CArticleDetail.m
//  XReader
//
//  Created by Pablo Collins on 12/12/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import "CArticleDetail.h"

@implementation CArticleDetail

@synthesize textView, label, textField;

#pragma mark -
#pragma mark My Stuff

- (void)setArticle:(Article *)article {
	_article = article;
}

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	textField.text = label.text = textView.text = _article.guid;
}

@end
