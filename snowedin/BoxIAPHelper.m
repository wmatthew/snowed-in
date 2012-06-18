//
//  BoxIAPHelper.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/12/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "BoxIAPHelper.h"
#import "SquidLog.h"
#import "BoxProduct.h"
#import "BoxControlRoom.h"

@implementation BoxIAPHelper

static BoxIAPHelper * _sharedHelper;

+ (BoxIAPHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[BoxIAPHelper alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[BoxIAPHelper sharedHelper]];
    return _sharedHelper;    
}

// Return all products, free or otherwise.
+ (NSArray*) fetchProducts {
    NSMutableArray *allProductKeys = [[[NSMutableArray alloc] init] autorelease];
    for (BoxProduct *product in [BoxProduct getAllProductsInOrder]) {
        [allProductKeys addObject:[product getProductKey]];
    }

    //=========================
    // Sanity checks
    int expectedCount;
    appVersion myVersion = [BoxControlRoom getMyAppVersion];
    if (myVersion == appVersionFree) {
        expectedCount = 13;
    } else if (myVersion == appVersionPaid) {
        expectedCount = 12;
    } else {
        [SquidLog error:@"unexpected app type: %i", myVersion];
    }
    if ([allProductKeys count] != expectedCount) {
        [SquidLog warn:@"Regression warning- expected %i products, found %i.", expectedCount, [allProductKeys count]];
    }
    //=========================
    
    return allProductKeys;
}

- (id)init {
    NSSet *productIdentifiers = [NSSet setWithArray:[BoxIAPHelper fetchProducts]];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
    }
    return self;
}

@end