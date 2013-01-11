//
//  ZSPurchaser.h
//  Whisper
//
//  Created by Zed Scio on 12/20/12.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^ProductRequestBlock) (NSArray *products);
typedef void (^PurchaseSuccessBlock)(BOOL success, id result);

@interface ZSPurchaser : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) SKProduct *purchase;
@property (nonatomic, strong) ProductRequestBlock productRequestBlock;
@property (nonatomic, strong) PurchaseSuccessBlock purchaseSuccessBlock;
@property NSInteger maxUnknownErrorAttempts;

- (void)requestProducts:(NSString *) productId,...;
- (void)purchaseProduct:(SKProduct*)product onComplete:(PurchaseSuccessBlock)completion;
+ (ZSPurchaser *)p;

@end
