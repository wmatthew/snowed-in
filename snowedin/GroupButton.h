//
//  PackButton.h
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "BoxButton.h"
#import "LevelManager.h"
#import "cocos2d.h"

@class ButtonOrientation;

typedef enum {
    // house base is on menu, below these.
    depthHouseTrim = 2,
    depthHouseRoof = 4,
    depthLightSnow = 6,
    depthHeavySnow = 8,
    depthHouseWindows = 10,
} houseDepth;

@interface GroupButton : BoxButton {
    levelGroup _myGroup;
    CCSprite *_baseSprite;
    CCSprite *_trimSprite;
    CCSprite *_roofSprite;
    CCSprite *_lightSnowSprite;
    CCSprite *_heavySnowSprite;
}

+ (GroupButton*) makeButton:(levelGroup)group orientation:(ButtonOrientation*)orient parent:(CCLayer*)parent menu:(CCMenu*)menu menuDepth:(int)menuDepth;
- (float) butScale;
- (void) drawGroup;
- (void) drawLabel;
- (void) setGroup:(levelGroup)group;
- (void) setHouseColors;

@end
