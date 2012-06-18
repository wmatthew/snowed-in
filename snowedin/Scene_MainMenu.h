//
//  Scene_MainMenu.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/25/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "Scene_Generic_BoxPusher.h"
#import "SignArtist.h"
#import "cocos2d.h"
#import "ProgressSnowman.h"

@class SignAction;

typedef enum {
    // lowest
    depthHouseMenu = 10,
    depthHouseImagery = 20,
    depthSignPost = 25,
    depthSignMenu = 30,
    depthSignText = 40,
    // highest
} depthMainMenu;

typedef enum {
    snowHeightMin,
    snowHeightMax,
    snowHeightFull,
} snowHeight;

@interface Scene_MainMenu : Scene_Generic_BoxPusher {

    CCLayer *_contentLayer;
    CCLayer *_hillLayer;

    CCMenu *_houseMenu;    
    CCMenu *_signMenu;    
    
    float _viewWidth;
    float _pagesOfContent;
    float _contentWidth;
    float _scrollableWidth;
}

- (void) dragTick:(ccTime)dt;
- (void) addSnowAtDepth:(int)depth withSpeed:(float)movementSpeed;

- (CCLayer*) addHillLayer;
- (void) addOneHillAt:(int)pageIndex snowLevel:(float)snowLevel;
- (void) addOverallProgressHill;
- (void) addMountains;
- (NSArray*) getOrientations:(int) houseCount;

- (void) drawPack:(levelPack)pack atOffset:(float)offset;
- (CCLabelTTF*) drawSignText:(NSString*)signText at:(CGPoint)pos fontSize:(float)size;
- (void) drawMainSign:(NSString*)title subtitle:(NSString*)subtitle at:(CGPoint)pos action:(SignAction*)action;
- (void) drawSignHelper:(artResource)imageString at:(CGPoint)pos action:(SignAction*)action post:(signPostType)post;

@end
