//
//  CHourSelector.h
//  XReader
//
//  Created by Pablo Collins on 3/6/11.
//

#import <UIKit/UIKit.h>

@interface CHourSelector : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    NSString *defaultsKey;
    UIPickerView *picker;
    NSUserDefaults *defaults;
}

@property (nonatomic, strong) IBOutlet UIPickerView *picker;

- (id)initWithDefaultsKey:(NSString *)key;

@end
