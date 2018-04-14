//
//  DailyRepeatSubview.h
//  XReader
//
//  Created by Pablo Collins on 2/27/11.
//

#import <UIKit/UIKit.h>

@interface DailyRepeatSubview : UIView {
    UIButton *button;
    UIView *subView;
}

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UIView *subView;

@end
