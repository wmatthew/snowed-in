//
//  GridLogicManager.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "TileManager.h"
@class Entity;

@interface GridLogicManager : NSObject {
}

// Initialization
+ (void) reset;
+ (void) addEntity:(Entity*)entity at:(CGPoint)gridPos;
+ (void) addBlockAt:(CGPoint)gridPos isInit:(bool)isInit;
+ (void) setInitialFacingDirection;

// Getters
+ (Entity*) getEntityAt:(CGPoint)gridPos;
+ (tileType) getTypeAt:(CGPoint)gridPos;
+ (Entity*) getAvatar;
+ (bool) isMoveAllowed:(CGPoint)direction;
+ (bool) isTileAheadEmpty:(CGPoint)direction;
+ (bool) didWin;
+ (bool) isInverted;
+ (bool) didAnyMoveYet;
+ (int) getOriginalUndoLength;

// Utility
+ (NSString*) convertToKey:(CGPoint)point;
+ (CGPoint) convertToDirection:(NSString*)historyChar;

// Moving Stuff
+ (void) invertAt:(CGPoint)gridPos;
// Return YES if success, NO if failure.
+ (bool) moveThingFrom:(CGPoint)oldGridPos to:(CGPoint)newGridPos undoing:(bool)isUndo pushOrPull:(bool)isPush; // returns "should I invert?"

+ (bool) redoMove;
+ (void) executeMove:(CGPoint)direction isRedo:(bool)isRedo;
+ (void) recordMove:(CGPoint) direction pushed:(bool)pushedBlock;

+ (bool) undoMove;
+ (void) executeUndo:(CGPoint)direction pull:(bool)pullBlock;
+ (void) updateHUD;

+ (bool) replaceRedoHistory:(NSString*)newRedoHistory;
+ (void) persistLog;

+ (void) failGracefully;


@end
