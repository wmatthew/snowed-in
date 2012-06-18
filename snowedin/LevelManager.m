//
//  LevelManager.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/31/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "LevelManager.h"
#import "boxpusher.h"

#import "SquidLog.h"

@implementation LevelManager

static bool _didErrorCheckAllLevels;
static bool _didShowWinScreen;

+ (void) initialize {
    _didErrorCheckAllLevels = NO;
    _didShowWinScreen = NO;
}

+ (void) officiallyRecordWin {
    int currentLevel = [BoxStorageLevels getCurrentLevelID];

    // Record the win
    [SquidLog info:@"Recording win for %@ (level %i)", [BoxLevel getTitle], currentLevel];
    [BoxStorageLevels setLevelState:LEVEL_FINISHED forLevel:currentLevel];
    
    // Unlock the next level
    NSArray *group = [self getLevelsIn:[BoxStorageLevels getCurrentLevelGroup]];
    int index = [group indexOfObject:[NSNumber numberWithInt:currentLevel]];
    int edge = [self getLevelGroupSizeRoot:[BoxStorageLevels getCurrentLevelGroup]];
    
    if (index % edge != 0) {
        [self tryToUnlockIndex:index-1]; // Left
    }
    if ((index+1) % edge != 0) {
        [self tryToUnlockIndex:index+1]; // Right
    }
    [self tryToUnlockIndex:index+edge]; // Down
    [self tryToUnlockIndex:index-edge]; // Up
    
    // If user just finished last level in a group
    if (index == [group count] -1) {

        levelGroup parentGroup = [LevelManager getParentOfLevel:currentLevel];
        NSArray *allGroupsInOrder = [LevelManager getAllLevelGroups];
        int groupIndex = [allGroupsInOrder indexOfObject:[NSNumber numberWithInt:parentGroup]];

        // Unlock next two levels.
        for (int nextIndex = groupIndex + 1; nextIndex < [allGroupsInOrder count] && nextIndex <= groupIndex + 2; nextIndex++) {
            levelGroup nextGroup = [[allGroupsInOrder objectAtIndex:nextIndex] intValue];
            levelPack nextParent = [LevelManager getParentOfGroup:nextGroup];

            int nextGroupsFirstLevelID = [[[self getLevelsIn:nextGroup] objectAtIndex:0] intValue];
            
            if ([[BoxProduct getProductFromPack:nextParent] didUserBuyMe]) {
                [SquidLog info:@"Auto-unlocking level %i", nextGroupsFirstLevelID];
                [self tryToUnlockLevel:nextGroupsFirstLevelID];    
            } else {
                [SquidLog info:@"Not going to unlock level %i; it's an unpurchased pack", nextGroupsFirstLevelID];
            }
        }
    }
}

+ (void) tryToUnlockIndex:(int)indexInCurrentGroup {
    NSArray *group = [self getLevelsIn:[BoxStorageLevels getCurrentLevelGroup]];
    if (indexInCurrentGroup >= [group count] || indexInCurrentGroup < 0) {
        [SquidLog debug:@"Can't unlock next level; out of bounds."];    
        return;
    }
    
    NSNumber *next = [group objectAtIndex:indexInCurrentGroup];
    if (next != nil) {
        [self tryToUnlockLevel:[next intValue]];
    } else {
        [SquidLog error:@"Can't unlock next level; it's nil. Unexpected."];
    }
}

+ (void) tryToUnlockLevel:(int)levelID {
    if ([BoxStorageLevels getLevelState:levelID] == LEVEL_LOCKED) {
        [SquidLog info:@"Unlocking level %i", levelID];
        [BoxStorageLevels setLevelState:LEVEL_READY forLevel:levelID]; 
    }    
}

+ (NSArray*) getAllPacks {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:packHowToPlay],
            [NSNumber numberWithInt:packHowToInvert],
            [NSNumber numberWithInt:packHill1],
            [NSNumber numberWithInt:packHill2],
            [NSNumber numberWithInt:packHill3],
            [NSNumber numberWithInt:packHill4],
            [NSNumber numberWithInt:packHill5],
            [NSNumber numberWithInt:packHill6],
            nil];
}

+ (NSArray*) getAllLevelGroups {
    NSMutableArray *allGroups = [NSMutableArray array];
    for (NSNumber *pack in [self getAllPacks]) {
        [allGroups addObjectsFromArray:[self getLevelGroupsInPack:[pack intValue]]];
    }
    
    return allGroups;
}

