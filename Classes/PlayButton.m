//
//  PlayButton.m
//  XReader
//
//  Created by Pablo Collins on 5/12/12.
//

#import "PlayButton.h"

@implementation PlayButton

- (id)initWithFontSize:(CGFloat)size frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:size];
        [self setTitle:@"▸" forState:UIControlStateNormal];
    }
    return self;
}

@end
