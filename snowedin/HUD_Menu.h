//
//  HUD_Menu.h
//  Snowed In!!
//
//  Created by Matthew Webber on 7/12/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "HUD_Generic.h"

@interface HUD_Menu : HUD_Generic {
    
    CCMenuItemImage *_upgrade;

    CCMenuItemImage *_musicOn;
    CCMenuItemImage *_musicOff;
    CCMenuItemImage *_soundOn;
    CCMenuItemImage *_soundOff;
}

- (id) initWithConfig:(hudConfiguration)config scene:(Scene_Generic_BoxPusher*)scene;

+ (HUD_Menu*) getNewHUD:(hudConfiguration)config withScene:(Scene_Generic_BoxPusher*)scene;
+ (HUD_Menu*) getOldHUD;

@end
