//
//  SignAction.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/20/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import "SignAction.h"
#import "SquidLog.h"

@implementation SignAction

+ (SignAction*) make:(signActionType)actionType pack:(levelPack)pack {
    if (actionType == actionPlayThisLevel) {
        [SquidLog error:@"nope, use different make method"];
    }
    SignAction *newAction = [[[SignAction alloc] init] retain];
    [newAction setActionType:actionType];
    [newAction setPack:pack];
    return newAction;
}

+ (SignAction*) makePlayThisLevel:(int)levelID {
    SignAction *newAction = [[[SignAction alloc] init] retain];
    [newAction setActionType:actionPlayThisLevel];
    [newAction setLevelID:levelID];
    return newAction;
}

- (signActionType) getActionType {
    return _action;
}

- (levelPack) getPack {
    if (_action == actionNextHill) {
        [SquidLog warn:@"In actionNextHill, why do you need the pack?"];
    }
    return _pack;
}

- (int) getLevelID {
    return _levelID;
}

- (void) setActionType:(signActionType)action {
    _action = action;
}

- (void) setPack:(levelPack)pack {
    _pack = pack;
}

- (void) setLevelID:(int)levelID {
    _levelID = levelID;
    levelGroup group = [LevelManager getParentOfLevel:levelID];
    [self setPack:[LevelManager getParentOfGroup:group]];
}

@end
