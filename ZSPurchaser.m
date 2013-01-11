//
//  WChatPurchaser.m
//  Whisper
//
//  Created by Zed Scio on 12/20/12.
//  Copyright (c) 2012 Whisper. All rights reserved.
//

#import "WPurchaser.h"

@implementation WPurchaser {
    NSInteger retries;
}

@synthesize purchase, productComplete, completion, maxUnknownErrorAttempts;

- (void)requestProducts:(ProductRequestBlock)productBlock {
    NSSet *productIds = [NSSet setWithObjects:kInApp1MonthSubscription, kInApp3MonthSubscription, kInApp6MonthSubscription, kInAppPurchase1DaySubscription, nil];
    SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    req.delegate = self;
    [req start];
    self.productComplete = productBlock;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    if (productComplete) productComplete(YES, self.products);
}

- (void)purchaseProduct:(SKProduct *)product onComplete:(PurchaseSuccessBlock)completion {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    self.purchase = product;
    SKPayment *p = [SKPayment paymentWithProduct:self.purchase];
    [[SKPaymentQueue defaultQueue] addPayment:p];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                if (completion) {
                    completion(YES, transaction);
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed: {
                NSMutableDictionary *errorCode = [NSMutableDictionary dictionary];
				if (transaction.error.code == SKErrorUnknown && retries < self.maxUnknownErrorAttempts) {
                    retries++;
                    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                    [self purchaseProduct:self.purchase onComplete:self.completion];
                    return;
				}
                retries = 0;
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                if(self.completion) self.completion(NO, transaction.error);
                else [[NSNotificationCenter defaultCenter] postNotificationName:@"failed_purchase" object:nil];
                break;
            }
            default:
                break;
        }
    }
}

@end
