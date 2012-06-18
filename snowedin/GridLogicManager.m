//
//  GridLogicManager.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "GridLogicManager.h"
#import "boxpusher.h"

@implementation GridLogicManager

static bool _isInverted;
static bool _didWin;
static NSMutableDictionary *_gridState; // Blocks and walls only.
Entity *_avatar; 
static NSString *_undoHistory;
static NSString *_redoHistory;

static int _originalUndoLength;
static bool _didAnyMoveYet;

NSString *EAST = @"e";
NSString *WEST = @"w";
NSString *NORTH = @"n";
NSString *SOUTH = @"s";

// Initialization
+ (void) reset {

    _didWin = NO;
    _isInverted = NO;
    _gridState = [[NSMutableDictionary dictionary] retain];

    CGPoint size = [BoxLevel getLevelSize];
    [SquidLog debug:@"GridLogic Reset. Size: %i, %i", (int)size.x, (int)size.y];
    for (int j=0; j<size.y; j++) {
        for (int i=0; i<size.x; i++) {
            CGPoint curPos = ccp(i,j);
            tileType curType = [BoxLevel getBasicTypeAt:curPos];
            if (curType == tileBlock) {
                [self addBlockAt:ccp(i,j) isInit:YES];
            } else if (curType == tileAvatar) {
                _avatar = [Entity makeAt:curPos withType:tileAvatar];
                [self addEntity:_avatar at:curPos];         
            } else if (curType == tileWall) {
                [self addEntity:[Entity makeAt:curPos withType:tileWall]
                             at:curPos];
            } else if (curType == tileInverter) {
                // Inverter
            } else {
                // Empty or goal.
            }
        }        
    }

    // HUD and history
    NSString *_undoHistTemp = [BoxStorageLevels getUndoLog:[BoxStorageLevels getCurrentLevelID]];
    NSString *_redoHistTemp = [BoxStorageLevels getRedoLog:[BoxStorageLevels getCurrentLevelID]];
    
    _undoHistory = @"";
    _redoHistory = [[NSString stringWithFormat:@"%@%@", _undoHistTemp, _redoHistTemp] retain];
    [SquidLog debug:@"Loaded History: [%@ - %@]", _undoHistTemp, _redoHistTemp];
    
    _originalUndoLength = [_undoHistTemp length];
    _didAnyMoveYet = NO;
    
    [self setInitialFacingDirection];

    [self updateHUD];
    [[HUD_Play getOldHUD] setOriginalUndoLength:_originalUndoLength];
}

// Don't face up if that's straight into a wall, duh.
+ (void) setInitialFacingDirection {
    
    if ([self isMoveAllowed:ccp(0,-1)]) {
        [[self getAvatar] rotateSpriteToward:ccp(0,-1) duration:0.0]; // Up

    } else if ([self isMoveAllowed:ccp(1,0)]) {
        [[self getAvatar] rotateSpriteToward:ccp(1,0) duration:0.0]; // Right
    
    } else if ([self isMoveAllowed:ccp(0,1)]) {
        [[self getAvatar] rotateSpriteToward:ccp(0,1) duration:0.0]; // Down
    
    } else if ([self isMoveAllowed:ccp(-1,0)]) {
        [[self getAvatar] rotateSpriteToward:ccp(-1,0) duration:0.0]; // Left
    
    } else {
        [SquidLog warn:@"setInitialFacingDirection: no moves are allowed! Defaulting to right."];
        [[self getAvatar] rotateSpriteToward:ccp(1,0) duration:0.0]; // Right
    }
}

+ (bool) didAnyMoveYet {
    return _didAnyMoveYet;
}

// Get the length of the undo log from when the level was loaded.
+ (int) getOriginalUndoLength {
    return _originalUndoLength;
}

+ (void) addBlockAt:(CGPoint)gridPos isInit:(bool)isInit {
    if ([self getEntityAt:gridPos]) {
        [SquidLog warn:@"Trying to add block, but something is there."];
        [self failGracefully];
        return;
    }

    [self addEntity:[Entity makeAt:gridPos withType:tileBlock] at:gridPos];
    if (!isInit) {
        [GridDisplayManager addEntity:[self getEntityAt:gridPos]];
    }
}

