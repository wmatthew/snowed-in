//
//  GridInputManager.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import <Foundation/Foundation.h>

@class Scene_Play;

@interface GridInputManager : NSObject {}

+ (void) reset:(Scene_Play*)playScene;
+ (void) tick:(ccTime)dt;

+ (void) noteStrokeID;

+ (bool) canSlide;
+ (bool) canPush;
+ (bool) canFrustrate;

// Need to specify explicitly because the protocol only handles instance calls, not static ones.
+ (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
+ (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
+ (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
