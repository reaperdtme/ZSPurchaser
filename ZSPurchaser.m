//
//  WChatPurchaser.m
//  Whisper
//
//  Created by Zed Scio on 12/20/12.
//  Copyright (c) 2012 Whisper. All rights reserved.
//

#import "WPurchaser.h"
#import "WRemote.h"
#import "Mixpanel.h"
#import "WAppDelegate.h"

@implementation ZSPurchaser {
    NSInteger retries;
}

@synthesize purchase, productRequestBlock, purchaseSuccessBlock, maxUnknownErrorAttempts;

- (void)requestProducts:(NSString *)productId, ... {
    NSMutableSet *productIds = [NSMutableSet set];
	va_list args;
    va_start(args, productId);
    for (NSString *arg = productId; arg != nil; arg = va_arg(args, NSString *)) {
        [productIds addObject:arg];
    }
    va_end(args);
    SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    req.delegate = self;
    [req start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    if (productRequestBlock) productRequestBlock(self.products);
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
                if (purchaseSuccessBlock) {
                    purchaseSuccessBlock(YES, transaction);
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed: {
				if (transaction.error.code == SKErrorUnknown && retries < self.maxUnknownErrorAttempts) {
                    retries++;
                    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                    [self purchaseProduct:self.purchase onComplete:self.purchaseSuccessBlock];
                    return;
				}
                retries = 0;
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                if(self.purchaseSuccessBlock) self.purchaseSuccessBlock(NO, transaction.error);
                else [[NSNotificationCenter defaultCenter] postNotificationName:@"failed_purchase" object:nil];
                break;
            }
            default:
                break;
        }
    }
}

+ (ZSPurchaser *)p {
	ZSPurchaser *p = [[ZSPurchaser alloc] init];
	p.maxUnknownErrorAttempts = 3;
	return p;
}

@end