+ (void) addEntity:(Entity*)entity at:(CGPoint)gridPos {
    if (entity == nil) {
        [SquidLog warn:@"Trying to add nil entity at pos (%f,%f)", gridPos.x, gridPos.y];
        [self failGracefully];
        return;
    }

    if ([self getEntityAt:gridPos]) {
        [SquidLog warn:@"Trying to add entity where one already exists at (%f, %f)", gridPos.x, gridPos.y];
        [self failGracefully];
        return;
    }
    
    [_gridState setObject:entity forKey:[self convertToKey:gridPos]];
}

// Note: won't clear inverters.
+ (void) clearSpot:(CGPoint)gridPos {
    if (![self getEntityAt:gridPos]) {
        [SquidLog warn:@"Trying to clear spot, but nothing is there."];
        [self failGracefully];
        return;
    }
        
    [_gridState removeObjectForKey:[self convertToKey:gridPos]];
}

+ (void) executeUndo:(CGPoint)originalDirection pull:(bool)pullBlock {
    
    _didAnyMoveYet = YES;
    bool isOkayToContinue;

    CGPoint zeroForward = [_avatar getGridPosition];
    CGPoint oneForward = ccpAdd([_avatar getGridPosition], originalDirection);
    CGPoint oneBack = ccpSub([_avatar getGridPosition], originalDirection);
    
    // sanity checks
    if ([self getTypeAt:zeroForward] != tileAvatar) {
        [SquidLog warn:@"Undo failed. Nothing at avatar position."];
        [self failGracefully];
        return;
    } else if (pullBlock && [self getEntityAt:oneForward] == nil && ![BoxLevel isInvertPos:oneForward]) {
        [SquidLog warn:@"Undo failed. No block to pull."];
        [self failGracefully];
        return;
    }
    
    // invert (if necessary)
    if ([BoxLevel isInvertPos:zeroForward]) {
        [self invertAt:zeroForward];
    } else if (pullBlock && [BoxLevel isInvertPos:oneForward]) {
        [self invertAt:oneForward];
    }
    
    // do the move (after inversion, because this is an undo)
    if ([self getTypeAt:oneBack] == tileBlock) {
        // need to clear path for avatar- special case where user is backing out of inverter.
        [[self getEntityAt:oneBack] markForDeletion];
        [self clearSpot:oneBack];
    }
    isOkayToContinue = [self moveThingFrom:zeroForward to:oneBack undoing:YES pushOrPull:pullBlock];
    if (isOkayToContinue == NO) {return;}
    if (pullBlock) {
        tileType pulled = [self getTypeAt:oneForward];
        if (pulled == tileBlock) {
            isOkayToContinue = [self moveThingFrom:oneForward to:zeroForward undoing:YES pushOrPull:NO];
            if (isOkayToContinue == NO) {return;}
        } else if (pulled == tileEmpty && [BoxLevel isInvertPos:oneForward]) {
            [self addBlockAt:oneForward isInit:NO];
            isOkayToContinue = [self moveThingFrom:oneForward to:zeroForward undoing:YES pushOrPull:NO];
            if (isOkayToContinue == NO) {return;}
        } else {
            [SquidLog warn:@"Error, unexpected type pulling block on undo"];
            [self failGracefully];
        }
    }
    
    // Update history.
    NSString *recentMove = [_undoHistory substringFromIndex:[_undoHistory length] - 1];
    _undoHistory = [[_undoHistory substringToIndex:[_undoHistory length]-1] retain];
    _redoHistory = [[NSString stringWithFormat:@"%@%@", recentMove, _redoHistory] retain];
    [SquidLog debug:[NSString stringWithFormat:@"U History: %@ | %@", _undoHistory, _redoHistory]];
    [self updateHUD];
    [self persistLog];
}

