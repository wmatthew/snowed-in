//
//  BoxLevel.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/27/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "boxpusher.h"
#import "GridLogicManager.h"

@interface BoxLevel : NSObject { 
}

// Initialize
+ (void) loadLevel:(int)levelID;
+ (NSString*) readLevelFile;
+ (void) unpackSpecString;
+ (void) clearLevel;
+ (void) parseNewFormat:(NSString*)levelData;

// Access
+ (CGPoint) getLevelSize;
+ (tileType) getBasicTypeAt:(CGPoint)gridPos; // TODO: deprecate
+ (tileType) getActualTypeAt:(CGPoint)gridPos;
+ (bool) isGoalPos:(CGPoint)gridPos;
+ (bool) isInvertPos:(CGPoint)gridPos;

+ (NSString*) getTitle;
+ (NSString*) getTutorialOne;
+ (NSString*) getTutorialTwo;
+ (NSString*) getBestSolution;
+ (NSString*) getParSolution;
+ (NSString*) getDifficulty;

// Error-checking
+ (bool) isValidSolutionFormat:(NSString*)solution;
+ (void) sanityCheckLevel;

// Deserialization
+ (NSString*) outputNewFormat;

@end
