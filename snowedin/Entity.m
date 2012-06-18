//
//  Entity.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "Entity.h"
#import "boxpusher.h"

static NSMutableArray *_allEntities;

@implementation Entity

+ (void) reset {
    _allEntities = [[NSMutableArray array] retain];
}

+ (Entity*) makeAt:(CGPoint)gridPos withType:(tileType)type {
    Entity *newEntity = [[[Entity alloc] initWithType:type] autorelease];
    [newEntity forceToPoint:gridPos];
    [_allEntities addObject:newEntity];
    return newEntity;
}

- (id) initWithType:(tileType)type {
    if (( self = [super init] )) {
        _shouldBeDeletedSoon = NO;
        _myType = type;
        if (_myType == tileBlock) {
            if ([GridLogicManager isInverted]) {
                _mySprite = [Art sprite:sm_square];
                _mySprite.color = [HousePainter getBaseColor:[BoxStorageLevels getCurrentLevelGroup]];
            } else {
                _mySprite = [Art sprite:sm_square];
                _mySprite.color = [HousePainter getTrimColor:[BoxStorageLevels getCurrentLevelGroup]];
            }
            
            /**
            // Wobble
            _mySprite.rotation = -8 + CCRANDOM_0_1() * 4;
            float flip = CCRANDOM_0_1()>0.5?1:-1;
            float myDur = 0.4 + CCRANDOM_0_1() * 0.1;
            [_mySprite runAction:
             [CCSequence actions:
              [CCRotateTo actionWithDuration:myDur angle: 6*flip],
              [CCRotateTo actionWithDuration:myDur angle:-6*flip],                                                             
              [CCRotateTo actionWithDuration:myDur*1.5 angle: 5*flip],
              [CCRotateTo actionWithDuration:myDur*1.5 angle:-5*flip],                                                             
              [CCRotateTo actionWithDuration:myDur*2  angle: 4*flip],
              [CCRotateTo actionWithDuration:myDur*2  angle:-4*flip],                                                             
              [CCRotateTo actionWithDuration:myDur*3 angle: (-3 + CCRANDOM_0_1()*6)*flip],
              nil]
             ];
             **/
            _mySprite.scale = 0.225;
        } else if (_myType == tileWall) {
            // walls don't have sprites
            _mySprite = nil;
        } else if (_myType == tileAvatar) {
            // avatar
            _mySprite = [Art sprite:img_snowman];
            _mySprite.scale = 0.25;
            _frustrateTimer = 0;
            _isFrustrated = NO;
        } else {
            [SquidLog error:@"Unknown tileType!"];
        }
    }
    return self;
}

- (void) markForDeletion {
    _shouldBeDeletedSoon = YES;
}

- (bool) shouldBeDeleted {
    return _shouldBeDeletedSoon && _mySprite.opacity == 0;
}

+ (void) tick:(ccTime)dt {
    int count = [_allEntities count];
    if (count > 200) {
        // If this comes up, check where entities are removed in GridLogicManager's invert function.
        [SquidLog warn:@"Entity List has %i entries. Memory leak, giant level, or furious inverting?", [_allEntities count]];    
    } else {
        [SquidLog debug:@"Entity List has %i entries", [_allEntities count]];
    }
    
    NSMutableArray *deadEntities = [NSMutableArray array];
    [SquidLog debug:@"Entities: %i", [_allEntities count]];
    for (Entity *e in _allEntities) {
        if ([e shouldBeDeleted]) {
            [deadEntities addObject:e];
        } else {            
            [e tick:dt];
        }
    }

    for (Entity *del in deadEntities) {
        [[[del getSprite] parent] removeChild:[del getSprite] cleanup:YES];    
    }
    [_allEntities removeObjectsInArray:deadEntities];
}

- (void) tick:(ccTime)dt {
    [self checkRep];
    
    // Make actualGridPos a little closer to desiredGridPos
    float movementSpeed = 0.15; // normally 0.1
    _actualGridPos = ccpAdd(ccpMult(_actualGridPos, 1.0 - movementSpeed), ccpMult(_desiredGridPos, movementSpeed));
    [self updateSpritePos];
    
    if (_myType == tileAvatar && _isFrustrated) {
        _frustrateTimer -= dt;
        if (_frustrateTimer < 0) {
            [self unfrustrate];
        }
    }
}

- (void) updateSpritePos {
    CGPoint spritePos = [GridDisplayManager gridToPx:_actualGridPos];
    [_mySprite setPosition:spritePos];
}

- (void) forceToPoint:(CGPoint)gridPos {
    _actualGridPos = gridPos;
    _desiredGridPos = gridPos;
}

- (tileType) getType {
    return _myType;
}

- (CCSprite*) getSprite {
    if (_mySprite == nil) {
        [SquidLog warn:@"Returning nil sprite in Entity class"];
    }
    return _mySprite;
}

// Logical grid position
- (CGPoint) getGridPosition {
    return _desiredGridPos;
}

- (void) checkRep {
    if (_myType == tileWall && _mySprite != nil) {
        [SquidLog error:@"Error, tileWall entities shouldn't have sprites."];    
    }
    
    if (_myType != tileWall && _mySprite == nil) {
        [SquidLog error:@"Error, non-tileWall entity has no sprite."];
    }    
    
    Entity *jerk = [GridLogicManager getEntityAt:_desiredGridPos];
    if (!_shouldBeDeletedSoon && jerk != nil && jerk != self) {
        [SquidLog warn:@"Something else is in this entity's spot. Type: %i", [jerk getType]];
        [GridLogicManager failGracefully];
    }
}

- (void) moveToward:(CGPoint)newGridPos isUndo:(bool)isUndo isPush:(bool)isPush {
    CGPoint oldPos = _desiredGridPos;    
    _desiredGridPos = newGridPos;

    if (_myType == tileAvatar) {
        CGPoint direction = ccpSub(newGridPos, oldPos);
        if (isUndo) {
            direction = ccpMult(direction, -1);
        }
        
        if (isPush) {
            [self frustrateEntity:direction];
        } else {
            _isFrustrated = NO;
            [self rotateSpriteToward:direction duration:0.1];
            _mySprite.texture = [Art texture:img_snowman];      
        }
    }
}

- (void) unfrustrate {
    _mySprite.texture = [Art texture:img_snowman];    
    _isFrustrated = NO;
}

- (void) frustrateEntity:(CGPoint)direction {
    if (_myType != tileAvatar) {
        [SquidLog warn:@"Trying to frustrate a non-avatar"];
        return;
    }
    _isFrustrated = YES;
    _frustrateTimer = 1.0f;
    [self rotateSpriteToward:direction duration:0.0];
    _mySprite.texture = [Art texture:img_snowman_push];    
}

- (void) rotateSpriteToward:(CGPoint)direction duration:(float)turnDuration {
    float angle;
    if (direction.y == -1) {
        angle = 0;
    } else if (direction.x == 1) {
        angle = 90;
    } else if (direction.y == 1) {
        angle = 180;
    } else {
        angle = 270;
    }

    if (turnDuration > 0) {
        [_mySprite runAction:[CCRotateTo actionWithDuration:turnDuration angle:angle]];
    } else {
        _mySprite.rotation = angle;
    }
}

- (CGPoint) convertPointPxToPointGrid:(CGPoint)pointPx {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return ccpMult(ccpSub(pointPx, ccp(winSize.width, winSize.height)), 0.01);
}    
                                        
@end
