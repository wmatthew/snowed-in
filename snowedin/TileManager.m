//
//  TileManager.m
//  Snowed In!!
//
//  Created by Matthew Webber on 9/30/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "TileManager.h"

@implementation TileManager

+ (bool) isAvatarTile:(tileType)tile {
    return tile == tileAvatar || tile == tileAvatarGoal || tile == tileAvatarInverter;
}

+ (bool) isGoalTile:(tileType)tile {
    return tile == tileAvatarGoal || tile == tileBlockGoal || tile == tileEmptyGoal;
}

+ (bool) isBlockTile:(tileType)tile {
    return tile == tileBlock || tile == tileBlockGoal;
}

+ (bool) isInverterTile:(tileType)tile {
    return tile == tileInverter || tile == tileAvatarInverter;
}

@end