+ (bool) isTutorialGroup:(levelGroup)group {
    levelPack parentPack = [LevelManager getParentOfGroup:group];
    return (parentPack == packHowToPlay || parentPack == packHowToInvert);
}

+ (NSArray*) getLevelGroupsInPack:(levelPack)page {
    switch (page) {
        case packHowToPlay:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupIntro],
                    nil];
        case packHowToInvert:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupInvert1],
                    [NSNumber numberWithInt:groupInvert2],
                    nil];
        case packHill1:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupB],
                    nil];
        case packHill2:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupC],
                    nil];
        case packHill3:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupD],
                    [NSNumber numberWithInt:groupE],
                    nil];
        case packHill4:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupF],
                    [NSNumber numberWithInt:groupG],
                    [NSNumber numberWithInt:groupH],
                    nil];
        case packHill5:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupI],
                    [NSNumber numberWithInt:groupJ],
                    [NSNumber numberWithInt:groupK],
                    [NSNumber numberWithInt:groupL],
                    [NSNumber numberWithInt:groupM],
                    [NSNumber numberWithInt:groupN],
                    [NSNumber numberWithInt:groupO],
                    [NSNumber numberWithInt:groupP],
                    nil];
        case packHill6:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:groupQ],
                    [NSNumber numberWithInt:groupR],
                    [NSNumber numberWithInt:groupS],
                    [NSNumber numberWithInt:groupT],
                    [NSNumber numberWithInt:groupU],
                    [NSNumber numberWithInt:groupV],
                    [NSNumber numberWithInt:groupW],
                    [NSNumber numberWithInt:groupX],
                    nil];            
    }
    [SquidLog error:@"Unknown level page: %i", page];
    return nil;
}

+ (int) getTotalNumberOfLevelsInPack:(levelPack)pack {
    int sum = 0;
    for (NSNumber *groupNum in [LevelManager getLevelGroupsInPack:pack]) {
        levelGroup group = [groupNum intValue];
        sum += [[LevelManager getLevelsIn:group] count];
    }
    return sum;
}

+ (int) getCompletedLevelsInGroup:(levelGroup)group {
    int sum = 0;
    for (NSNumber *levelNum in [LevelManager getLevelsIn:group]) {
        int state = [BoxStorageLevels getLevelState:[levelNum intValue]];
        if (state >= LEVEL_FINISHED) {
            sum += 1;
        }
    }
    return sum;
}

+ (int) getCompletedLevelsInPack:(levelPack)pack {
    int sum = 0;
    for (NSNumber *groupNum in [LevelManager getLevelGroupsInPack:pack]) {
        levelGroup group = [groupNum intValue];
        sum += [self getCompletedLevelsInGroup:group];
    }
    return sum;
}

+ (int) getCompletedLevelsOverall {
    bool HACK_PRETEND_ALL_LEVELS_ARE_COMPLETED = NO;
    if (HACK_PRETEND_ALL_LEVELS_ARE_COMPLETED) {
        return [self getTotalNumberOfLevelsOverall];
    }
    
    int numCompleted = 0;
    for (NSNumber *packNum in [LevelManager getAllPacks]) {
        numCompleted += [LevelManager getCompletedLevelsInPack:[packNum intValue]];
    }    
    return numCompleted;
}

+ (int) getTotalNumberOfLevelsOverall {
    int numCompleted = 0;
    for (NSNumber *packNum in [LevelManager getAllPacks]) {
        numCompleted += [LevelManager getTotalNumberOfLevelsInPack:[packNum intValue]];
    }    
    return numCompleted;    
}

+ (NSString*) getPackDisplayTitle:(levelPack)pack {
    switch (pack) {
        case packHowToPlay:
            return @"How to Play"; 
        case packHowToInvert:
            return @"Inverting";
        case packHill1:
            return @"First Hill";
        case packHill2:
            return @"Second Hill";
        case packHill3:
            return @"Third Hill";
        case packHill4:
            return @"Fourth Hill";
        case packHill5:
            return @"Fifth Hill";
        case packHill6:
            return @"Sixth Hill";
        default:
            return @"";
    }
}

