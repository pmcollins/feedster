//
//  CArticleDetail.h
//  XReader
//
//  Created by Pablo Collins on 12/12/10.
//  Copyright 2010 trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface CArticleDetail : UIViewController {
	UITextView *textView;
	UILabel *label;
	UITextField *textField;
	Article *_article;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UITextField *textField;

- (void)setArticle:(Article *)article;

@end
