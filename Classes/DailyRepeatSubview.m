//
//  DailyRepeatSubview.m
//  XReader
//
//  Created by Pablo Collins on 2/27/11.
//

#import "DailyRepeatSubview.h"

@implementation DailyRepeatSubview

@synthesize button, subView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"DailyRepeatSubview" owner:self options:nil];
        //NSLog(@"button: %@", button);
        [self addSubview:subView];
    }
    return self;
}


@end