+ (NSString*) getGroupDisplayTitle:(levelGroup)group {
    // Possible naming convention:
    // http://en.wikipedia.org/wiki/List_of_U.S._states_by_date_of_statehood
    
    switch (group) {
        case groupIntro:
            return @"How To Play";
        case groupInvert1:
            return @"Invert 1";
        case groupInvert2:
            return @"Invert 2";
        case groupB:
            return @"B";
        case groupC:
            return @"C";
        case groupD:
            return @"D";
        case groupE:
            return @"E";
        case groupF:
            return @"F";
        case groupG:
            return @"G";
        case groupH:
            return @"H";
        case groupI:
            return @"I";
        case groupJ:
            return @"J";
        case groupK:
            return @"K";
        case groupL:
            return @"L";
        case groupM:
            return @"M";
        case groupN:
            return @"N";
        case groupO:
            return @"O";
        case groupP:
            return @"P";
        case groupQ:
            return @"Q";
        case groupR:
            return @"R";
        case groupS:
            return @"S";
        case groupT:
            return @"T";
        case groupU:
            return @"U";
        case groupV:
            return @"V";
        case groupW:
            return @"W";
        case groupX:
            return @"X";
        default:
            [SquidLog warn:@"getGroupDisplayTitle: group not recognized"];
            return @"?";    
    }
}

// Difficulty Ranking
// 0 very easy, player can't lose
// 2 easy - few moves, no tricks
// 4 med - some minor trick
// 6 hard - several tricks
// 8 very hard - :O

