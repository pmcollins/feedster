//
//  ArticleTableView.m
//  XReader
//
//  Created by Pablo Collins on 1/16/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "ArticleTitleView.h"
#import "QuartzCore/QuartzCore.h"

@interface ArticleTitleView() {
    UILabel *badge;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation ArticleTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -1, 154, 20)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = UITextAlignmentLeft;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.shadowColor = [UIColor darkGrayColor];
    _titleLabel.shadowOffset = CGSizeMake(0, -1);
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:_titleLabel];

    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 154, 14)];
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.textAlignment = UITextAlignmentLeft;
    _subtitleLabel.textColor = [UIColor whiteColor];
    _subtitleLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:_subtitleLabel];

    self.faviconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [_faviconView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_faviconView.layer setBorderWidth:1];
    _faviconView.alpha = 1.0;
    [self addSubview:_faviconView];

    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    activityIndicator.hidden = YES;
    activityIndicator.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [self addSubview:activityIndicator];
    
    [self addSubview:badge];
    
    return self;
}

- (void)startAnimating
{
    _faviconView.hidden = YES;
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
}

- (void)stopAnimating
{
    _faviconView.hidden = NO;
    activityIndicator.hidden = YES;
    [activityIndicator stopAnimating];
}

@end
