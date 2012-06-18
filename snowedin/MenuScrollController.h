//
//  MenuScrollController.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/2/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCLayer;

@interface MenuScrollController : NSObject {
}

// Setup
+ (void) reset:(int)contentWidth centerAt:(float)xPosPx;
+ (void) addNode:(CCNode*)node movementSpeed:(float)speed;
+ (void) needsToShowWinScreen;

// Utility
+ (bool) screenIsInBounds;
+ (float) averageIgnoreZeros:(float)a b:(float)b c:(float)c;

// Touch Delegate Interface
+ (void) ccTouchesBegan: (NSSet *)touches withEvent: (UIEvent *)event;
+ (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
+ (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

+ (void) dragTick:(ccTime)dt;
+ (void) updateAllLayers;
+ (void) bumpOneScreenRight;
+ (void) bumpHardLeft;

@end
