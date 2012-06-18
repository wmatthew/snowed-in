//
//  BoxStorageLevels.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/28/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "BoxStorageLevels.h"
#import "boxpusher.h"

NSString *STORAGE_ZOOM = @"zoom";
NSString *STORAGE_LEVEL_HINT_SEEN = @"maxhint";

NSString *STORAGE_LEVEL_UNDO_LOG = @"undolog";
NSString *STORAGE_LEVEL_REDO_LOG = @"redolog";
NSString *EMPTY_LOG = @"";
static levelGroup _currentLevelGroup;
static levelPack _currentLevelPack;

@implementation BoxStorageLevels

+ (void) initialize {
    [self addInDefaults];
}

+ (void) addInDefaults {
    [super addInDefaults];
    _currentLevelPack = packHowToPlay;
}

+ (int) getFirstLevelID {
    NSNumber *firstLev = [[LevelManager getLevelsIn:groupIntro] objectAtIndex:0];
    return [firstLev intValue];
}

//===================================================================================================
+ (float) getZoom:(float)defaultZoom {
    NSNumber *value = (NSNumber*)[self getValueForKey:STORAGE_ZOOM];
    return value ? [value floatValue] : defaultZoom;
}

+ (void) setZoom:(float)zoom {
    [self setValue:[NSNumber numberWithFloat:zoom] forKey:STORAGE_ZOOM];
}

//===================================================================================================
// Max hint level seen so far
+ (hintType) getHintLevel:(int)levelID {
    NSNumber *value = (NSNumber*)[self getValueForKey:STORAGE_LEVEL_HINT_SEEN withNum:levelID];
    [SquidLog debug:@"Get hint level: %i (level %i)", [value intValue], levelID];
    return value ? (hintType)[value intValue] : hintNone;
}

+ (void) setHintLevel:(hintType)hintLevel forLevel:(int)levelID {
    [SquidLog debug:@"Set hint level: %i (level %i)", hintLevel, levelID];
    [self setValue:[NSNumber numberWithInt:hintLevel] forKey:STORAGE_LEVEL_HINT_SEEN withNum:levelID];
}

//===================================================================================================
// Undo Log
+ (NSString*) getUndoLog:(int)levelID {
    NSString *value = (NSString*)[self getValueForKey:STORAGE_LEVEL_UNDO_LOG withNum:levelID];
    return value ? value : EMPTY_LOG;
}

+ (void) setUndoLog:(NSString*)progress forLevel:(int)levelID {
    [self setValue:progress forKey:STORAGE_LEVEL_UNDO_LOG withNum:levelID];
}

//===================================================================================================
// Redo Log
+ (NSString*) getRedoLog:(int)levelID {
    NSString *value = (NSString*)[self getValueForKey:STORAGE_LEVEL_REDO_LOG withNum:levelID];
    return value ? value : EMPTY_LOG;
}

+ (void) setRedoLog:(NSString*)progress forLevel:(int)levelID {
    [self setValue:progress forKey:STORAGE_LEVEL_REDO_LOG withNum:levelID];
}

//===================================================================================================
// Level Pack
+ (levelGroup) getCurrentLevelGroup {
    return _currentLevelGroup;
}

+ (void) setCurrentLevelGroup:(levelGroup)levelGroup {
    // not persisted currently.
    _currentLevelGroup = levelGroup;
}

//===================================================================================================
// Current Level
+ (void) setCurrentLevelID:(int)levelID {
    [super setCurrentLevelID:levelID];
    [self setCurrentLevelGroup:[LevelManager getParentOfLevel:levelID]];
}

//===================================================================================================
// Level Pack
// Note- this is only used for positioning the main menu screen and may or may not be the parent pack of the current level.
+ (levelPack) getCurrentLevelPack {
    return _currentLevelPack;
}

// Note- this is only used for positioning the main menu screen and may or may not be the parent pack of the current level.
+ (void) setCurrentLevelPack:(levelPack)levelPack {
    // not persisted currently.
    _currentLevelPack = levelPack;
}

@end
