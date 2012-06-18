//
//  BoxLevel.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/27/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "BoxLevel.h"
#import "cocos2d.h"
#import "SquidLog.h"
#import "VecUtil.h"
#import "BoxStorageLevels.h"

@implementation BoxLevel

static NSString *ROW_DELIM;
static NSString *KEY_TITLE = @"Title";
static NSString *KEY_LEVEL = @"Level";
static NSString *KEY_TEXT1 = @"Text1";
static NSString *KEY_TEXT2 = @"Text2";
static NSString *KEY_PAR   = @"Par";
static NSString *KEY_BEST  = @"Best";
static NSString *KEY_HARD  = @"Hard";

// Fields
static NSArray *_fieldKeys;
static NSMutableDictionary *_parsedFields;

// Tiles/Map
static NSMutableDictionary *_tileDictionary;
static NSArray *_rows;
static int _width;
static int _height;

// Special tiles
NSMutableArray *_inverters;
static CGPoint _goalPos;

static int _levelID;


+ (void) initialize {
    ROW_DELIM = @"\n";
    _tileDictionary = [[NSMutableDictionary alloc] init];
    [_tileDictionary setObject:[NSNumber numberWithInt:tileEmpty]     forKey:@" "]; // TODO: remove?
    [_tileDictionary setObject:[NSNumber numberWithInt:tileEmpty]     forKey:@"_"];
    [_tileDictionary setObject:[NSNumber numberWithInt:tileBlock]     forKey:@"."];
    [_tileDictionary setObject:[NSNumber numberWithInt:tileAvatar]    forKey:@"A"];
    [_tileDictionary setObject:[NSNumber numberWithInt:tileInverter]  forKey:@"@"];
    [_tileDictionary setObject:[NSNumber numberWithInt:tileEmptyGoal] forKey:@"B"];
    [_tileDictionary setObject:[NSNumber numberWithInt:tileBlockGoal] forKey:@"b"];
    [_tileDictionary setObject:[NSNumber numberWithInt:tileWall]      forKey:@"X"];
    
    _fieldKeys = [[NSArray arrayWithObjects:
                  KEY_TITLE,
                  KEY_LEVEL,
                  KEY_TEXT1,
                  KEY_TEXT2,
                  KEY_PAR,
                  KEY_BEST,
                  KEY_HARD,
               nil] retain];
}

