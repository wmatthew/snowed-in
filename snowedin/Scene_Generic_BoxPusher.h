//
//  Scene_Generic_BoxPusher.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/25/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "Scene_Generic.h"
#import "Dimensions.h"
#import "PurchasePopup.h"
#import "SignAction.h"

@interface Scene_Generic_BoxPusher : Scene_Generic <RespondsToPurchases> {}

+ (void) goToNextScene:(CCNode*)nextScene;

- (void) addLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize;
- (void) addBottomLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize;

- (void) refreshBecauseSomethingWasPurchased;

@end
