//
//  FreeProduct.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/17/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import "BoxProduct.h"
#import "boxpusher.h"

NSString *PURCHASE_KEY_REMOVE_ADS; 
NSString *PURCHASE_KEY_HILL_INTRO; 
NSString *PURCHASE_KEY_HILL_INVERT;
NSString *PURCHASE_KEY_HILL_1;
NSString *PURCHASE_KEY_HILL_2; 
NSString *PURCHASE_KEY_HILL_3;  
NSString *PURCHASE_KEY_HILL_4;   
NSString *PURCHASE_KEY_HILL_5;   
NSString *PURCHASE_KEY_HILL_6;    
NSString *PURCHASE_KEY_UNLOCK_SMALL_HINTS;
NSString *PURCHASE_KEY_UNLOCK_MEDIUM_HINTS;
NSString *PURCHASE_KEY_UNLOCK_LARGE_HINTS;
NSString *PURCHASE_KEY_UNLOCK_ALL_HINTS;

@implementation BoxProduct

static NSMutableDictionary *dictionaryByEnum;
static NSMutableDictionary *dictionaryByProductKey;
static NSMutableArray *productsInOrder;

+ (void) initialize {
    
    [self initializeProductKeyStrings];
    
    dictionaryByEnum = [[[NSMutableDictionary alloc] init] retain];
    dictionaryByProductKey = [[[NSMutableDictionary alloc] init] retain];
    productsInOrder = [[[NSMutableArray alloc] init] retain];
    
    [self initAllProducts:[BoxControlRoom getMyAppVersion]];
}

// This function is a little verbose, but it's nice to have these strings come up when I search for a product key.
+ (void) initializeProductKeyStrings {
    
    appVersion myVersion = [BoxControlRoom getMyAppVersion];
    
    if (myVersion == appVersionPaid) {

        PURCHASE_KEY_REMOVE_ADS         = @"com.squidmixer.snowedin.standard.remove_ads"; // should never come up
        PURCHASE_KEY_HILL_INTRO         = @"com.squidmixer.snowedin.standard.hill_intro";
        PURCHASE_KEY_HILL_INVERT        = @"com.squidmixer.snowedin.standard.hill_invert";
        PURCHASE_KEY_HILL_1             = @"com.squidmixer.snowedin.standard.hill_1";
        PURCHASE_KEY_HILL_2             = @"com.squidmixer.snowedin.standard.hill_2";
        PURCHASE_KEY_HILL_3             = @"com.squidmixer.snowedin.standard.hill_3";
        PURCHASE_KEY_HILL_4             = @"com.squidmixer.snowedin.standard.hill_4";
        PURCHASE_KEY_HILL_5             = @"com.squidmixer.snowedin.standard.hill_5";
        PURCHASE_KEY_HILL_6             = @"com.squidmixer.snowedin.standard.hill_6";
        PURCHASE_KEY_UNLOCK_SMALL_HINTS = @"com.squidmixer.snowedin.standard.hints_small";
        PURCHASE_KEY_UNLOCK_MEDIUM_HINTS= @"com.squidmixer.snowedin.standard.hints_medium";
        PURCHASE_KEY_UNLOCK_LARGE_HINTS = @"com.squidmixer.snowedin.standard.hints_large";
        PURCHASE_KEY_UNLOCK_ALL_HINTS   = @"com.squidmixer.snowedin.standard.hints_all";
        
    } else if (myVersion == appVersionFree) {
    
        PURCHASE_KEY_REMOVE_ADS         = @"com.squidmixer.snowedin.free.remove_ads";
        PURCHASE_KEY_HILL_INTRO         = @"com.squidmixer.snowedin.free.hill_intro";
        PURCHASE_KEY_HILL_INVERT        = @"com.squidmixer.snowedin.free.hill_invert";
        PURCHASE_KEY_HILL_1             = @"com.squidmixer.snowedin.free.hill_1";
        PURCHASE_KEY_HILL_2             = @"com.squidmixer.snowedin.free.hill_2";
        PURCHASE_KEY_HILL_3             = @"com.squidmixer.snowedin.free.hill_3";
        PURCHASE_KEY_HILL_4             = @"com.squidmixer.snowedin.free.hill_4";
        PURCHASE_KEY_HILL_5             = @"com.squidmixer.snowedin.free.hill_5";
        PURCHASE_KEY_HILL_6             = @"com.squidmixer.snowedin.free.hill_6";
        PURCHASE_KEY_UNLOCK_SMALL_HINTS = @"com.squidmixer.snowedin.free.hints_small";
        PURCHASE_KEY_UNLOCK_MEDIUM_HINTS= @"com.squidmixer.snowedin.free.hints_medium";
        PURCHASE_KEY_UNLOCK_LARGE_HINTS = @"com.squidmixer.snowedin.free.hints_large";
        PURCHASE_KEY_UNLOCK_ALL_HINTS   = @"com.squidmixer.snowedin.free.hints_all";
    
    } else {
        [SquidLog error:@"Unexpected app version %i", myVersion];
    }
}