+ (NSArray*) getLevelsIn:(levelGroup)group {
    switch (group) {
        case groupIntro:
            return [NSArray arrayWithObjects:
                    // Intro Levels
                    [NSNumber numberWithInt:101], // 0 Moving
                    [NSNumber numberWithInt:102], // 0 Pushing
                    [NSNumber numberWithInt:103], // 0 Navigating
                    [NSNumber numberWithInt:104], // 0 Inverting
                    nil];
        case groupInvert1:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:105], // 
                    [NSNumber numberWithInt:106], // 
                    [NSNumber numberWithInt:107], // 
                    [NSNumber numberWithInt:108], // 
                    nil];
        case groupInvert2:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:109], // 
                    [NSNumber numberWithInt:110], // 
                    [NSNumber numberWithInt:111], // 
                    [NSNumber numberWithInt:112], // 
                    nil];
            
        //========================================================================
        // First Hill
        case groupB:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:12], // 0 Kitten
                    [NSNumber numberWithInt:79], // 2 Pinwheel
                    [NSNumber numberWithInt:80], // 2 Link
                    [NSNumber numberWithInt:77], // 1 Phaser
                    nil];
        
        //========================================================================
        // Second Hill
        case groupC:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:78], // 1 Sink
                    [NSNumber numberWithInt:24], // 2 Thick                    
                    [NSNumber numberWithInt:84], // 2 Intestine
                    [NSNumber numberWithInt:81], // 3 Belfry
                    nil];
            
        //========================================================================
        // Third Hill
        case groupD:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:35], // 3 Boxed
                    [NSNumber numberWithInt:42], // 3 Cube
                    [NSNumber numberWithInt:26], // 4 Bishop // cool. keep separate from squid.
                    [NSNumber numberWithInt:16], // 4 Hand
                    nil];
        case groupE:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:2],  // 3 Scarlet
                    [NSNumber numberWithInt:17], // 4 Sandwich
                    [NSNumber numberWithInt:64], // 5 Valves
                    [NSNumber numberWithInt:94], // 5 Spinner // cool, but long
                    nil];
        
        //========================================================================
        // Fourth Hill
        case groupF:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:28], // 2 Tic // paid
                    [NSNumber numberWithInt:4],  // 4 Circle // cool, small
                    [NSNumber numberWithInt:25], // 4 Tour // so cool
                    [NSNumber numberWithInt:73], // 5 Centipede
                    nil];
        case groupG:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:29], // 2 Tac // paid
                    [NSNumber numberWithInt:3],  // 4 Coda // cool
                    [NSNumber numberWithInt:31], // 5 Goldfish // awesome level
                    [NSNumber numberWithInt:48], // 5 Macaroni // cool
                    nil];
        case groupH:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:30], // 3 Toe // paid
                    [NSNumber numberWithInt:36], // 4 Quad // cool, tricky
                    [NSNumber numberWithInt:71], // 4 Origami // cool
                    [NSNumber numberWithInt:10], // 7 Cat // cool
                    nil];
            
        //========================================================================
        // Fifth Hill (Free or Paid)

        case groupI:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:22], // 4 Squid // start of paid pack
                    [NSNumber numberWithInt:32], // 4 Factory
                    [NSNumber numberWithInt:33], // 4 Springfield
                    [NSNumber numberWithInt:15], // 5 Check
                    nil];
        case groupJ:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:5],  // 4 Fort
                    [NSNumber numberWithInt:34], // 5 Boat                    
                    [NSNumber numberWithInt:8],  // 5 Snooze
                    [NSNumber numberWithInt:9],  // 5 Frost
                    nil];
        case groupK:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:37], // 3 Insect
                    [NSNumber numberWithInt:38], // 3 Science
                    [NSNumber numberWithInt:40], // 3 Nougat
                    [NSNumber numberWithInt:19], // 6 Zipper
                    nil];
        case groupL:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:52], // 3 Matchbook                    
                    [NSNumber numberWithInt:41], // 4 Spittoon
                    [NSNumber numberWithInt:39], // 4 Threshold
                    [NSNumber numberWithInt:44], // 4 Koch
                    nil];
        case groupM:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:46], // 4 Brookings
                    [NSNumber numberWithInt:47], // 5 Apollo
                    [NSNumber numberWithInt:45], // 5 Suitcase
                    [NSNumber numberWithInt:50], // 5 Twist
                    nil];
        case groupN:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:60], // 3 Pixie
                    [NSNumber numberWithInt:51], // 7 Inject
                    [NSNumber numberWithInt:93], // 6 Pirate
                    [NSNumber numberWithInt:49], // 7 Bender
                    nil];
        case groupO:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:58], // 3 Peas // (kind of cheap/easy/trivial)
                    [NSNumber numberWithInt:23], // 3 Thin
                    [NSNumber numberWithInt:14], // 4 Temple
                    [NSNumber numberWithInt:43], // 8 Metric
                    nil];
        case groupP:
            return [NSArray arrayWithObjects:                    
                    [NSNumber numberWithInt:61], // 3 Attic
                    [NSNumber numberWithInt:53], // 3 Skew
                    [NSNumber numberWithInt:57], // 6 Alamo
                    [NSNumber numberWithInt:72], // 7 Tornado // level pack 1: final level.
                    nil];
            
        //========================================================================
        // Sixth Hill (Paid)

        case groupQ:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:70], // 3 Pizza
                    [NSNumber numberWithInt:54], // 4 Stasis
                    [NSNumber numberWithInt:56], // 4 Bridge
                    [NSNumber numberWithInt:67], // 4 Science
                    nil];
        case groupR:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:6],  // 4 Buttress
                    [NSNumber numberWithInt:7],  // 6 Chameleon // cool
                    [NSNumber numberWithInt:88], // 7 Mining // cool
                    [NSNumber numberWithInt:65], // 7 Prion // pretty cool
                    nil];
        case groupS:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:1],  // 3 Cyclops
                    [NSNumber numberWithInt:66], // 6 Skyscraper
                    [NSNumber numberWithInt:69], // 6 Waltz
                    [NSNumber numberWithInt:18], // 6 Avalanche // save for paid pack.
                    nil];
        case groupT:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:83], // 3 Tag
                    [NSNumber numberWithInt:59], // 4 Teapot
                    [NSNumber numberWithInt:55], // 5 Oblique
                    [NSNumber numberWithInt:62], // 5 Geyser
                    nil];
        case groupU:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:13], // 3 Eagle
                    [NSNumber numberWithInt:75], // 4 Turtle
                    [NSNumber numberWithInt:68], // 5 Ventricle
                    [NSNumber numberWithInt:21], // 5 Lift
                    nil];
        case groupV:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:74], // 5 Catalyst
                    [NSNumber numberWithInt:76], // 5 Typhoon
                    [NSNumber numberWithInt:20], // 6 Industry
                    [NSNumber numberWithInt:85], // 6 Alien (long, slow, save for last level pack)
                    nil];
        case groupW:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:82], // 3 Gate
                    [NSNumber numberWithInt:91], // 4 Layers
                    [NSNumber numberWithInt:86], // 5 Chef
                    [NSNumber numberWithInt:95], // 7 Corrosion
                    nil];
        case groupX:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:87], // 4 Reflect
                    [NSNumber numberWithInt:11], // 5 Checkers // paid pack, slow
                    [NSNumber numberWithInt:89], // 5 Zest
                    [NSNumber numberWithInt:27], // 6 Partisan  // frustrating?
                    nil];

