//
//  Entity.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "GridLogicManager.h"
#import "boxpusher.h"

@class CCSprite;

@interface Entity : NSObject {
    tileType _myType;
    CGPoint _actualGridPos;
    CGPoint _desiredGridPos;
    CCSprite *_mySprite;
    bool _shouldBeDeletedSoon;
    
    // Avatar use only
    float _frustrateTimer;
    bool _isFrustrated;
}

// Initialization
- (id) initWithType:(tileType)type;
+ (void) reset;
+ (Entity*) makeAt:(CGPoint)gridPos withType:(tileType)type;

// Getters
- (tileType) getType;
- (CCSprite*) getSprite;
- (CGPoint) getGridPosition;

// Modifiers
+ (void) tick:(ccTime)dt;
- (void) tick:(ccTime)dt;
- (void) forceToPoint:(CGPoint)gridPos;
- (void) moveToward:(CGPoint)posPx isUndo:(bool)isUndo isPush:(bool)isPush;
- (void) markForDeletion;
- (bool) shouldBeDeleted;
- (void) updateSpritePos;
- (void) frustrateEntity:(CGPoint)direction;
- (void) unfrustrate;
- (void) rotateSpriteToward:(CGPoint)direction duration:(float)turnDuration;

// Utility
- (CGPoint) convertPointPxToPointGrid:(CGPoint)pointPx;
- (void) checkRep;

@end
