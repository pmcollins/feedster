//
//  CUpgrade.m
//  XReader
//
//  Created by Pablo Collins on 2/23/13.
//

#import "CUpgrade.h"
#import "XReaderAppDelegate.h"

@interface CUpgrade () {
    NSMutableDictionary *_products;
} @end

@implementation CUpgrade

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Feedster Premium";
        _products = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [StoreTransactionObserver sharedInstance].delegate = self;
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductData];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"The app store is not accepting  payments from this account. Please check your settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark

- (void)requestProductData
{
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:
                                  [NSSet setWithObject:kProductIdentifierFullVersion]];
    request.delegate = self;
    [request start];
}

- (void)setPriceAndEnableButtons
{
    _upgradeBtn.hidden = _restoreBtn.hidden= NO;
    _upgradeBtn.enabled = _restoreBtn.enabled = YES;
    _loadingViewContainer.hidden = YES;
    
    SKProduct *product = _products[kProductIdentifierFullVersion];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *priceString = [numberFormatter stringFromNumber:product.price];
    
    [_upgradeBtn setTitle:[NSString stringWithFormat:@"❦ Upgrade to Premium (%@)", priceString] forState:UIControlStateNormal];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    for (SKProduct *p in products) {
        _products[p.productIdentifier] = p;
    }
    [self performSelectorOnMainThread:@selector(setPriceAndEnableButtons) withObject:nil waitUntilDone:NO];
}

#pragma mark - StoreTransactionObserverDelegate

- (void)completedTransactionForProduct:(NSString *)productIdentifier
{
    if ([productIdentifier isEqualToString:kProductIdentifierFullVersion]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPrefFullVersion];
        _upgradeBtn.hidden = _restoreBtn.hidden = YES;
        _thankYouLabel.hidden = NO;
    }
}

- (void)transactionFailedForProduct:(NSString *)productIdentifier withError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPrefFullVersion];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    _upgradeBtn.enabled = _restoreBtn.enabled = YES;
}

- (void)viewDidUnload {
    [self setActivityIndicator:nil];
    [self setUpgradeBtn:nil];
    [self setRestoreBtn:nil];
    [self setThankYouLabel:nil];
    [self setLoadingViewContainer:nil];
    [super viewDidUnload];
}

#pragma - Actions

- (IBAction)upgradeTouched:(id)sender {
    _upgradeBtn.enabled = _restoreBtn.enabled = NO;

    SKProduct *p = _products[kProductIdentifierFullVersion];
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction)restoreTouched:(id)sender {
    _upgradeBtn.enabled = _restoreBtn.enabled = NO;

    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
