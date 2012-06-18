//
//  GridDisplayManager.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "BoxUnderlay.h"
#import "boxpusher.h"

static CCLayer *_mainLayer;
static CGPoint _offset;
static CGPoint _tileSize;
static NSArray *_backgroundTiles;
static NSArray *_inverterSprites;

@implementation GridDisplayManager

+ (CCLayer*) reset {
    _mainLayer = [CCLayer node]; // autorelease
    _tileSize = [Dimensions isIPad] ? ccp(100,100) : ccp(50,50);

    // Background Tiles
    CGPoint size = [BoxLevel getLevelSize];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _offset = ccp(winSize.width/2  - (size.x-1) * _tileSize.x/2,
                  winSize.height/2 + (size.y-1) * _tileSize.y/2);
    
    NSMutableArray *bgTiles = [NSMutableArray array];
    NSMutableArray *invSprites = [NSMutableArray array];
    for (int j=0; j<size.y; j++) {
        for (int i=0; i<size.x; i++) {
            CGPoint curPos = ccp(i,j);

            if ([BoxLevel getBasicTypeAt:curPos] == tileWall) {
                continue;
            }
            if ([BoxLevel isInvertPos:curPos]) {
                ccColor3B invColor = [HousePainter getTrimColor:[BoxStorageLevels getCurrentLevelGroup]];
                CCSprite *inv = [self addTileAt:curPos sprite:[Art sprite:sm_invert] color:invColor scale:1 z:1];
                //CCSprite *inv = [self addTileAt:curPos sprite:[Art sprite:sm_snowflake] color:invColor scale:0.5 z:1];
                [invSprites addObject:inv];
            }
            if ([BoxLevel isGoalPos:curPos]) {
                CCSprite *snowflake = [Art sprite:sm_snowflake];
                [snowflake runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:12.0 angle:360]]];
                [self addTileAt:curPos sprite:snowflake color:ccWHITE scale:1.0 z:1];
            }
            if (YES) {
                // Note: scale=0.51 here is to fudge scale, to get rid of thin gaps

                // Far background tile
                ccColor3B trimColor = [HousePainter getTrimColor:[BoxStorageLevels getCurrentLevelGroup]];
                [self addTileAt:curPos sprite:[Art sprite:sm_square] color:trimColor scale:0.255 z:-2];
                
                // Background tile
                ccColor3B baseColor = [HousePainter getBaseColor:[BoxStorageLevels getCurrentLevelGroup]];
                CCSprite *bg = [self addTileAt:curPos sprite:[Art sprite:sm_square] color:baseColor scale:0.255 z:-1]; 
                
                [bgTiles addObject:bg];
            }
        }        
    }
    
    _backgroundTiles = [[NSArray arrayWithArray:bgTiles] retain];
    _inverterSprites = [[NSArray arrayWithArray:invSprites] retain];
    
    // Movable Blocks
    for (int j=0; j<size.y; j++) {
        for (int i=0; i<size.x; i++) {
            Entity *current = [GridLogicManager getEntityAt:ccp(i,j)];
            if (current != nil) {
                [self addEntity:current];
            }
        }        
    }    

    //[_mainLayer addChild:[[BoxUnderlay alloc] init] z:3];
    //[_mainLayer addChild:[[BoxOverlay alloc] init] z:2];
    
    return _mainLayer;
}

+ (CCSprite*) addTileAt:(CGPoint)gridPos sprite:(CCSprite*)bgTile color:(ccColor3B)color scale:(float)scale z:(int)depth {
    bgTile.color = color;
    bgTile.scale = scale;
    [bgTile setPosition:[self gridToPx:gridPos]];
    [_mainLayer addChild:bgTile z:depth];
    return bgTile;
}

+ (void) setInversion:(bool)inverted atPos:(CGPoint)invertGridPos {

    if (!_backgroundTiles) {
        [SquidLog error:@"GridDisplayManager: couldn't invert; _bgTiles is borked (nil?)."];
    } else {
        [SquidLog debug:@"Inverting %i tiles...", [_backgroundTiles count]];
    }

    for (CCSprite *sprite in _inverterSprites) {
        if (inverted) {
            sprite.color = [HousePainter getBaseColor:[BoxStorageLevels getCurrentLevelGroup]];
        } else {
            sprite.color = [HousePainter getTrimColor:[BoxStorageLevels getCurrentLevelGroup]];
        }
        // Spin the inverters
        [sprite runAction:[CCRotateTo actionWithDuration:FADE_TIME angle:inverted ? 150 : 0]];
    }

    for (CCSprite *sprite in _backgroundTiles) {
        float delay = [self getInversionDelay:invertGridPos targetPos:[self pxToGrid:sprite.position]];
        float eventualOpacity = inverted ? 0 : 255;

        // Just in case there's several inverts happening in short succession.
        [sprite stopAllActions];
        
        [sprite runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:delay],
                           [CCFadeTo actionWithDuration:FADE_TIME opacity:eventualOpacity],
                           nil]];                
    }
}

+ (float) getInversionDelay:(CGPoint)invertGridPos targetPos:(CGPoint)targetGridPos {
    float multFactor = 0.3f;
    float dist = ccpDistance(invertGridPos, targetGridPos);
    dist = MAX(0, dist-2);
    return dist * multFactor;
}

+ (void) addEntity:(Entity*) newGuy {
    if ([newGuy getType] == tileWall) {
        // Walls have no sprites
        return;
    }

    int depth = ([newGuy getType] == tileAvatar) ? 2 : 0;
    [_mainLayer addChild:[newGuy getSprite] z:depth];
    [newGuy updateSpritePos];
}

+ (CGPoint) gridToPx:(CGPoint)gridPos {
    return ccpAdd(ccp(_tileSize.x*gridPos.x,-_tileSize.y*gridPos.y), _offset);
}

+ (CGPoint) pxToGrid:(CGPoint)posPx {
    CGPoint temp = ccpSub(posPx, _offset);
    return ccp(temp.x/_tileSize.x, -temp.y/_tileSize.y);
}
 
+ (CGPoint) getLevelCenterPx {
    CGPoint levelSize = [BoxLevel getLevelSize];
    CGPoint centerGridPos = ccp((levelSize.x-1.0)/2.0, (levelSize.y-1.0)/2.0);
    return [self gridToPx:centerGridPos];
}

@end
