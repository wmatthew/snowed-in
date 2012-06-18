//
//  BoxMusic.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/14/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "BoxMusic.h"
#import "boxpusher.h"

@implementation BoxMusic

static NSString *_currentMusic;
static bool _isMusicPaused;

+ (void) tryToPlayMenuMusic {
    [self tryToPlayMusic:[Art menuMusic]];
}

+ (void) tryToPlayGameMusic {
    [self tryToPlayMusic:[Art gameMusic]];
}

+ (void) tryToPlayMusic:(NSString*)newMusic {
    
    if ([SquidStorageAudio getMusicMuted]) {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        return;
    }
    
    if (!_isMusicPaused && [_currentMusic isEqualToString: newMusic]) {
        // The music we want is already playing; do nothing        
    } else if (_isMusicPaused && [_currentMusic isEqualToString: newMusic]) {
        // The music we want is paused. Resume it.
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        
    } else {
        // Something else or nothing was paused/playing, start anew
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic: newMusic];
    }
    
    _currentMusic = newMusic;        
    _isMusicPaused = NO;
}

+ (void) muteMusic {
    [SquidStorageAudio setMusicMuted:YES];
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    _isMusicPaused = YES;
}

// Do this, for instance, if an iAd needs to be shown.
// We don't change the stored preferences in SquidStorageAudio.
+ (void) pauseMusic {
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    _isMusicPaused = YES;
}

+ (void) unmuteMusic {
    [SquidStorageAudio setMusicMuted:NO];
    [self tryToPlayMenuMusic];
}

+ (void) muteSounds {
    [SquidStorageAudio setSoundMuted:YES];
}

+ (void) unmuteSounds {
    [SquidStorageAudio setSoundMuted:NO];
}

+ (void) tryToPlaySound:(soundResource)sound {
    if ([SquidStorageAudio getSoundMuted]) {
        return;
    }

    if (sound == redo_sound) { return; } // HACK FIX TODO
    
    [SquidLog debug:@"Sound: %@", [Art getSound:sound]];
    float gain;
    switch (sound) {
        case push1_sound:
        case push2_sound:
            gain = 0.5; // 0.1?
            break;
        case undo_sound:
        case redo_sound:
        case invert1_sound:
        case invert2_sound:
            gain = 0.5;
            break;
        case press_sound:
        case win_sound:
        case frustrate_sound:
            gain = 1.0;
            break;
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:[Art getSound:sound] pitch:1.0f pan:0.0f gain:gain];
}

@end
