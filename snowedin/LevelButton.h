//
//  LevelButton.h
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "BoxButton.h"
@class Scene_Group;

@interface LevelButton : BoxButton {
    int _levelID;
    bool _locked;
    Scene_Group *_parent;
}

+ (LevelButton*) makeButton:(int)levelID offset:(CGPoint)offset scale:(float)scale parent:(Scene_Group*)parent menu:(CCMenu*)menu;
- (void) drawLevel:(float)scale;
- (void) setLevelID:(int)levelID;
- (void) addSprite:(CCSprite*)tileSprite at:(CGPoint)pos scale:(float)scale color:(ccColor3B)color z:(int)depth;
- (void) setParent:(Scene_Group*)parent;
@end
