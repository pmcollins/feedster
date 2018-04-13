//
//  CAppSettings.m
//  XReader
//
//  Created by Pablo Collins on 3/5/11.
//  Copyright 2011 trickbot. All rights reserved.
//

#import "CAppSettings.h"
#import "TableViewSection.h"
#import "TableViewRow.h"
#import "CHourSelector.h"
#import "CFolders.h"
#import "XReaderAppDelegate.h"
#import "CUpgrade.h"

#import <StoreKit/StoreKit.h>

@interface CAppSettings () {
    CFeedList *_cFeedList;
    TableViewData *_tableData;
    NSUserDefaults *_userDefaults;
    NSMutableDictionary *_switches;
    UITableViewCell *_upgradeCell;
} @end

@implementation CAppSettings

- (id)initWithOpener:(CFeedList *)o
{
    self = [super initWithNibName:@"CAppSettings" bundle:nil];
    if (self) {
        _cFeedList = o;
        _switches = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)showPremiumEnabled
{
    _upgradeCell.textLabel.font = [UIFont italicSystemFontOfSize:18];
    _upgradeCell.textLabel.text = @"❦ Premium Enabled";
    _upgradeCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.title = @"Settings";
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneBtn;
    _tableData = [[TableViewData alloc] init];
    
    TableViewSection *section;
    TableViewRow *row;
    
    NSString *title;
    NSString *key;
    SEL selector;
    
    ////
    section = [[TableViewSection alloc] initWithTitle:nil];
    
    row = [[TableViewRow alloc] init];
    row.height = 44;
        
    row.cellMaker = ^{
        _upgradeCell = [[UITableViewCell alloc] init];
        if ([_userDefaults boolForKey:kPrefFullVersion]) {
            [self showPremiumEnabled];
        } else {
            _upgradeCell.textLabel.text = @"❦ Upgrade to Premium";
        }
        return _upgradeCell;
    };
    row.rowSelectionCallback = ^{
        if (![_userDefaults boolForKey:kPrefFullVersion]) {
            CUpgrade *cUpgrade = [[CUpgrade alloc] initWithNibName:@"CUpgrade" bundle:nil];
            [self.navigationController pushViewController:cUpgrade animated:YES];
        }
    };
    
    [section addRow:row];
    [_tableData addSection:section];
    
    section = [[TableViewSection alloc] initWithTitle:nil];
    section.footerTitle = @"Edit and rearrange your feed categories.";
    row = [[TableViewRow alloc] init];
    row.cellMaker = ^{
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = @"Feed Categories";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    };
    row.rowSelectionCallback = ^{
        CFolders *cFolders = [[CFolders alloc] initWithNibName:@"CFolders" bundle:nil];
        [self.navigationController pushViewController:cFolders animated:YES];
    };
    [section addRow:row];
    [_tableData addSection:section];
    
    ////
    section = [[TableViewSection alloc] initWithTitle:nil];
    
    row = [[TableViewRow alloc] init];
    row.height = 56;

    title = @"Automatically update feeds";
    key = kPrefFeedAutoUpdates;
    selector = @selector(feedAutoUpdateChanged:);

    row.cellMaker = [self mkCellMaker:title selector:selector key:key enabled:YES margin:8];
    
    [section addRow:row];
    [_tableData addSection:section];
    
    ////
    section = [[TableViewSection alloc] initWithTitle:nil];
    section.footerTitle = @"To protect your cellular data plan, podcasts will download automatically only over WiFi. However, a podcast can always be downloaded manually by touching its download button.";
    
    row = [[TableViewRow alloc] init];
    row.height = 56;
    
    title = @"Automatically download new podcasts";
    key = kPrefPodcastAutoDownloads;
    selector = @selector(podcastAutoDownloadsChanged:);
    
    row.cellMaker = [self mkCellMaker:title selector:selector key:key enabled:YES margin:8];
    
    [section addRow:row];
    [_tableData addSection:section];

}

- (CellMaker)mkCellMaker:(NSString *)title selector:(SEL)selector key:(NSString *)key enabled:(BOOL)enabled margin:(NSUInteger)m
{
    return ^{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:nil];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(19, m, 200, 40)];
        l.font = [UIFont boldSystemFontOfSize:17];
        l.backgroundColor = [UIColor clearColor];
        l.numberOfLines = 2;
        l.text = title;
        [cell addSubview:l];
        
        UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(214, 7 + m, 0, 0)];
        _switches[key] = sw;

        sw.enabled = enabled;
        sw.on = [_userDefaults boolForKey:key];
        [sw addTarget:self
               action:selector
     forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:sw];
        
        return cell;
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    if ([_userDefaults boolForKey:kPrefFullVersion]) {
        [self showPremiumEnabled];
    }
    
    [super viewWillAppear:animated];
}

- (void)done
{
    [_cFeedList dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - event handlers

- (void)podcastAutoDownloadsChanged:(UISwitch *)sw
{
    [_userDefaults setBool:sw.on forKey:kPrefPodcastAutoDownloads];
}

- (void)feedAutoUpdateChanged:(UISwitch *)sw
{
    [_userDefaults setBool:sw.on forKey:kPrefFeedAutoUpdates];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [_tableData sectionCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [_tableData titleForSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [_tableData footerForSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_tableData rowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewRow *row = [_tableData rowAtIndexPath:indexPath];
	return row.cellMaker();
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewRow *row = [_tableData rowAtIndexPath:indexPath];
    return row.height == 0 ? 44 : row.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewRow *row = [_tableData rowAtIndexPath:indexPath];
    if (row.rowSelectionCallback) {
        row.rowSelectionCallback();
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *out = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    out.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 300, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    [out addSubview:label];
    return out;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

@end