/***        
        case groupI:
            return [NSArray arrayWithObjects:
                    
                    [NSNumber numberWithInt:90], // 5 Mask
                    [NSNumber numberWithInt:92], // 6 New York
                    [NSNumber numberWithInt:63], // 8 Waterloo // final level in final level pack
                    nil];
     ***/       
            // Difficulty Ranking
            // 0 very easy, player can't lose
            // 2 easy - few moves, no tricks
            // 4 med - some minor trick
            // 6 hard - several tricks
            // 8 very hard - :O
    
    }
    [SquidLog error:@"Unknown level group: %i", group];
    return nil;
}

+ (int) getLevelGroupSizeRoot:(levelGroup)group {
    int size = [[self getLevelsIn:group] count];
    int root = floor(sqrt(size));

    if (root*root != size) {
        [SquidLog error:@"Level pack size is not a square number: %i", size];
    }
    
    return root;
}

+ (levelPack) getParentOfGroup:(levelGroup)group {
    bool foundParentYet = NO;
    levelPack parentPack;

    for (NSNumber *pack in [self getAllPacks]) {
        if ([[self getLevelGroupsInPack:[pack intValue]] containsObject:[NSNumber numberWithInt:group]]) {
            if (foundParentYet) {
                [SquidLog error:@"One group is in multiple packs. Group: %i", group];
            }
            parentPack = (levelPack)[pack intValue];
            foundParentYet = YES;
        }
    }
    if (!foundParentYet) {
        [SquidLog error:@"No parent pack for group: %i. Returning a random pack- bad!", group];    
        return packHowToPlay;
    } else {
        return parentPack;
    }
}


+ (levelGroup) getParentOfLevel:(int)levelID {
    BOOL foundParentYet = NO;
    levelGroup parentGroup;
    
    for (NSNumber *group in [self getAllLevelGroups]) {
        if ([[self getLevelsIn:[group intValue]] containsObject:[NSNumber numberWithInt:levelID]]) {
            if (foundParentYet) {
                [SquidLog error:@"One level is in multiple groups. Level: %i", levelID];
            }
            parentGroup = (levelGroup)[group intValue];
            foundParentYet = YES;
        }
    }
    if (!foundParentYet) {
        [SquidLog error:@"No parent group for level: %i. Returning a random group- bad", levelID];
        return groupIntro;
    } else {
        return parentGroup;
    }
}

+ (void) checkAllLevels {
    if (_didErrorCheckAllLevels) {
        // don't do more than once, no point.
        return;
    }

    for (NSNumber *group in [self getAllLevelGroups]) {
        for (NSNumber *level in [self getLevelsIn:[group intValue]]) {
            [BoxLevel loadLevel:[level intValue]];
        }
    }
    _didErrorCheckAllLevels = YES;
}

+ (NSNumber*) getFirstPlayableLevelInGroup:(levelGroup)group {
    for (NSNumber *levelNum in [LevelManager getLevelsIn:group]) {
        int state = [BoxStorageLevels getLevelState:[levelNum intValue]];
        if (state == LEVEL_READY) {
            return levelNum;
        }
    }
    return nil;
}

+ (NSNumber*) getFirstPlayableLevelInPack:(levelPack)pack {
    for (NSNumber *groupNum in [LevelManager getLevelGroupsInPack:pack]) {
        NSNumber *first = [self getFirstPlayableLevelInGroup:[groupNum intValue]];
        if (first != nil) {
            return first;
        }
    }
    return nil;
}

+ (bool) areAllLevelsLockedInGroup:(levelGroup)group  {
    for (NSNumber *levelNum in [LevelManager getLevelsIn:group]) {
        int state = [BoxStorageLevels getLevelState:[levelNum intValue]];
        if (state != LEVEL_LOCKED) {
            return NO;
        }
    }
    return YES;
}

+ (bool) areAllLevelsLockedInPack:(levelPack) pack {
    for (NSNumber *groupNum in [LevelManager getLevelGroupsInPack:pack]) {
        if ([self areAllLevelsLockedInGroup:[groupNum intValue]] == NO) {
            return NO;
        }
    }
    return YES;
}

+ (bool) getDidShowWinScreen {
    return _didShowWinScreen;
}

+ (void) setDidShowWinScreen:(bool)didShow {
    _didShowWinScreen = didShow;
}

@end
