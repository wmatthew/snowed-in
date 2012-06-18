//
//  BoxStorageLevels.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/28/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "SquidStorageLevels.h"
#import "LevelManager.h"
#import "HUD_Generic.h"
#import "HintEnums.h"

@interface BoxStorageLevels : SquidStorageLevels {}

+ (int) getFirstLevelID;
+ (void) addInDefaults;

+ (float) getZoom:(float)defaultZoom;
+ (void) setZoom:(float)zoom;

+ (hintType) getHintLevel:(int)levelID;
+ (void) setHintLevel:(hintType)hintLevel forLevel:(int)levelID;

+ (NSString*) getUndoLog:(int)levelID;
+ (void) setUndoLog:(NSString*)progress forLevel:(int)levelID;
+ (NSString*) getRedoLog:(int)levelID;
+ (void) setRedoLog:(NSString*)progress forLevel:(int)levelID;

+ (levelGroup) getCurrentLevelGroup;
+ (void) setCurrentLevelGroup:(levelGroup)newLevelGroup;

+ (levelPack) getCurrentLevelPack;
+ (void) setCurrentLevelPack:(levelPack)newLevelPack;

@end