+ (void) executeMove:(CGPoint)direction isRedo:(bool)isRedo {

    _didAnyMoveYet = YES;
    bool isOkayToContinue;

    CGPoint zeroForward = [_avatar getGridPosition];
    CGPoint oneForward = ccpAdd([_avatar getGridPosition], direction);
    CGPoint twoForward = ccpAdd(oneForward, direction);
    bool pushingBlock = [self getTypeAt:oneForward] == tileBlock;
    
    // Move
    if (pushingBlock) {
        if (rand()%2==0) {
            [BoxMusic tryToPlaySound:push1_sound];
        } else {
            [BoxMusic tryToPlaySound:push2_sound];
        }
        isOkayToContinue = [self moveThingFrom:oneForward to:twoForward undoing:NO pushOrPull:NO];
        if (isOkayToContinue == NO) {return;}
    }
    isOkayToContinue = [self moveThingFrom:zeroForward to:oneForward undoing:NO pushOrPull:pushingBlock];
    if (isOkayToContinue == NO) {return;}
    
    // Invert (if needed)
    if ([BoxLevel isInvertPos:oneForward]) {
        [self invertAt:oneForward];
    } else if (pushingBlock && [BoxLevel isInvertPos:twoForward]) {
        [self invertAt:twoForward];
    }

    // Detect Win
    if ([BoxLevel isGoalPos:oneForward]) {
        _didWin = YES;
        [BoxMusic tryToPlaySound:win_sound];
        [LevelManager officiallyRecordWin];
    }

    // Update history
    if (!isRedo) {
        _redoHistory = @"";
    }
    [self recordMove:direction pushed:pushingBlock];
    [self updateHUD];
    [self persistLog];
}

+ (void) updateHUD {
    [[HUD_Play getOldHUD] setHistoryOptions:[_undoHistory length] > 0
                                  redo:[_redoHistory length] > 0
                               undoAll:[_undoHistory length] > 1
                               redoAll:[_redoHistory length] > 1];
}

+ (void) recordMove:(CGPoint) direction pushed:(bool)pushedBlock {
    NSString *newPart = @"?";
    if (direction.x == 1) {
        newPart = EAST;
    } else if (direction.x == -1) {
        newPart = WEST;
    } else if (direction.y == 1) {
        newPart = SOUTH;
    } else if (direction.y == -1) {
        newPart = NORTH;
    } else {
        [SquidLog warn:@"Bad direction in recordMove"];
        [self failGracefully];
    }

    if (pushedBlock) {
        newPart = [newPart uppercaseString];
    }
    
    _undoHistory = [[NSString stringWithFormat:@"%@%@", _undoHistory, newPart] retain];
    [SquidLog debug:[NSString stringWithFormat:@"M History: %@ | %@", _undoHistory, _redoHistory]];
    
    if (_didWin) {
        if ([_undoHistory length] < [[BoxLevel getBestSolution] length]) {

            [SquidLog warn:@"  ===== NEW RECORD! ====="];
            [SquidLog warn:@"  Your solution is the best known solution for this %@ (level %i)! Record it !!!-> %@ <-!!!",
                [BoxLevel getTitle],
                [BoxStorageLevels getCurrentLevelID],
                _undoHistory
             ];
        } else {
            [SquidLog info:@"  %@", _undoHistory];
        }
        [SquidLog info:@"  Solution Lengths: Best(%i), Par(%i), Yours(%i)", [[BoxLevel getBestSolution] length], [[BoxLevel getParSolution] length], [_undoHistory length]];
    }
}

+ (bool) redoMove {
    if (!_redoHistory || [_redoHistory length] == 0) {
        [SquidLog debug:@"Nothing to redo"];
        return NO;
    }

    [BoxMusic tryToPlaySound:redo_sound];

    // Get move
    NSString *recentMove = [_redoHistory substringToIndex:1];
    CGPoint direction = [self convertToDirection:recentMove];
    
    // Update history.
    _redoHistory = [[_redoHistory substringFromIndex:1] retain];
    
    [self executeMove:direction isRedo:YES];
    
    //[SquidLog info:@"Redo. %@", _undoHistory];
    
    return YES;
}

// Returns if move was undone.
+ (bool) undoMove {
    if (!_undoHistory || [_undoHistory length] == 0) {
        [SquidLog debug:@"Nothing to undo"];
        return NO;
    }
    
    [BoxMusic tryToPlaySound:undo_sound];
    
    // Get recent move
    NSString *recentMove = [_undoHistory substringFromIndex:[_undoHistory length] - 1];
    CGPoint direction = [self convertToDirection:recentMove];
    bool pullBlock = [[recentMove uppercaseString] isEqualToString:recentMove];
    [self executeUndo:direction pull:pullBlock];
    return YES;
}

