//
//  HUD_Pack.m
//  Snowed In!!
//
//  Created by Matthew Webber on 7/12/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "HUD_Menu.h"
#import "boxpusher.h"

@implementation HUD_Menu

static HUD_Menu *_singleton;

+ (HUD_Menu*) getNewHUD:(hudConfiguration)config withScene:(Scene_Generic_BoxPusher*)scene {
    _singleton = [[HUD_Menu alloc] initWithConfig:config scene:scene];
    return _singleton;
}

+ (HUD_Menu*) getOldHUD {
    return _singleton;
}

- (id) initWithConfig:(hudConfiguration)config scene:(Scene_Generic_BoxPusher*)scene{
    if (( self = [super init] )) {
        
        _scene = scene;
        
        _hudMenu = [CCMenu menuWithItems: nil];
        [_hudMenu setPosition:CGPointZero];
        [self addChild:_hudMenu];        
        
        float _botRowY = 0.05; // alignment of all buttons/text on bottom row.
        
        if (config == configMainMenu) {

            ccColor3B darkGrey = ccc3(50,50,50);
            
            _musicOn = [self addBottomButtonAt:ccp(0.4,_botRowY) 
                                         label:@"Music"
                                      function:@selector(musicOn:)
                                         color:ccGRAY 
                                      selColor:darkGrey
                                 defaultSprite:[Art sprite:sm_nomusic]
                                selectedSprite:[Art sprite:sm_music]
                                   zoomOnPress:2.0];
            
            _musicOff = [self addBottomButtonAt:ccp(0.4,_botRowY) 
                                          label:@"Music"
                                       function:@selector(musicOff:) 
                                          color:ccGRAY
                                       selColor:darkGrey
                                  defaultSprite:[Art sprite:sm_music]
                                 selectedSprite:[Art sprite:sm_nomusic]
                                    zoomOnPress:2.0];
            
            if ([SquidStorageAudio getMusicMuted]) {
                _musicOff.visible = NO;
            } else {            
                _musicOn.visible = NO;
            }
            
            _soundOn = [self addBottomButtonAt:ccp(0.5,_botRowY)
                                         label:@"Sound"
                                      function:@selector(soundOn:)
                                         color:ccGRAY 
                                      selColor:darkGrey
                                 defaultSprite:[Art sprite:sm_nosound]
                                selectedSprite:[Art sprite:sm_sound]
                                   zoomOnPress:2.0];
            
            _soundOff = [self addBottomButtonAt:ccp(0.5,_botRowY)
                                          label:@"Sound"
                                       function:@selector(soundOff:) 
                                          color:ccGRAY 
                                       selColor:darkGrey
                                  defaultSprite:[Art sprite:sm_sound] 
                                 selectedSprite:[Art sprite:sm_nosound]
                                    zoomOnPress:2.0];
            
            if ([SquidStorageAudio getSoundMuted]) {
                _soundOff.visible = NO;
            } else {
                _soundOn.visible = NO;
            }
        } else {
            [SquidLog error:@"HUD config not recognized: %i", config];
        }
    }
    return self;
}

- (void) soundOn:(id)sender {
    [BoxMusic unmuteSounds];
    _soundOn.visible = NO;
    _soundOff.visible = YES;
    [BoxMusic tryToPlaySound:press_sound];
}

- (void) soundOff:(id)sender {
    [BoxMusic muteSounds];
    _soundOn.visible = YES;
    _soundOff.visible = NO;
    [BoxMusic tryToPlaySound:press_sound]; // will fail, but hey, consistency.
}

- (void) musicOn:(id)sender {
    [BoxMusic unmuteMusic];
    _musicOn.visible = NO;
    _musicOff.visible = YES;
    [BoxMusic tryToPlaySound:press_sound];
}

- (void) musicOff:(id)sender {
    [BoxMusic muteMusic];
    _musicOn.visible = YES;
    _musicOff.visible = NO;
    [BoxMusic tryToPlaySound:press_sound];
}

@end
