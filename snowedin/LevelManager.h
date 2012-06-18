//
//  LevelManager.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/31/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum {
    packHowToPlay,
    packHowToInvert,
    packHill1,
    packHill2,
    packHill3,
    packHill4,
    packHill5,
    packHill6,
} levelPack;

typedef enum {
    groupIntro,
    groupInvert1,
    groupInvert2,
    groupB,
    groupC,
    groupD,
    groupE,
    groupF,
    groupG,
    groupH,
    groupI,
    groupJ,
    groupK,
    groupL,
    groupM,
    groupN,
    groupO,
    groupP,
    groupQ,
    groupR,
    groupS,
    groupT,
    groupU,
    groupV,
    groupW,
    groupX,
} levelGroup;

@interface LevelManager : NSObject {}

+ (NSArray*) getAllPacks;
+ (NSArray*) getAllLevelGroups;
+ (int) getCompletedLevelsOverall;
+ (int) getTotalNumberOfLevelsOverall;

// Things to do with a pack
+ (NSArray*) getLevelGroupsInPack:(levelPack)pack;
+ (int) getTotalNumberOfLevelsInPack:(levelPack)pack;
+ (int) getCompletedLevelsInPack:(levelPack)pack;
+ (NSNumber*) getFirstPlayableLevelInPack:(levelPack)pack;
+ (bool) areAllLevelsLockedInPack:(levelPack) pack;

// Things to do with a level group
+ (bool) isTutorialGroup:(levelGroup)group;
+ (int) getCompletedLevelsInGroup:(levelGroup)group;
+ (int) getLevelGroupSizeRoot:(levelGroup)group;
+ (NSString*) getPackDisplayTitle:(levelPack)pack;
+ (NSString*) getGroupDisplayTitle:(levelGroup)group;
+ (NSArray*) getLevelsIn:(levelGroup)group;
+ (levelPack) getParentOfGroup:(levelGroup)group;
+ (NSNumber*) getFirstPlayableLevelInGroup:(levelGroup)group;
+ (bool) areAllLevelsLockedInGroup:(levelGroup) group;

// Things to do with a level
+ (void) officiallyRecordWin;
+ (void) tryToUnlockIndex:(int)indexInCurrentPack;
+ (void) tryToUnlockLevel:(int)levelID;
+ (levelGroup) getParentOfLevel:(int)levelID;

// Error checking
+ (void) checkAllLevels;

+ (bool) getDidShowWinScreen;
+ (void) setDidShowWinScreen:(bool)didShow;

@end
