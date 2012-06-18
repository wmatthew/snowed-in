//
//  ProgressSnowman.h
//  Snowed In!!
//
//  Created by Matthew Webber on 11/11/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Art.h"

@class CCLayer, CCSprite;

@interface ProgressSnowman : NSObject

typedef enum {
    progressBall1,
    progressBall2,
    progressBall3,
    progressHat,
    progressEyes,
    progressCarrot,
    progressMouth,
    progressArms,
    progressButtons,
    progressJoy,
    progressFlurry,
} snowBuildProgress;

+ (void) initialize;    
+ (void) setThreshold:(snowBuildProgress)progress at:(int)numLevels;
+ (void) setImage:(artResource)image forProgress:(snowBuildProgress)progress;
+ (void) setDisplayName:(NSString*)name forProgress:(snowBuildProgress)progress;

+ (NSString*) getNextMilestoneName:(int)numCompleted;
+ (int) getNextMilestoneGap:(int)numCompleted;

+ (void) makeProgressSnowmanAt:(CGPoint)snowManCenter completed:(int)numCompleted parent:(CCLayer*)parentLayer;

+ (snowBuildProgress) getProgressLevel:(int)numCompleted;
+ (void) addMilestoneImage:(snowBuildProgress)milestone at:(CGPoint)pos parent:(CCLayer*)parent;

+ (NSString*) getDisplayNameForProgress:(snowBuildProgress)progress;
+ (void) setDisplayName:(NSString*)name forProgress:(snowBuildProgress)progress;

@end