+ (CGPoint) convertToDirection:(NSString*)historyChar {
    if ([[historyChar lowercaseString] isEqualToString:EAST]) {
        return ccp(1,0);
    } else if ([[historyChar lowercaseString] isEqualToString:WEST]) {
        return ccp(-1,0);
    } else if ([[historyChar lowercaseString] isEqualToString:SOUTH]) {
        return  ccp(0,1);
    } else if ([[historyChar lowercaseString] isEqualToString:NORTH]) {
        return ccp(0,-1);
    } else {
        [SquidLog warn:@"Bad direction in convertToDirection: %@", historyChar];
        [self failGracefully];
    }
    return CGPointZero; // should never happen
}

// Return YES if success, NO if failure.
+ (bool) moveThingFrom:(CGPoint)oldGridPos to:(CGPoint)newGridPos undoing:(bool)isUndo pushOrPull:(bool)isPush {
    Entity *shouldBeNothing = [self getEntityAt:newGridPos];
    if (shouldBeNothing != nil) {
        [SquidLog warn:@"Found something at spot that should be empty: %f, %f", newGridPos.x, newGridPos.y];
        [self failGracefully];
        return NO;
    }
    
    Entity *thing = [self getEntityAt:oldGridPos];
    if (!thing) {
        [SquidLog warn:@"Trying to move thing, but thing is nil."];
        [self failGracefully];
        return NO;
    }
    
    [self clearSpot:oldGridPos];
    [self addEntity:thing at:newGridPos];    
    [thing moveToward:newGridPos isUndo:isUndo isPush:isPush];
    return YES;
}

+ (void) invertAt:(CGPoint)invertGridPos {

    _isInverted = !_isInverted;

    if (_isInverted) {
        [BoxMusic tryToPlaySound:invert1_sound];
    } else {
        [BoxMusic tryToPlaySound:invert2_sound];
    }
    
    // Change background tile color (including spots under blocks)
    [GridDisplayManager setInversion:_isInverted atPos:invertGridPos];
    
    // Change the blocks
    CGPoint size = [BoxLevel getLevelSize];
    for (int j=0; j<size.y; j++) {
        for (int i=0; i<size.x; i++) {
            CGPoint currentPos = ccp(i,j);
            tileType current = [self getTypeAt:currentPos];
            float delay = [GridDisplayManager getInversionDelay:invertGridPos targetPos:currentPos];
            if (current == tileEmpty && ![BoxLevel isInvertPos:currentPos]) {
                [self addBlockAt:currentPos isInit:NO];
                [[self getEntityAt:currentPos] getSprite].opacity = 0;
                float fullDelayTime = 0;
                float fullFadeTime = 0;
                if ([BoxLevel isGoalPos:currentPos]) {
                    fullDelayTime = delay;
                    fullFadeTime = FADE_TIME;
                }
                [[[self getEntityAt:currentPos] getSprite] runAction:[CCSequence actions:
                                                                      [CCDelayTime actionWithDuration:fullDelayTime],
                                                                      [CCFadeIn actionWithDuration:fullFadeTime],
                                                                      nil]];                
            } else if (current == tileBlock) {
                Entity *goner = [self getEntityAt:currentPos];
                float fullDelayTime = FADE_TIME+delay;
                if ([BoxLevel isGoalPos:currentPos]) {
                    fullDelayTime = delay;
                }
                [self clearSpot:currentPos];
                [[goner getSprite] runAction:[CCSequence actions:
                                              [CCDelayTime actionWithDuration:fullDelayTime],
                                              [CCFadeTo actionWithDuration:FADE_TIME opacity:0],
                                              nil]];                
                [goner markForDeletion];
            } else {
                // Inverter, Goal, Avatar: do nothing
            }
        }
    }
    
    // unfreeze
}

// Getters
+ (Entity*) getEntityAt:(CGPoint)gridPos {
    if (_gridState == nil) {
        [SquidLog warn:@"Uh-oh. Grid state was nil."];
        [self failGracefully];
        return nil;
    } else if (![VecUtil isIntPoint:gridPos]) {
        [SquidLog warn:@"Not a valid grid pos: %f, %f", gridPos.x, gridPos.y];
        [self failGracefully];
        return nil;
    } else if (![VecUtil isInBounds:gridPos]) {
        //[SquidLog info:@"Pushed edge of map"];
        return nil;
    }
    return [_gridState objectForKey:[self convertToKey:gridPos]];
}

