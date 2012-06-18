//
//  HintLayer.h
//  Snowed In!!
//
//  Created by Matthew Webber on 7/6/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "HintEnums.h"
#import "PurchasePopup.h"
#import "boxpusher.h"

@class HUD_Play;

@interface HintLayer : CCLayerColor <RespondsToPurchases> {
    CCMenu *_hintMenu;
    NSMutableArray *_hintButtons;
    hintType _biggestHintSeenYet;
    HUD_Play *_playHUD;
    CCLabelTTF *_signText;
}

+ (HintLayer*) makeHintLayerWithParent:(HUD_Play*)parent;

- (CCMenuItemImage*) addButtonAt:(CGPoint)pos
                      conversion:(screenConversionType)conversion
                        function:(SEL)selector
                           color:(ccColor3B)color
                        selColor:(ccColor3B)selColor
                   defaultSprite:(CCSprite*)defaultSprite
                  selectedSprite:(CCSprite*)selectedSprite;

+ (int) getHintSize:(hintType)type fullSolution:(int)fullLength;

- (id) initHintWithColor:(ccColor4B)color andHUD:(HUD_Play*) playHUD;

- (CCLabelTTF*) addLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize conversion:(screenConversionType)conversionType;
- (void) addHintButtonAt:(CGPoint)pos type:(hintType)hintType;

- (hintStatus) getHintStatus:(hintType)hintType;
- (bool) isFreebieHint:(hintType)hintType;

- (void) hideHintLayer:(id)sender;
- (void) showHintLayer;

- (void) updateHintColors;
- (void) addHintSign;

@end
