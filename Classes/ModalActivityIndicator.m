//
//  ModalActivityIndicator.m
//  XReader
//
//  Created by Pablo Collins on 4/9/11.
//

#import "ModalActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

@implementation ModalActivityIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.layer.cornerRadius = 10.0;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(30, 30, 40, 40)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activityIndicator startAnimating];
    [self addSubview:activityIndicator];
    return self;
}

@end
