//
//  ArticleTableView.h
//  XReader
//
//  Created by Pablo Collins on 1/16/11.
//

#import <UIKit/UIKit.h>

@interface ArticleTitleView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *faviconView;

- (void)startAnimating;
- (void)stopAnimating;

@end
