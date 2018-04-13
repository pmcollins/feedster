//
//  TableViewRow.h
//  XReader
//
//  Created by Pablo Collins on 3/6/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewData.h"

typedef UITableViewCell * (^CellMaker)(void);
typedef void (^RowSelectionCallback)(void);

@interface TableViewRow : NSObject

@property (copy, nonatomic) CellMaker cellMaker;
@property (copy, nonatomic) RowSelectionCallback rowSelectionCallback;
@property (nonatomic) CGFloat height;

@end
