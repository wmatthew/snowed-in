//
//  WinExplosion.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/30/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import "WinExplosion.h"
#import "cocos2d.h"
#import "Dimensions.h"
#import "Art.h"

// This class is based on CCParticleExplosion
@implementation WinExplosion
-(id) init {
    int numParticles = [Dimensions isIPad] ? 500 : 1000;
	return [self initWithTotalParticles:numParticles];
}

-(id) initWithTotalParticles:(int)p {
	if( (self=[super initWithTotalParticles:p]) ) {
        
		// duration
		duration = 0.01f;
		
        self.positionType = kCCPositionTypeGrouped; // keeps them tied to emitter pos - MW
        
		self.emitterMode = kCCParticleModeGravity;
        
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
        
		// Gravity Mode: radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// Gravity Mode: tagential
		self.tangentialAccel = 0.1;
		self.tangentialAccelVar = 0;
		
		// angle
		angle = 90;
		angleVar = 360;
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 0.4f;
		lifeVar = 0.3;
		
		// size, in pixels
		startSize = 15.0f * [Dimensions doubleForIpad];
		startSizeVar = 10.0f * [Dimensions doubleForIpad];
		endSize = kCCParticleStartSizeEqualToEndSize;
        
		// emits per second
		emissionRate = totalParticles/duration;
		
		// color of particles
		startColor.r = 0.0f;
		startColor.g = 0.9f;
		startColor.b = 0.0f;
		startColor.a = 1.0f;
		startColorVar.r = 0.1f;
		startColorVar.g = 0.1f;
		startColorVar.b = 0.1f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 0.0f;
		endColorVar.r = 0.1f;
		endColorVar.g = 0.1f;
		endColorVar.b = 0.1f;
		endColorVar.a = 0.0f;
		
		self.texture = [Art texture:sm_fire];
        
		// additive
		self.blendAdditive = NO;
        
        self.autoRemoveOnFinish = YES;
        
	}
	
	return self;
}

-(void) setStartColor: (ccColor3B) color {
    startColor.r = (float)(color.r/255.0);
    startColor.g = (float)(color.g/255.0);
    startColor.b = (float)(color.b/255.0);
}

-(void) setEndColor: (ccColor3B) color {
    endColor.r   = (float)(color.r/255.0);
    endColor.g   = (float)(color.g/255.0);
    endColor.b   = (float)(color.b/255.0);
}

- (void) setWinBoxLevelDefaults:(ccColor3B) color {
    [self setStartColor:color];
    [self setEndColor:color];
    startColorVar.r = 0.0f;
    startColorVar.g = 0.0f;
    startColorVar.b = 0.0f;
    
    endColorVar.r = 0.0f;
    endColorVar.g = 0.0f;
    endColorVar.b = 0.0f;
    
    // life of particles
    life = 1.0f;
    lifeVar = 0;
        
    self.speed = 500 * [Dimensions doubleForIpad];
    self.speedVar = 60 * [Dimensions doubleForIpad]; 
    
    duration = -1; // run forever
    emissionRate = totalParticles/1.0f;
}

- (void) setMenuScreenWinSprayDefaults {
    [self setStartColor:ccWHITE];
    [self setEndColor:ccWHITE];
    startColorVar.r = 0.0f;
    startColorVar.g = 0.0f;
    startColorVar.b = 0.0f;
    
    endColorVar.r = 0.0f;
    endColorVar.g = 0.0f;
    endColorVar.b = 0.0f;
    
    // life of particles
    life = 1.0f;
    lifeVar = 0.5;
    
    self.speed = 300 * [Dimensions doubleForIpad];
    self.speedVar = 60 * [Dimensions doubleForIpad]; 
    
    duration = -1.0f; // run forever
    emissionRate = totalParticles/5.0f;
}

@end
