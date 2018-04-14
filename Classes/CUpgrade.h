//
//  CUpgrade.h
//  XReader
//
//  Created by Pablo Collins on 2/23/13.
//

#import <UIKit/UIKit.h>
#import "StoreTransactionObserver.h"
#import <StoreKit/StoreKit.h>

@interface CUpgrade : UIViewController <SKProductsRequestDelegate, StoreTransactionObserverDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *upgradeBtn;
@property (strong, nonatomic) IBOutlet UIButton *restoreBtn;
@property (strong, nonatomic) IBOutlet UILabel *thankYouLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingViewContainer;

- (IBAction)upgradeTouched:(id)sender;
- (IBAction)restoreTouched:(id)sender;

@end