+ (void) loadLevel:(int)levelID {
    
    [SquidLog debug:@"Loading level %i", levelID];
    [self clearLevel];

    _levelID = levelID;
    NSString *levelData = [self readLevelFile];
    levelData = [levelData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    levelData = [levelData stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if (levelData == nil) {
        [SquidLog error:@"Error, could not find level %03i", levelID];
        return;
    }
    
    if (![levelData hasPrefix:@"###"]) {
        [SquidLog error:@"Level %i malformed.", _levelID];
    }

    [self parseNewFormat:levelData];
}

+ (void) parseNewFormat:(NSString*)levelData {
    
    if (![levelData hasSuffix:@"###"]) {
        [SquidLog warn:@"Level %i doesn't end with ###; it ends with '%@'", _levelID, [levelData substringFromIndex:[levelData length]-5]];
    }
    
    NSArray *allLevelLines = [levelData componentsSeparatedByString:@"\n"];
    
    // Parse all fields/comments
    for (NSString *line in allLevelLines) {
        for (NSString *field in _fieldKeys) {
            NSString *prefix = [NSString stringWithFormat:@"# %@:", field];
            if ([line hasPrefix:prefix]) {
                [_parsedFields setObject:[[line stringByReplacingOccurrencesOfString:prefix withString:@""] 
                                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                  forKey:field];
            }
        }
    }

    // Parse the level map
    NSMutableArray *levelRowsClean = [NSMutableArray array];
    for (NSString *line in allLevelLines) {
        if ([line hasPrefix:@"|"]) {
            [levelRowsClean addObject:[line stringByReplacingOccurrencesOfString:@"|" withString:@""]];
        }
    }
    _rows = [NSArray arrayWithArray:levelRowsClean];

    [self unpackSpecString];
    [self sanityCheckLevel];
}

+ (void) clearLevel {
    [_inverters release];
    _inverters = [[NSMutableArray array] retain];

    [_parsedFields release];
    _parsedFields = [[NSMutableDictionary dictionary] retain];
    
    _levelID = -1;
    _goalPos = ccp(-99,-99); // TODO: find a better way to do this.
}

// Does not check if solution works; just if it's the right format.
+ (bool) isValidSolutionFormat:(NSString*)solution {
    if (solution == nil || [solution length] < 1) {
        return NO;
    }
    
    if ([[solution stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"NEWSnews"]] length] > 0) {
        return NO;
    }

    return YES;
}

+ (NSString*) getTitle {
    return [_parsedFields objectForKey:KEY_TITLE];
}

+ (NSString*) getBestSolution {
    return [_parsedFields objectForKey:KEY_BEST];
}

+ (NSString*) getDifficulty {
    NSString *difficulty = [_parsedFields objectForKey:KEY_HARD];
    if (difficulty == nil) {
        [SquidLog error:@"no difficulty in level %i (%@)", _levelID, [self getTitle]];
        return nil;
    }
  
    int hard = [difficulty intValue];
    switch (hard) {
        case 0:
        case 1:
        case 2:
            return @"Easy";
        case 3:
            return @"Medium";
        case 4:
            return @"Hard";
        case 5:
            return @"Very Hard";
        case 6:
            return @"Very Very Hard";
        case 7:
        case 8:
        case 9:
        case 10:
            return @"Inconceivable";
        default:
            return @"";
    }
    return [_parsedFields objectForKey:KEY_HARD];
}

+ (NSString*) getParSolution {
    return [_parsedFields objectForKey:KEY_PAR];
}

+ (NSString*) getTutorialOne {
    return [_parsedFields objectForKey:KEY_TEXT1];
}

+ (NSString*) getTutorialTwo {
    return [_parsedFields objectForKey:KEY_TEXT2];
}

+ (NSString*) readLevelFile {
    NSString *fileName = [NSString stringWithFormat:@"Level%03i", _levelID];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *myData = [NSString stringWithContentsOfFile:filePath
                                                 encoding:NSStringEncodingConversionAllowLossy
                                                            error:nil];
    if (myData) {
        [SquidLog debug:@"Read file data: \n%@", myData];
        return myData;
    } else {
        [SquidLog error:@"Error, couldn't read level file: %@", fileName];
        return nil;
    }
}

+ (void) unpackSpecString {
    _height = [_rows count];
    _width = 1;
    for (NSString *row in _rows) {
        _width = MAX(_width, [row length]);
    }
    
    // This is done to locate goal position. TODO: find a better way.
    for (int i=0; i<_width; i++) {
        for (int j=0; j<_height; j++) {
            [self getBasicTypeAt:ccp(i,j)];
        }
    }
    
    [SquidLog debug:@"Level size: %i,%i", _width, _height];

}

+ (void) sanityCheckLevel {
    
    // level id checks out?
    NSString *parsedLevelID = [_parsedFields objectForKey:KEY_LEVEL];
    if (parsedLevelID == nil ||
        ![parsedLevelID isEqualToString:[NSString stringWithFormat:@"%03i", _levelID]]) {
        [SquidLog error:@"Level ID mismatch: %03i vs %@", _levelID, parsedLevelID];
    }

    // has exactly one avatar, and exactly one goal?
    int avatarCount = 0;
    int goalCount = 0;
    for (int i=0; i<_width; i++) {
        for (int j=0; j<_height; j++) {
            tileType tile = [self getActualTypeAt:ccp(i,j)];
            if ([TileManager isAvatarTile:tile]) {
                avatarCount++;
            }
            if ([TileManager isGoalTile:tile]) {
                goalCount++;
            }
        }
    }
    if (avatarCount != 1) {
        [SquidLog error:@"Level has not 1 avatar, but %i: (level %i)", avatarCount, _levelID];
    }
    if (goalCount != 1) {
        [SquidLog error:@"Level has not 1 goal, but %i", goalCount];
    }
    
    // Has the goal been properly set?
    if (_goalPos.x < 0 || _goalPos.y < 0) {
        [SquidLog error:@"Invalid goal."];
    }
    
    // Has optimal solution and par solution?
    if (![self isValidSolutionFormat:[self getBestSolution]]) {
        [SquidLog warn:@"Invalid best solution for level %03i: %@", _levelID, [self getBestSolution]];
    }

    if (![self isValidSolutionFormat:[self getParSolution]]) {
        [SquidLog warn:@"Invalid par solution for level %03i: %@", _levelID, [self getParSolution]];
    }

    // Par should be 2+ longer than best known solution.
    if ([[self getBestSolution] isEqualToString:[self getParSolution]]) {
        [SquidLog warn:@"%@ (level %i): par = best = %@", [self getTitle], _levelID, [self getParSolution]];
    } else {
        int bestLength = [[self getBestSolution] length];
        int parLength = [[self getParSolution] length];
        if (parLength < bestLength + 2) {
            [SquidLog warn:@"Bad par length on %@ (level %i): par=%i; best=%i", [self getTitle], _levelID, parLength, bestLength];
        }
    }    

    // has title?
    NSString *title = [self getTitle];
    if (title == nil || [title length] < 1) {
        [SquidLog error:@"invalid level title: %@", title];
    } else if ([title length] < 3) {
        [SquidLog warn:@"Level %i title suspiciously short: %@", _levelID, title];
    } else if ([title length] > 15) {
        [SquidLog warn:@"Level %i title suspiciously long: %@", _levelID, title];
    }
    
    // Has difficulty, with value in range?
    NSString *difficulty = [_parsedFields objectForKey:KEY_HARD];
    if (difficulty == nil) {
        [SquidLog error:@"no difficulty in level %i (%@)", _levelID, [self getTitle]];
    } else {
        int hard = [difficulty intValue];
        if (hard < 0 || hard > 10) {
            [SquidLog error:@"difficulty %@ out of range on level %i (%@)", difficulty, _levelID, [self getTitle]];
        }
    }
    
    bool isTutorialLevel = [LevelManager isTutorialGroup:[LevelManager getParentOfLevel:_levelID]];
    if (isTutorialLevel) {
        if ([self getTutorialOne] == nil || [self getTutorialTwo] == nil) {
            [SquidLog warn:@"Tutorial level; tutorial text is not present"];
        }
    } else {
        if ([self getTutorialOne] != nil || [self getTutorialTwo] != nil) {
            [SquidLog warn:@"Non-tutorial level; tutorial text is present"];
        }    
    }
}

+ (CGPoint) getLevelSize {
    return ccp(_width, _height);
}

+ (tileType) getActualTypeAt:(CGPoint)gridPos {
    tileType basicType = [self getBasicTypeAt:gridPos];
    bool isGoal = [self isGoalPos:gridPos];
    bool isInverter = [self isInvertPos:gridPos];

    if (isGoal && isInverter) {
        [SquidLog error:@"Invalid tile: both goal and inverter."];
        return tileEmpty;
    }

    if (isGoal) {
        switch (basicType) {
            case tileEmpty:
                return tileEmptyGoal;
            case tileBlock:
                return tileBlockGoal;
            case tileAvatar:
                return tileAvatarGoal;
            default:
                [SquidLog error:@"Invalid tile: invalid goal."];                
        }
    }
    
    if (isInverter) {
        switch (basicType) {
            case tileInverter:
                return tileInverter;
            case tileAvatar:
                return tileAvatarInverter;
            default:
                [SquidLog error:@"Invalid tile: invalid inverter."];                
        }
    }
    
    switch (basicType) {
        case tileEmpty:
        case tileBlock:
        case tileWall:
        case tileAvatar:
            return basicType;
        default:
            [SquidLog error:@"Invalid tile: invalid inverter."];                
    }
    
    return tileEmpty;
}


// Deprecated
+ (tileType) getBasicTypeAt:(CGPoint)gridPos {
    // Sanity check, make sure these are integers and in bounds
    if (![VecUtil isExactGridPos:gridPos]) {
        [SquidLog error:@"BoxLevel: not a gridPos: (%f, %f)", gridPos.x, gridPos.y];
    }
    
    NSString *row = [_rows objectAtIndex:gridPos.y];
    NSRange range = {gridPos.x,1};
    NSString *letter = [row substringWithRange:range];
        
    if ([letter isEqualToString: @"@"]) {
        [_inverters addObject:[GridLogicManager convertToKey:gridPos]];
        return tileInverter;
    } else if ([letter isEqualToString: @"B"]) {
        _goalPos = gridPos;
        return tileEmpty;
    } else if ([letter isEqualToString: @"b"]) {
         // Lower case = covered by block
        _goalPos = gridPos;
        return tileBlock;
    }

    if ([_tileDictionary objectForKey:letter]) {
        return [[_tileDictionary objectForKey:letter] intValue];
    }

    [SquidLog error:@"Unknown tile [%@]; default to tileEmpty.", letter];
    return tileEmpty;
}

+ (bool) isGoalPos:(CGPoint)gridPos {
    return _goalPos.x == gridPos.x && _goalPos.y == gridPos.y;
}

+ (bool) isInvertPos:(CGPoint)gridPos {
    return [_inverters containsObject:[GridLogicManager convertToKey:gridPos]];
}

+ (NSString*) convertTileTypeToString:(tileType)type {
    NSArray *keys = [_tileDictionary allKeysForObject:[NSNumber numberWithInt:type]];
    if ([keys count] == 0) {
        [SquidLog error:@"No keys for tile type %i", type];
    }
    return [keys objectAtIndex:0];
}

+ (NSString*) outputNewFormat {
    NSString *output = @"###\n";
    output = [output stringByAppendingString:[NSString stringWithFormat:@"# Title: %@\n", [self getTitle]]];
    output = [output stringByAppendingString:[NSString stringWithFormat:@"# Level: %@\n", [NSString stringWithFormat:@"%03i", _levelID]]];
    if ([self getTutorialOne] != nil) {
        output = [output stringByAppendingString:[NSString stringWithFormat:@"# Text1: %@\n", [self getTutorialOne]]];
    }
    if ([self getTutorialTwo] != nil) {
        output = [output stringByAppendingString:[NSString stringWithFormat:@"# Text2: %@\n", [self getTutorialTwo]]];
    }

    output = [output stringByAppendingString:@"# ~ Comments ~\n"];
    NSString *_comments = @"# Note, comments were not retained!";
    output = [output stringByAppendingString:[NSString stringWithFormat:@"%@\n", (_comments == nil) ? @"#" : _comments ]];

    for (int j=0; j<_height; j++) {
        NSString *row = @"";
        for (int i=0; i<_width; i++) {
            CGPoint pos = ccp(i,j);
            tileType type = [self getActualTypeAt:pos];            
            row = [row stringByAppendingString:[self convertTileTypeToString:type]];
        }
        output = [output stringByAppendingString:[NSString stringWithFormat:@"|%@|\n", row]];        
    }

    output = [output stringByAppendingString:[NSString stringWithFormat:@"# Par:   %@\n", [self getParSolution]]];
    output = [output stringByAppendingString:[NSString stringWithFormat:@"# Best:  %@\n", [self getBestSolution]]];
    output = [output stringByAppendingString:@"###\n"];

    return output;
}

@end
