//
//  Snowfall.m
//  Snowed In!!
//
//  Created by Matthew Webber on 7/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "Snowfall.h"
#import "Dimensions.h"
#import "Art.h"

@implementation Snowfall

- (id) init {
    
    // TODO- reduce this number? will it slow stuff down?
    int numParticles = [Dimensions isIPad] ? 300 : 1200;
    
    if (( self = [super initWithTotalParticles:numParticles] )) { 
        self.texture = [Art texture:sm_fire];
        self.startSize *= [Dimensions doubleForIpad];
        self.startSizeVar *= [Dimensions doubleForIpad];
    }
    return self;
}

@end
