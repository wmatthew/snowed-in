//
//  SignAction.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/20/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelManager.h"

typedef enum {
    actionPurchasePopup,
    actionNextHill,
    actionJumpLeft,
    actionPlayNextLevel,
    actionGoMainMenu, // scene_group
    actionPlayThisLevel, // scene_group
} signActionType;

@interface SignAction : NSObject {
    signActionType _action;
    levelPack _pack;
    int _levelID;
}

+ (SignAction*) make:(signActionType)actionType pack:(levelPack)pack;
+ (SignAction*) makePlayThisLevel:(int)levelID;

- (signActionType) getActionType;
- (levelPack) getPack;
- (int) getLevelID;

- (void) setActionType:(signActionType)action;
- (void) setPack:(levelPack)pack;
- (void) setLevelID:(int)levelID;

@end
