//
//  CreditsManager.h
//  Aqwertian
//
//  Created by Nathan Ziebart on 11/26/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface CreditsManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (CreditsManager *)sharedManager;
- (NSInteger) numberOfCredits;
- (BOOL) subtractCredit;
- (void) buyCredits:(NSInteger)aNumberOfCredits withCallback:(void (^)(BOOL))aCallback;
- (void) addCredits:(NSInteger)aNumber;

@end
