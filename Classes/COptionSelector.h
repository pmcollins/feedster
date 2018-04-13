//
//  CPeriodSelector.h
//  XReader
//
//  Created by Pablo Collins on 3/13/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFeedSettings.h"

typedef void (^CallbackAction)();

@interface COptionSelector : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    UIPickerView *pickerView;
    NSArray *options;
    CallbackAction action;
    NSNumber *preselected;
    Feed *_feed;
}

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, copy) CallbackAction action;

- (id)initWithOptions:(NSArray *)o selected:(NSNumber *)n feed:(Feed *)feed;
- (IBAction)done;

@end
