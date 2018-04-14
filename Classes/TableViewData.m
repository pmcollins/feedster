//
//  TableViewData.m
//  XReader
//
//  Created by Pablo Collins on 1/30/11.
//

#import "TableViewData.h"
#import "TableViewSection.h"

@implementation TableViewData

- (id)init {
    self = [super init];
    sections = [[NSMutableArray alloc] init];
    return self;
}

- (void)addSection:(TableViewSection *)s {
    [sections addObject:s];
}

- (NSInteger)sectionCount {
    return [sections count];
}

- (NSString *)titleForSection:(NSInteger)section {
    TableViewSection *s = sections[section];
    return s.title;
}

- (NSString *)footerForSection:(NSInteger)section {
    TableViewSection *s = sections[section];
    return s.footerTitle;
}

- (NSInteger)rowsInSection:(NSInteger)section {
    TableViewSection *s = [self section:section];
    return [s rowCount];
}

- (TableViewSection *)section:(NSInteger)section {
     return sections[section];
}

- (TableViewRow *)rowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewSection *s = [self section:[indexPath section]];
    return [s rowAtIndex:[indexPath row]];
}


@end