// Initialization
- (id) initWithProduct:(purchasableThing)thing
                withID:(NSString*)productKey
          displayTitle:(NSString*)displayTitle
              costType:(costType)costType {
    if (( self = [super init] )) {
        _thing = thing;
        _productKey = productKey;
        _displayTitle = displayTitle;
        _costType = costType;
    }
    return self;
}

+ (BoxProduct*) makeProduct:(purchasableThing)thing
                     withID:(NSString*)purchaseKey
               displayTitle:(NSString*)displayTitle
                   costType:(costType)costType {
    
    return [[[BoxProduct alloc]
            initWithProduct:thing
            withID:purchaseKey
            displayTitle:displayTitle
            costType:costType] autorelease];
}

+ (void) initPurchase:(purchasableThing)thing
              withKey:(NSString*)productKey
         displayTitle:(NSString*)displayTitle
             costType:(costType)costType {
    
    BoxProduct *product = [BoxProduct makeProduct:thing withID:productKey displayTitle:displayTitle costType:costType];

    [dictionaryByEnum setObject:product forKey:[NSNumber numberWithInt:thing]];
    [dictionaryByProductKey setObject:product forKey:productKey];
    [productsInOrder addObject:product];
}

+ (void) initAllProducts:(appVersion)version {

    if (version != appVersionPaid && version != appVersionFree) {
        [SquidLog warn:@"Unexpected app version %i- has it been fully tested?", version];
    }
    
    if (version == appVersionFree) {
        [self initPurchase:PurchaseRemoveAllAds
                   withKey:PURCHASE_KEY_REMOVE_ADS 
              displayTitle:@"Remove All Ads" 
                  costType:costsMoney];
    }
    
    [self initPurchase:PurchaseHillIntro 
               withKey:PURCHASE_KEY_HILL_INTRO 
          displayTitle:@"How To Play (4 Levels)"
              costType:freeAndPreinstalled];
    
    [self initPurchase:PurchaseHillInvert 
               withKey:PURCHASE_KEY_HILL_INVERT 
          displayTitle:@"Inverting (8 Levels)"
              costType:freeAndPreinstalled];
    
    [self initPurchase:PurchaseHillOne 
               withKey:PURCHASE_KEY_HILL_1
          displayTitle:@"First Hill (4 Levels)" 
              costType:freeAndPreinstalled];
    
    [self initPurchase:PurchaseHillTwo
               withKey:PURCHASE_KEY_HILL_2
          displayTitle:@"Second Hill (4 Levels)" 
              costType:freeAndPreinstalled];  
    
    [self initPurchase:PurchaseHillThree
               withKey:PURCHASE_KEY_HILL_3
          displayTitle:@"Third Hill (4 Levels)" 
              costType:isFree];  
    
    [self initPurchase:PurchaseHillFour
               withKey:PURCHASE_KEY_HILL_4 
          displayTitle:@"Fourth Hill (12 Levels)"
              costType:isFree];
    
    if (version == appVersionFree) {
        [self initPurchase:PurchaseHillFive 
                   withKey:PURCHASE_KEY_HILL_5
              displayTitle:@"Fifth Hill (32 Levels)" 
                  costType:costsMoney];
    } else {
        [self initPurchase:PurchaseHillFive 
                   withKey:PURCHASE_KEY_HILL_5
              displayTitle:@"Fifth Hill (32 Levels)" 
                  costType:isFree];
    }
    
    [self initPurchase:PurchaseHillSix 
               withKey:PURCHASE_KEY_HILL_6
          displayTitle:@"Sixth Hill (32 Levels)"
              costType:costsMoney];
    
    if (version == appVersionFree) {
        [self initPurchase:PurchaseUnlockSmallHints 
                   withKey:PURCHASE_KEY_UNLOCK_SMALL_HINTS 
              displayTitle:@"Unlock All Small Hints" 
                  costType:costsMoney];
        // The rest are the same, except for the titles
        [self initPurchase:PurchaseUnlockMediumHints 
                   withKey:PURCHASE_KEY_UNLOCK_MEDIUM_HINTS 
              displayTitle:@"Unlock All Small and Medium Hints" 
                  costType:costsMoney];
        
        [self initPurchase:PurchaseUnlockLargeHints 
                   withKey:PURCHASE_KEY_UNLOCK_LARGE_HINTS 
              displayTitle:@"Unlock All Small, Medium and Large Hints" 
                  costType:costsMoney];
        
        [self initPurchase:PurchaseUnlockAllHints 
                   withKey:PURCHASE_KEY_UNLOCK_ALL_HINTS 
              displayTitle:@"Unlock All Hints and Full Solutions" 
                  costType:costsMoney];
    } else {
        // PAID version
        
        [self initPurchase:PurchaseUnlockSmallHints 
                   withKey:PURCHASE_KEY_UNLOCK_SMALL_HINTS 
              displayTitle:@"Unlock All Small Hints" 
                  costType:isFree];    
        
        // The rest are the same, except for the titles
        [self initPurchase:PurchaseUnlockMediumHints 
                   withKey:PURCHASE_KEY_UNLOCK_MEDIUM_HINTS 
              displayTitle:@"Unlock All Medium Hints" 
                  costType:costsMoney];
        
        [self initPurchase:PurchaseUnlockLargeHints 
                   withKey:PURCHASE_KEY_UNLOCK_LARGE_HINTS 
              displayTitle:@"Unlock All Medium and Large Hints" 
                  costType:costsMoney];
        
        [self initPurchase:PurchaseUnlockAllHints 
                   withKey:PURCHASE_KEY_UNLOCK_ALL_HINTS 
              displayTitle:@"Unlock All Hints and Full Solutions" 
                  costType:costsMoney];
    }
}

