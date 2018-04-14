//
//  CHourSelector.m
//  XReader
//
//  Created by Pablo Collins on 3/6/11.
//

#import "CHourSelector.h"

@implementation CHourSelector

@synthesize picker;

- (id)initWithDefaultsKey:(NSString *)key
{
    self = [super initWithNibName:@"CHourSelector" bundle:nil];
    if (self) {
        self.title = key;
        defaultsKey = key;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    NSInteger i = [defaults integerForKey:defaultsKey];
    [picker selectRow:i inComponent:0 animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 24;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%li:00", (long)row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    [defaults setInteger:row forKey:defaultsKey];
}

@end
