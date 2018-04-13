//
//  CPeriodSelector.m
//  XReader
//
//  Created by Pablo Collins on 3/13/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "COptionSelector.h"
#import "Feed+Logic.h"

@implementation COptionSelector

@synthesize pickerView, action;

- (id)initWithOptions:(NSArray *)o selected:(NSNumber *)n feed:(Feed *)feed
{
    self = [super initWithNibName:@"COptionSelector" bundle:nil];
    if (self) {
        preselected = n;
        options = o;
        _feed = feed;
    }
    return self;
}

- (IBAction)done
{
    action();
}

- (NSInteger)indexForValue:(NSInteger)m
{
    NSArray *a;
    int i = 0;
    for (a in options) {
        NSNumber *n = a[1];
        if ([n intValue] == m) {
            return i;
        }
        i += 1;
    }
    return -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSInteger idx = [self indexForValue:[preselected intValue]];
    [pickerView selectRow:idx inComponent:0 animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [options count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)rowNum forComponent:(NSInteger)component
{
    NSArray *row = options[rowNum];
    return row[0];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _feed.refreshPeriod = options[row][1];
}

@end
