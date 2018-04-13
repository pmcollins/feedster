//
//  DailyRepeatSubview.h
//  XReader
//
//  Created by Pablo Collins on 2/27/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyRepeatSubview : UIView {
    UIButton *button;
    UIView *subView;
}

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UIView *subView;

@end
