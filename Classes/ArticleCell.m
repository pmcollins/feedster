//
//  ArticleCell.m
//  XReader
//
//  Created by Pablo Collins on 2/20/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "ArticleCell.h"
#import "Article+Logic.h"
#import "Player.h"
#import "FormatUtil.h"

#define FONT_SIZE                15.0f
#define DATE_FONT_SIZE           12.0f
#define DATE_CONTENT_HEIGHT      12.0f
#define CELL_CONTENT_WIDTH      300.0f
#define CELL_VERTICAL_PADDING     6.0f
#define CELL_LEFT_PADDING         8.0f
#define CELL_RIGHT_PADDING       10.0f
#define MEDIA_LABEL_WIDTH       100.0f
#define DATE_LABEL_WIDTH        200.0f
#define PROGRESS_VIEW_WIDTH     100.0f
#define PODCAST_IMAGE_SIZE       20
#define IMAGEVIEW_BUFFER         10

@interface ArticleCell () {
    NSCalendar *_gregorian;
    Article *_article;
} @end

@implementation ArticleCell

+ (NSUInteger)widthForArticle:(Article *)article
{
    BOOL hasMedia = article.mediaUrl && article.mediaUrl.length;
    return CELL_CONTENT_WIDTH - (CELL_LEFT_PADDING + CELL_RIGHT_PADDING) + (hasMedia ? -IMAGEVIEW_BUFFER : PODCAST_IMAGE_SIZE);
}

+ (CGSize)constraintForArticle:(Article *)article
{
    return CGSizeMake([ArticleCell widthForArticle:article], 20000.0f);
}

+ (CGFloat)heightForArticle:(Article *)article
{
    if (article == nil) {
        return 60;
    }
    NSString *title = article.title;
    CGSize constrant = [ArticleCell constraintForArticle:article];
    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constrant];
    return size.height + (CELL_VERTICAL_PADDING * 2) + DATE_CONTENT_HEIGHT;
}

- (UIColor *)dateColor
{
    return [UIColor colorWithRed:0 green:0.25 blue:0.5 alpha:1];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_titleLabel setLineBreakMode:UILineBreakModeWordWrap];
    [_titleLabel setMinimumFontSize:FONT_SIZE];
    [_titleLabel setNumberOfLines:0];
    [_titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    [self.contentView addSubview:_titleLabel];

    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(
        CELL_LEFT_PADDING,
        CELL_VERTICAL_PADDING,
        DATE_LABEL_WIDTH,
        DATE_CONTENT_HEIGHT
    )];
    [_dateLabel setFont:[UIFont boldSystemFontOfSize:DATE_FONT_SIZE]];
    [_dateLabel setTextColor:[self dateColor]];
    [self.contentView addSubview:_dateLabel];

    _podcastStatusIconView = [[PodcastStatusIconView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    _podcastStatusIconView.hidden = YES;
    _podcastStatusIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_podcastStatusIconView];
    
    return self;
}

- (void)arrangeTitleFrame
{
    CGSize constraint = [ArticleCell constraintForArticle:_article];
    CGSize size = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]
                               constrainedToSize:constraint
                                   lineBreakMode:UILineBreakModeWordWrap];
    [_titleLabel setFrame:CGRectMake(
        CELL_LEFT_PADDING,
        DATE_CONTENT_HEIGHT + CELL_VERTICAL_PADDING,
        [ArticleCell widthForArticle:_article],
        size.height
    )];
}

- (NSDate *)trunc:(NSDate *)d
{
    NSDate *out;
    [[self gregorian] rangeOfUnit:NSDayCalendarUnit startDate:&out interval:nil forDate:d];
    return out;
}

- (NSCalendar *)gregorian
{
    if (_gregorian == nil) {
        _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return _gregorian;
}

- (void)setDate:(NSDate *)date
{
    if (date == nil) {
        _dateLabel.text = @"";
    } else {
        NSDate *tDate = [self trunc:date];
        NSDate *tNow = [self trunc:[NSDate date]];
        NSDateComponents *cft = [[self gregorian] components:NSDayCalendarUnit fromDate:tDate toDate:tNow options:0];
        NSInteger d = [cft day];
        if (d < 0) {
            _dateLabel.text = @"Now";
        } else if (d == 0) {
            _dateLabel.text = [NSString stringWithFormat:@"%@", [[FormatUtil sharedInstance].cellFormatter stringFromDate:date]];
        } else if (d == 1) {
            _dateLabel.text = [NSString stringWithFormat:@"Yesterday %@", [[FormatUtil sharedInstance].cellFormatter stringFromDate:date]];
        } else {
            _dateLabel.text = [NSString stringWithFormat:@"%ld days ago %@", (long)d, [[FormatUtil sharedInstance].cellFormatter stringFromDate:date]];
        }
    }
}

- (void)setDuration:(float)d played:(float)p
{
//    progressView.hidden = NO;
//    progressView.progress = p/d;
//    mediaLabel.text = [NSString stringWithFormat:@"%@", [Article fmtSecs:d]];
}

- (void)setAssetLoaded
{
    [_podcastStatusIconView setStatus:0.0];
}

- (void)setIsUnread:(BOOL)unread
{
    _titleLabel.textColor = unread ? [UIColor blackColor] : [UIColor grayColor];
    _dateLabel.textColor = unread ? [self dateColor] : [UIColor grayColor];
}

- (void)setArticle:(Article *)article
{
    _article = article;
    [_podcastStatusIconView setStatus:[article podcastStatus]];
    
    if (_article == nil) {
        _titleLabel.text = @"Loading...";
        
        [self setDate:nil];
    } else {
        _titleLabel.text = _article.title;
        
        [self setDate:_article.pubDate];
        
        _height = [ArticleCell heightForArticle:_article];
        _podcastStatusIconView.frame = CGRectMake(288, (_height/2) - (PODCAST_IMAGE_SIZE/2.0), PODCAST_IMAGE_SIZE, PODCAST_IMAGE_SIZE);
        
        if ([_article.downloaded boolValue] && [_article hasPlayableMediaType]) {
            [self setDuration:[_article.mediaLength floatValue] played:[_article.playedLength floatValue]];
        }
    }
    [self arrangeTitleFrame];
}

@end
