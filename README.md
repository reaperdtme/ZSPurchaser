# ZSPurchaser

Simple Wrapper for the iOS StoreKit

## Features
1. Simple purchase block
2. Grab products early, so users don't have to wait on the product request
3. Just returns the final SKProduct and SKPaymentTransactions (or error)
4. Retries on SKErrorUnknown a specifiable amount of times
5. Replaces the StoreKit import


## Suggested Usage:

1. Add the purchaser as a prop to your AppDelegate
2. Inititate the product request on launch

	```objective-c

	-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
		self.purchaser = [ZSPurchaser p];  
		[self.purchaser requestProducts:kFirstProductIdentifier, kSecondProductIdentifier, nil];
                        
	```
3. Access it from anywhere in your app, just import your app delegate and call

	```objective-c

	ZSPurchaser *p =  [(MyAppDelegate *)[UIApplication sharedApplication].delegate purchaser];  
	if (p.products) {  
		[self showProducts:p.products];  
	} else {  
		// If products aren't loaded yet, set callback  
		p.productsLoaded = ^(NSArray *products){  
			[self showProducts:p.products];  
		};  
		[self showLoading]; //Display loading indicator  
	}  

	```
4. When purchasing, call the purchase method  with your SKProduct and callback

	```objectivec
	
	[p purchaseProduct:mProduct onComplete:^(BOOL success, id result) {  
		if (success) {  
			SKPaymentTransaction *transaction = (SKPaymentTransaction *)result;  
			//This line really isn't necessary, you can just pass result  
			[self handlePurchase:transaction];  
		} else {  
			NSError *e = (NSError *)result;  
			[self handlePurchaseError:e];  
		}  
	}];

	```