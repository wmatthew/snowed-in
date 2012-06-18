//
//  Scene_Play.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/21/11.
//  Copyright SquidMixer 2011. All rights reserved.

#import "Scene_Generic_BoxPusher.h"
#import "SquidLog.h"
#import <iAd/iAd.h>

@class HUD_Play;
@class WinExplosion;

@interface Scene_Play : Scene_Generic_BoxPusher <ADBannerViewDelegate> {
    CCLayer *_playLayer;
    CCLayerColor *_winWhiteFadeLayer;
    ADBannerView *adBannerView;
    HUD_Play *_myHUDPlay;
    CGPoint _playLayerPositionOffset;
    WinExplosion *_winEmitter;
    
    UIPinchGestureRecognizer *_pinch;
    float _pinchBaseline;
}

- (void) tick: (ccTime) dt;
- (void) continueWin:(ccTime)dt;
- (void) finishWin;
- (void) removeAd; // only call this when exiting scene.
- (void) setZoomLevel:(float)zoomLevel;

- (void)fixBannerToDeviceOrientation:(UIDeviceOrientation)orientation;

@end
