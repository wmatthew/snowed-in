//
//  BoxMusic.h
//  Snowed In!!
//
//  Created by Matthew Webber on 6/14/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Art.h"

@interface BoxMusic : NSObject {}

+ (void) tryToPlayMusic:(NSString*)newMusic;
+ (void) tryToPlayMenuMusic;
+ (void) tryToPlayGameMusic;

+ (void) muteMusic;
+ (void) unmuteMusic;
+ (void) muteSounds;
+ (void) unmuteSounds;
+ (void) pauseMusic;

+ (void) tryToPlaySound:(soundResource)sound;

@end
