//
//  FFBadge.m
//  XReader
//
//  Created by Pablo Collins on 9/23/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import "FFBadge.h"
#import "QuartzCore/QuartzCore.h"

@interface FFBadge () {
    UILabel *_label;
} @end

@implementation FFBadge

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 16, 16)];
        _label.layer.cornerRadius = 8.0;
        _label.font = [UIFont boldSystemFontOfSize:13.0];
        _label.adjustsFontSizeToFitWidth = NO;
        _label.textAlignment = UITextAlignmentCenter;
        _label.backgroundColor = [UIColor colorWithRed:0.4 green:0.1 blue:0.1 alpha:1.0];
        _label.textColor = [UIColor whiteColor];
        _label.opaque = YES;

        [self addSubview:_label];
        
        self.hidden = YES;
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.zPosition = 100;
        self.opaque = YES;
        
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.8;
    }
    return self;
}

- (void)hideFFCountBadge:(BOOL)hide
{
    self.hidden = hide;
}

- (void)setFFCount:(NSString *)ffCount
{
    NSUInteger len = ffCount.length;
    int width = 26;
    if (len == 1) {
        width = 18;
    } else if (len == 2) {
        width = 22;
    }
    _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, width, _label.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width + 4, self.frame.size.height);
    _label.text = ffCount;
}

@end
