//
//  HUD.h
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#define UNDO_LAG 0.1
#define REDO_LAG 0.3
#define REPLAY_HINT_SMALL_LAG 0.6
#define REPLAY_HINT_BIG_LAG 2.0

#import "HintEnums.h"
#import "cocos2d.h"

@class CCMenuItemImage;
@class CCMenu;
@class Scene_Generic_BoxPusher;
@class HintLayer;
@class CCLayer;
@class CCSprite;

@interface HUD_Generic : CCLayer {
    float _stateCountdown;
    CCMenu *_hudMenu;
    Scene_Generic_BoxPusher *_scene;
    
    HintLayer *_hintLayer;
    
    int _redoLimit;
}

//==================
// Buttons
- (CCMenuItemImage*) addHorizButtonAt:(CGPoint)pos
                             function:(SEL)selector
                                color:(ccColor3B)color
                             selColor:(ccColor3B)selColor
                        defaultSprite:(CCSprite*)defaultSprite
                       selectedSprite:(CCSprite*)selectedSprite;

- (CCMenuItemImage*) addBottomButtonAt:(CGPoint)pos
                                 label:(NSString*)text
                              function:(SEL)selector
                                 color:(ccColor3B)color
                              selColor:(ccColor3B)selColor
                         defaultSprite:(CCSprite*)defaultSprite
                        selectedSprite:(CCSprite*)selectedSprite
                           zoomOnPress:(float)zoomFactor;

- (CCMenuItemImage*) addButtonAtPx:(CGPoint)pos 
                          function:(SEL)selector
                           color:(ccColor3B)color
                        selColor:(ccColor3B)selColor
                   defaultSprite:(CCSprite*)defaultSprite
                  selectedSprite:(CCSprite*)selectedSprite;



@end