+ (tileType) getTypeAt:(CGPoint)gridPos {
    Entity* ent = [self getEntityAt:gridPos];

    if (![VecUtil isIntPoint:gridPos]) {
        [SquidLog warn:@"Error, inexact pos: %f, %f", gridPos.x, gridPos.y];
        [self failGracefully];
    }
    
    if (![VecUtil isExactGridPos:gridPos]) {
        return tileWall;
    }
    
    if (ent == nil) {
        return tileEmpty;
    }
    
    return [ent getType];
}

//"Empty" here includes inverters
+ (bool) isTileAheadEmpty:(CGPoint)direction {
    // Sanity check
    if (![VecUtil isCardinalDirection:direction]) {
        [SquidLog warn:@"Error, not unit cardinal: %f, %f",
         direction.x,
         direction.y];
        [self failGracefully];
        return NO;
    }

    CGPoint oneAhead = ccpAdd([_avatar getGridPosition], direction);
    return ([self getTypeAt:oneAhead] == tileEmpty);
}

+ (bool) isMoveAllowed:(CGPoint)direction {
    // Sanity check
    if (![VecUtil isCardinalDirection:direction]) {
        [SquidLog warn:@"Error, not unit cardinal: %f, %f",
         direction.x,
         direction.y];
        [self failGracefully];
        return NO;
    }
    
    CGPoint oneAhead = ccpAdd([_avatar getGridPosition], direction);
    CGPoint twoAhead = ccpAdd(oneAhead, direction);

    if ([self getTypeAt:oneAhead] == tileEmpty) {
        return YES;
    } else if ([self getTypeAt:twoAhead] == tileEmpty &&
               [self getTypeAt:oneAhead] == tileBlock) {
        return YES;
    } else {
        [SquidLog debug:@"Can't push block to %f, %f", twoAhead.x, twoAhead.y];
    }
    
    return NO;
}

+ (Entity*) getAvatar {
    return _avatar;
}

// Return: was this successful?
+ (bool) replaceRedoHistory:(NSString*)newRedoHistory {
    if ([_undoHistory length] != 0) {
        [SquidLog warn:@"replaceRedoHistory called with a non-empty undo history. Serious stability risk. Quitting."];
        return NO;
    }
    
    _redoHistory = newRedoHistory;
    [self persistLog];
    return YES;
}

// Utility
+ (NSString*) convertToKey:(CGPoint)point {
    // TODO: validate input?
    NSString *keyString = [NSString stringWithFormat:@"%i_%i", (int)point.x, (int)point.y];
    return keyString;
}

+ (bool) didWin {
    return _didWin;
}

+ (bool) isInverted {
    return _isInverted;
}

// slight overkill to always persist both.
+ (void) persistLog {
    [BoxStorageLevels setUndoLog:_undoHistory forLevel:[BoxStorageLevels getCurrentLevelID]];
    [BoxStorageLevels setRedoLog:_redoHistory forLevel:[BoxStorageLevels getCurrentLevelID]];
}

// Something went seriously wrong. Clear history, persist, and go to pack scene.
+ (void) failGracefully {
    // TODO: Also set HUD state to stateDefault in here?
    
    [SquidLog warn:@"Fail gracefully: failing over to pack menu."];
    [[[CCDirector sharedDirector] runningScene] unscheduleAllSelectors];
    [SquidLog warn:@" > Undo: %@", _undoHistory];
    [SquidLog warn:@" > Redo: %@", _redoHistory];
    _undoHistory = @"";
    _redoHistory = @"";
    [self persistLog];

    //---------------
    // Print out some info
    NSString *_undoHistTemp = [BoxStorageLevels getUndoLog:[BoxStorageLevels getCurrentLevelID]];
    NSString *_redoHistTemp = [BoxStorageLevels getRedoLog:[BoxStorageLevels getCurrentLevelID]];
    [SquidLog info:@"Cleared History. It is now: [%@ - %@]", _undoHistTemp, _redoHistTemp];
    //---------------
    
    [Scene_Generic_BoxPusher goToNextScene:[Scene_Group node]];    
}

@end