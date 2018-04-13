//
//  AbstractAdViewController.h
//  XReader
//
//  Created by Pablo Collins on 2/17/13.
//  Copyright (c) 2013 Trickbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AbstractAdViewController : UIViewController <ADBannerViewDelegate> {
    ADBannerView *_adView;
}

@property (nonatomic, strong) IBOutlet UITableView * tableView;

@end
