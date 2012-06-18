//
//  BoxButton.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "BoxButton.h"
#import "SquidLog.h"
#import "Art.h"

@implementation BoxButton

- (id) initBlank {
    if (( self = [super init] )) {
        
        _basicSprite = [Art sprite:sm_square];
        _selectedSprite = [Art sprite:sm_square];
        
        _menuImage = [CCMenuItemImage itemFromNormalSprite:_basicSprite selectedSprite:_selectedSprite target:self selector:@selector(hitButton:)];
        _menuImage.scale = 0.4;
    }
    return self;
}

- (void) setColors:(ccColor3B)basic selected:(ccColor3B)selected {
    _basicSprite.color = basic;
    _selectedSprite.color = selected;
}

- (void) addTo:(CCMenu*)menu andLayer:(CCLayer*)parent {
    [SquidLog error:@"unimplemented: implement this function"];
}

- (void) hitButton:(id)sender {
    [SquidLog error:@"unimplemented: implement this function"];
}

- (CCMenuItemImage*) getMenuImage {
    return _menuImage;
}

@end
