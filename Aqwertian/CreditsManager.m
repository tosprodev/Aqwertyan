//
//  CreditsManager.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "CreditsManager.h"
#import "Util.h"

@interface CreditsManager() {
SKProductsRequest * _request;
}

@property (strong) SKProductsRequest *request;
@property (strong, atomic) NSDate *theDate;

- (void) buyProductWithIdentifier:(NSString *)productIdentifier;
- (void) purchaseFailed:(NSString *)productID reason:(NSString *)reason;
- (void) processTransaction:(SKPaymentTransaction *)transaction;
- (void) requestProductDetails:(NSString *)productIdentifier;
- (void) validatePurchase:(NSString *)productID forUser:(NSString *)userID;

@end

@implementation CreditsManager {
    void (^theCallback)(BOOL);
    NSInteger theNumberOfCredits;
    NSMutableDictionary *theTransactions;
    NSMutableDictionary *theOptions;
    
}

////
# pragma mark - INIT
//

+ (CreditsManager *)sharedManager {
    static CreditsManager *theManager = nil;
    if (theManager == nil) {
        theManager = [CreditsManager new];
    }
    
    return theManager;
}

- init {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        theTransactions = [NSMutableDictionary new];
        theOptions = [NSMutableDictionary new];
    }
    return self;
}

////
# pragma mark - CREDITS
//

- (NSInteger)numberOfCredits {
    int theCredits = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Credits"] integerValue];

    return theCredits;
}

- (void) addCredits:(NSInteger)aNumber {
    NSNumber *theNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"Credits"];
    if (!theNumber) {
        theNumber = [NSNumber numberWithInt:0];
    }
    theNumber = [NSNumber numberWithInt:[theNumber integerValue] + aNumber];
    [[NSUserDefaults standardUserDefaults] setObject:theNumber forKey:@"Credits"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)subtractCredit {
    if ([self numberOfCredits] > 0) {
        [self addCredits:-1];
        return YES;
    }
    return NO;
}


////
# pragma mark - IN APP PURCHASE
//

- (void)buyCredits:(NSInteger)aNumberOfCredits withCallback:(void (^)(BOOL))aCallback {
    theCallback = aCallback;
    theNumberOfCredits = aNumberOfCredits;
    [self buyProductWithIdentifier:[NSString stringWithFormat:@"com.aqwertyan.credits.%d", theNumberOfCredits]];
}

- (void)requestProductDetails:(NSString *)productIdentifier {
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSArray arrayWithObject:productIdentifier]];
    _request.delegate = self;
    [_request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Received products results...");
    self.request = nil;
    if (response.products.count > 0) {
        
        SKPayment *payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    } else {
        NSLog(@"Received products results... failed");
        [self purchaseFailed:@"don't know" reason:@"We were unable to identify the product you tried to purchase."];
    }
}



- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    
    NSLog(@"completeTransaction...");
    NSLog(@"Tansaction: %@ --%@ -- %@",transaction.transactionIdentifier, [transaction.transactionDate description],  transaction.payment.productIdentifier);
    
    [self processTransaction:transaction];
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"restoreTransaction...");
    NSLog(@"Tansaction: %@ --%@ -- %@",transaction.transactionIdentifier, [transaction.transactionDate description],  transaction.payment.productIdentifier);
    
    [self processTransaction: transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        NSLog(@"Tansaction: %@ --%@ -- %@",transaction.transactionIdentifier, [transaction.transactionDate description],  transaction.payment.productIdentifier);
        [self purchaseFailed:transaction.payment.productIdentifier reason:@"There was an error processing your purchase."];
    } else if (transaction.error.code == SKErrorPaymentCancelled) {
        [self purchaseCancelled:transaction.payment.productIdentifier];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}



- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    NSLog(@"Removed transaction..");
    for (SKPaymentTransaction *transaction in transactions)
        NSLog(@"Tansaction: %@ --%@ -- %@",transaction.transactionIdentifier, [transaction.transactionDate description],  transaction.payment.productIdentifier);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"Recieved Payment..");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
                
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                //[queue finishTransaction:transaction];
                break;
        }
    }
}

- (void)buyProductWithIdentifier:(NSString *)productIdentifier {
    
    NSLog(@"Requesting details to buy %@...", productIdentifier);
    [self requestProductDetails:productIdentifier];
}




////
# pragma mark - FINISHING PURCHASE
//

- (void)purchaseCancelled:(NSString *)productID {
    if (theCallback) {
    theCallback(NO);
    }
}

- (void)purchaseFailed:(NSString *)productID reason:(NSString *)reason {
    if (theCallback != nil) {
        theCallback(NO);
    }
    [Util showAlertWithTitle:@"Error" message:reason];
}

- (void)processTransaction:(SKPaymentTransaction *)transaction {
    [self addCredits:theNumberOfCredits];
    if (theCallback) {
    theCallback(YES);
    }
}




@end
