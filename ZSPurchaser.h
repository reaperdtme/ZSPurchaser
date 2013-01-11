//
//  ZSPurchaser.h
//  Whisper
//
//  Created by Zed Scio on 12/20/12.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^ProductRequestBlock) (BOOL success, NSArray *products);
typedef void (^PurchaseSuccessBlock)(BOOL success, id result);

@interface WPurchaser : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) SKProduct *purchase;
@property (nonatomic, strong) ProductRequestBlock productComplete;
@property (nonatomic, strong) PurchaseSuccessBlock completion;
@property NSInteger maxUnknownErrorAttempts;

- (void)requestProducts:(ProductRequestBlock)productRequestBlock;
- (void)purchaseProduct:(SKProduct*)product onComplete:(PurchaseSuccessBlock)completion;

@end
