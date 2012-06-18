//
//  BoxButton.h
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "cocos2d.h"

@interface BoxButton : CCLayer {
    CCMenuItemImage *_menuImage;
    CCSprite *_basicSprite;
    CCSprite *_selectedSprite;
}

- (id) initBlank;
- (void) addTo:(CCMenu*)menu andLayer:(CCLayer*)parent;
- (void) hitButton:(id)sender;
- (CCMenuItemImage*) getMenuImage;
- (void) setColors:(ccColor3B)basic selected:(ccColor3B)selected;

@end
