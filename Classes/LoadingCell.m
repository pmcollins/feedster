//
//  LoadingCell.m
//  XReader
//
//  Created by Pablo Collins on 12/8/12.
//  Copyright (c) 2012 Trickbot. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell

- (id)init
{
    self = [super init];

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.frame = CGRectMake(120, 0, 60, 60);
    [self addSubview:_activityIndicator];

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
