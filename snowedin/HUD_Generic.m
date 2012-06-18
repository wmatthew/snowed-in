//
//  HUD.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "HUD_Generic.h"
#import "boxpusher.h"

@implementation HUD_Generic

- (CCMenuItemImage*) addHorizButtonAt:(CGPoint)pos
                             function:(SEL)selector
                                color:(ccColor3B)color
                             selColor:(ccColor3B)selColor
                        defaultSprite:(CCSprite*)defaultSprite
                       selectedSprite:(CCSprite*)selectedSprite {
    
    return [self addButtonAtPx:[Dimensions convertScreensToPxWidthCentric:pos]
                      function:selector
                         color:color 
                      selColor:selColor
                 defaultSprite:defaultSprite
                selectedSprite:selectedSprite];
}

- (CCMenuItemImage*) addBottomButtonAt:(CGPoint)pos
                                 label:(NSString*)text
                              function:(SEL)selector
                                 color:(ccColor3B)color
                              selColor:(ccColor3B)selColor
                         defaultSprite:(CCSprite*)defaultSprite
                        selectedSprite:(CCSprite*)selectedSprite
                           zoomOnPress:(float)zoomFactor {

    // Expand a bit when tapped.
    selectedSprite.scale *= zoomFactor;
    selectedSprite.position =
    ccp([defaultSprite boundingBox].size.width/2  - [selectedSprite boundingBox].size.width/2,
        [defaultSprite boundingBox].size.height/2 - [selectedSprite boundingBox].size.height/2);

    CCMenuItemImage* ret = [self addButtonAtPx:[Dimensions convertScreensToPxBottomCentric:pos]
                                      function:selector
                                         color:color 
                                      selColor:selColor
                                 defaultSprite:defaultSprite
                                selectedSprite:selectedSprite];
    
    return ret;
}

- (CCMenuItemImage*) addButtonAtPx:(CGPoint)posPx
                          function:(SEL)selector
                             color:(ccColor3B)color
                          selColor:(ccColor3B)selColor
                     defaultSprite:(CCSprite*)defaultSprite
                    selectedSprite:(CCSprite*)selectedSprite {
    
    defaultSprite.color = color;
    selectedSprite.color = selColor;
    
    CCMenuItemImage *menuImage = [CCMenuItemImage itemFromNormalSprite:defaultSprite selectedSprite:selectedSprite target:self selector:selector];
    menuImage.scale = 0.2;
    [menuImage setPosition:posPx];
    [_hudMenu addChild:menuImage];
    return menuImage;
}

- (void) goLevelGroup:(id)sender {
    [BoxMusic tryToPlaySound:press_sound];
    [[[CCDirector sharedDirector] runningScene] unscheduleAllSelectors];
    [Scene_Generic_BoxPusher goToNextScene:[Scene_Group node]];    
}

@end
