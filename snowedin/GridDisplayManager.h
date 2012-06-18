//
//  GridDisplayManager.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"

#define FADE_TIME 0.5

@interface GridDisplayManager : NSObject {
}

+ (CCLayer*) reset;

+ (void) addEntity:(Entity*) newGuy;
+ (CGPoint) gridToPx:(CGPoint)gridPos;

+ (void) setInversion:(bool)inverted atPos:(CGPoint)invertGridPos;
+ (float) getInversionDelay:(CGPoint)invertGridPos targetPos:(CGPoint)targetGridPos;

+ (CGPoint) pxToGrid:(CGPoint)posPx;
+ (CCSprite*) addTileAt:(CGPoint)gridPos sprite:(CCSprite*)spriteName color:(ccColor3B)color scale:(float)scale z:(int)depth;

+ (CGPoint) getLevelCenterPx;

@end
