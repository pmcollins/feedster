//
//  ArticleCell.h
//  XReader
//
//  Created by Pablo Collins on 2/20/11.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "PodcastStatusIconView.h"

@interface ArticleCell : UITableViewCell {
    UILabel *_titleLabel;
    PodcastStatusIconView *_podcastStatusIconView;
    CGFloat _height;
}

@property (nonatomic, strong) UILabel *dateLabel;

+ (CGFloat)heightForArticle:(Article *)article;

- (void)setIsUnread:(BOOL)unread;
- (void)setArticle:(Article *)article;
- (void)setAssetLoaded;

@end
