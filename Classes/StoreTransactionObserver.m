//
//  StoreTransactionObserver.m
//  XReader
//
//  Created by Pablo Collins on 2/3/13.
//  Copyright (c) 2013 Trickbot. All rights reserved.
//

#import "StoreTransactionObserver.h"

@interface StoreTransactionObserver () {
} @end

@implementation StoreTransactionObserver

+ (StoreTransactionObserver *)sharedInstance
{
    static StoreTransactionObserver *me;
    if (me == nil) {
        me = [[StoreTransactionObserver alloc] init];
    }
    return me;
}

- (id)init
{
    self = [super init];
    
    if ([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

#pragma mark - SKPaymentTransactionObserver

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                // Transaction is being added to the server queue.
                NSLog(@"updatedTransaction: SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                // Transaction is in queue, user has been charged.  Client should complete the transaction.
                NSLog(@"updatedTransaction: SKPaymentTransactionStatePurchased");
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                // Transaction was cancelled or failed before being added to the server queue.
                NSLog(@"updatedTransaction: SKPaymentTransactionStateFailed");
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                // Transaction was restored from user's purchase history.  Client should complete the transaction.
                NSLog(@"updatedTransaction: SKPaymentTransactionStateRestored");
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"??paymentQueueRemovedTransactions: %@", transactions);
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFailedWithError: %@", error);
    [_delegate transactionFailedForProduct:nil withError:error];
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"??paymentQueueRestoreCompletedTransactionsFinished");
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    NSLog(@"??paymentQueue updatedDownloads");
}

#pragma mark - my SK stuff

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
//    NSLog(@"recordTransaction");
}

- (void)provideContent:(NSString *)productIdentifier
{
//    NSLog(@"provideContent: productIdentifier: %@", productIdentifier);
    [_delegate completedTransactionForProduct:productIdentifier];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [_delegate transactionFailedForProduct:transaction.payment.productIdentifier withError:transaction.error];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
