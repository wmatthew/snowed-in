//
//  FreeProduct.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/17/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelManager.h"
@class SKProduct;

typedef enum {
    PurchaseNoPurchase,
    PurchaseRemoveAllAds,
    PurchaseUnlockSmallHints,
    PurchaseUnlockMediumHints,
    PurchaseUnlockLargeHints,
    PurchaseUnlockAllHints,
    PurchaseHillIntro,
    PurchaseHillInvert,
    PurchaseHillOne,
    PurchaseHillTwo,
    PurchaseHillThree,
    PurchaseHillFour,
    PurchaseHillFive,
    PurchaseHillSix,
} purchasableThing;

typedef enum {
    costsMoney,
    isFree,
    freeAndPreinstalled,
} costType;

typedef enum {
    appVersionFree,
    appVersionPaid,
} appVersion;

@interface BoxProduct : NSObject {
    purchasableThing _thing;
    NSString *_productKey;
    NSString *_displayTitle;
    costType _costType;
}

+ (void) initializeProductKeyStrings;

+ (NSArray*) getAllProductsInOrder;
+ (BoxProduct*) productForPurchaseKey:(NSString*)purchaseKey;
+ (BoxProduct*) productForThing:(purchasableThing)thing;
+ (BoxProduct*) getProductFromPack:(levelPack)pack;

- (purchasableThing) purchaseEnum;
- (NSString*) getProductKey;
- (NSString*) getDisplayTitle;
- (bool) isFree;
- (bool) isFreeAndPreInstalled;
- (bool) didUserBuyMe;
- (SKProduct*) getSKProduct;

+ (void) initAllProducts:(appVersion)version;

@end
