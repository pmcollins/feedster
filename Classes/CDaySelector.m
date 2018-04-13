//
//  CDaySelector.m
//  XReader
//
//  Created by Pablo Collins on 1/29/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "CDaySelector.h"

@implementation CDaySelector

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
	self.title = @"Repeat";
	weekdays = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
	selectedDays = [[NSMutableSet alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
	//NSLog(@"**CDaySelector");
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
	cell.textLabel.text = [NSString stringWithFormat:@"Every %@", weekdays[[indexPath row]]];
	NSNumber *n = @([indexPath row]);
	if ([selectedDays containsObject:n]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSNumber *n = @([indexPath row]);
	if ([selectedDays containsObject:n]) {
		[selectedDays removeObject:n];
	} else {
		[selectedDays addObject:n];
	}
	NSArray *a = @[indexPath];
	[tableView reloadRowsAtIndexPaths:a withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark Stuff

- (void)setFeed:(Feed *)f {
	feed = f;
}

@end

