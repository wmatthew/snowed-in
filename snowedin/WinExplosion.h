//
//  WinExplosion.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/30/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import <Availability.h>
#import "cocos2d.h"

//! An explosion particle system
// This class is based on CCParticleExplosion
@interface WinExplosion : ARCH_OPTIMAL_PARTICLE_SYSTEM {}

- (void) setStartColor:(ccColor3B)color;
- (void) setEndColor:(ccColor3B)color;

- (void) setWinBoxLevelDefaults:(ccColor3B) color;
- (void) setMenuScreenWinSprayDefaults;

@end
