//
//  TileManager.h
//  Snowed In!!
//
//  Created by Matthew Webber on 9/30/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    tileAvatarInverter,
    tileAvatarGoal,
    tileEmptyGoal,
    tileBlockGoal,    
    tileEmpty,
    tileBlock,
    tileAvatar,
    tileWall,
    tileInverter,
} tileType;

@interface TileManager : NSObject {}

+ (bool) isAvatarTile:(tileType)tile;
+ (bool) isGoalTile:(tileType)tile;
+ (bool) isBlockTile:(tileType)tile;
+ (bool) isInverterTile:(tileType)tile;

@end
