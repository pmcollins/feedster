//
//  PauseButton.m
//  XReader
//
//  Created by Pablo Collins on 5/25/12.
//

#import "PauseButton.h"

@implementation PauseButton

- (id)initWithFontSize:(CGFloat)size frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:size];
        [self setTitle:@"■" forState:UIControlStateNormal];
    }
    return self;
}

@end