+ (BoxProduct*) productForPurchaseKey:(NSString*)purchaseKey {
    BoxProduct *result = [dictionaryByProductKey objectForKey:purchaseKey];
    if (result == nil) {
        [SquidLog error:@"Product not found in productForPurchaseKey: %@", purchaseKey];
    }
    return result;
}

+ (BoxProduct*) productForThing:(purchasableThing)thing {
    if (thing == PurchaseNoPurchase) {
        return nil;
    }

    NSNumber *thingNum = [NSNumber numberWithInt:thing];
    BoxProduct *result = [dictionaryByEnum objectForKey:thingNum];
    if (result == nil) {
        [SquidLog error:@"Product not found in productForThing: %i", thing];
    }
    return result;
}

+ (NSArray*) getAllProductsInOrder {
    return productsInOrder;
}

// internal only
+ (purchasableThing) getThingFromPack:(levelPack)pack {
    switch (pack) {
        case packHowToPlay: return PurchaseHillIntro;
        case packHowToInvert: return PurchaseHillInvert;
        case packHill1: return PurchaseHillOne;
        case packHill2: return PurchaseHillTwo;
        case packHill3: return PurchaseHillThree;
        case packHill4: return PurchaseHillFour;
        case packHill5: return PurchaseHillFive;
        case packHill6: return PurchaseHillSix;
    }
}

+ (BoxProduct*) getProductFromPack:(levelPack)pack {
    return [BoxProduct productForThing:[BoxProduct getThingFromPack:pack]];
}

- (purchasableThing) purchaseEnum {
    return _thing;
}

- (NSString*) getProductKey {
    return _productKey;
}

- (NSString*) getDisplayTitle {
    return _displayTitle;
}

- (bool) isFree {
    return (_costType != costsMoney);
}

- (bool) isFreeAndPreInstalled {
    return (_costType == freeAndPreinstalled);
}

- (bool) didUserBuyMe {
    
    if (_costType == freeAndPreinstalled) {
        return YES;
    }
    return [[BoxIAPHelper sharedHelper].purchasedProducts containsObject:_productKey];
}

- (SKProduct*) getSKProduct {
    if ([self isFree]) {
        [SquidLog error:@"Trying to get SKProduct for free product: %@", _productKey];    
    }
    
    if ([[BoxIAPHelper sharedHelper].products count] == 0) {
        [SquidLog error:@"Products list has 0 entries."];
    }
    
    for (SKProduct *sprod in [BoxIAPHelper sharedHelper].products) {
        if ([sprod.productIdentifier isEqualToString:_productKey]) {
            return sprod;
        }
    }
    [SquidLog error:@"getSKProduct: couldn't match product %@", _productKey];
    return nil;
}

@end
