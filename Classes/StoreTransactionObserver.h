//
//  StoreTransactionObserver.h
//  XReader
//
//  Created by Pablo Collins on 2/3/13.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kProductIdentifierFullVersion @"feedster.inapp.premium"

@protocol StoreTransactionObserverDelegate <NSObject>

- (void)completedTransactionForProduct:(NSString *)productIdentifier;
- (void)transactionFailedForProduct:(NSString *)productIdentifier withError:(NSError *)error;

@end

@interface StoreTransactionObserver : NSObject <SKPaymentTransactionObserver>

@property id<StoreTransactionObserverDelegate> delegate;

+ (StoreTransactionObserver *)sharedInstance;

@end
