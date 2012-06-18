//
//  GridInputManager.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/22/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "boxpusher.h"

@implementation GridInputManager

static Scene_Play *_playScene;

const float SLIDE_RECHARGE = 0.025;
const float PUSH_RECHARGE = 0.1;
const float FRUSTRATE_RECHARGE = 10.0;

static double _lastSlideTime;
static double _lastPushTime;
static double _lastFrustrateTime;

static int _currentStrokeID;

+ (void) reset:(Scene_Play*)playScene; {
    _lastFrustrateTime = 0;
    _lastSlideTime = 0;
    _lastPushTime = 0;
    _playScene = playScene;
    [TouchManager reset];
}

+ (void) tick:(ccTime)dt {
    
    if ([TouchManager hasTap]) {
        [TouchManager getTapPosition:YES]; // clear it
        [HUD_Play interruptAutoplay];
    }
    
    if ([TouchManager hasDrag]) {
        [self noteStrokeID];
        CGPoint dragDirection = [TouchManager getTotalDrag:NO];        
             
        // convert to cardinal direction unit vector
        // can't use ccpNormalize; it doesn't give exact 1.0 and -1.0.
        if (abs(dragDirection.x) > abs(dragDirection.y)) {
            dragDirection.x = dragDirection.x > 0 ? 1 : -1;
            dragDirection.y = 0;
        } else {
            dragDirection.x = 0;
            dragDirection.y = dragDirection.y > 0 ? -1 : 1; // we're flipping the sign here (deliberately)
        }

        if ([GridLogicManager isTileAheadEmpty:dragDirection]) {
            if ([self canSlide]) {
                [GridLogicManager executeMove:dragDirection isRedo:NO];             
                [TouchManager getTotalDrag:YES]; // clear it
            }
        } else if ([GridLogicManager isMoveAllowed:dragDirection]) {
            if ([self canPush]) {
                [GridLogicManager executeMove:dragDirection isRedo:NO];             
                [TouchManager getTotalDrag:YES]; // clear it            
            }
        } else {
            if ([self canFrustrate]) {
                [BoxMusic tryToPlaySound:frustrate_sound];
                [[GridLogicManager getAvatar] frustrateEntity:dragDirection];
                [TouchManager getTotalDrag:YES]; // clear it            
            }
        }
        
        [HUD_Play interruptAutoplay];
    }
}

+ (void) noteStrokeID {
    if ([TouchManager getStrokeID] != _currentStrokeID) {
        // Reset all timers
        _currentStrokeID = [TouchManager getStrokeID];
        _lastFrustrateTime = 0;
        _lastSlideTime = 0;
        _lastPushTime = 0;
    }
}

+ (bool) canSlide {
    double now = CACurrentMediaTime();
    if (now - _lastSlideTime > SLIDE_RECHARGE) {
        if (_lastSlideTime == 0) {
            // Inhibit second move
            _lastSlideTime = now + SLIDE_RECHARGE;
        } else {
            _lastSlideTime = now;
        }
        return YES;
    }
    return NO;
}

+ (bool) canPush {
    double now = CACurrentMediaTime();
    float lastMoveTime = MAX(_lastSlideTime, _lastPushTime);
    if (now - lastMoveTime > PUSH_RECHARGE) {
        _lastPushTime = now;
        return YES;
    }
    return NO;
}

+ (bool) canFrustrate {
    double now = CACurrentMediaTime();
    float lastActTime = MAX(_lastSlideTime, MAX(_lastPushTime, _lastFrustrateTime));
    if (now - lastActTime > FRUSTRATE_RECHARGE) {
        _lastFrustrateTime = now;
        return YES;
    }
    return NO;
}

+ (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [TouchManager ccTouchesBegan:touches withEvent:event];
}
+ (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [TouchManager ccTouchesMoved:touches withEvent:event];
}
+ (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [TouchManager ccTouchesEnded:touches withEvent:event];
}

@end
