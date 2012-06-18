//
//  ProgressSnowman.m
//  Snowed In!!
//
//  Created by Matthew Webber on 11/11/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.

#import "ProgressSnowman.h"
#import "WinExplosion.h"
#import "Art.h"
#import "SquidLog.h"

@implementation ProgressSnowman

static NSMutableDictionary *_thresholdDictionary;
static NSMutableArray *_milestoneArray;
static NSMutableDictionary *_imageDictionary;
static NSMutableDictionary *_displayNames;

+ (void) initialize {
    _thresholdDictionary = [[NSMutableDictionary dictionary] retain];
    _milestoneArray = [[NSMutableArray array] retain];
    _imageDictionary = [[NSMutableDictionary dictionary] retain];
    _displayNames = [[NSMutableDictionary dictionary] retain];
    
    // Must be set in increasing order
    [self setThreshold:progressBall1   at:0];
    [self setThreshold:progressBall2   at:10];
    [self setThreshold:progressBall3   at:20];
    [self setThreshold:progressEyes    at:25];
    [self setThreshold:progressHat     at:30];
    [self setThreshold:progressCarrot  at:35];
    [self setThreshold:progressMouth   at:40];
    // -- 40
    [self setThreshold:progressArms    at:45];
    [self setThreshold:progressButtons at:72];
    // -- 72
    [self setThreshold:progressJoy     at:77];
    [self setThreshold:progressFlurry  at:104];
    
    [self setImage:img_progress_ball1   forProgress:progressBall1];
    [self setImage:img_progress_ball2   forProgress:progressBall2];
    [self setImage:img_progress_ball3   forProgress:progressBall3];
    [self setImage:img_progress_hat     forProgress:progressHat];
    [self setImage:img_progress_eyes    forProgress:progressEyes];
    [self setImage:img_progress_carrot  forProgress:progressCarrot];
    [self setImage:img_progress_mouth   forProgress:progressMouth];
    [self setImage:img_progress_arms    forProgress:progressArms];
    [self setImage:img_progress_buttons forProgress:progressButtons];
    [self setImage:img_progress_joy     forProgress:progressJoy];
    
    [self setDisplayName:@"Bot Snowball" forProgress:progressBall1];
    [self setDisplayName:@"Mid Snowball" forProgress:progressBall2];
    [self setDisplayName:@"Top Snowball" forProgress:progressBall3];
    [self setDisplayName:@"Stovepipe Hat" forProgress:progressHat];
    [self setDisplayName:@"Charcoal Eyes" forProgress:progressEyes];
    [self setDisplayName:@"Carrot Nose" forProgress:progressCarrot];
    [self setDisplayName:@"Mouth" forProgress:progressMouth];
    [self setDisplayName:@"Arms" forProgress:progressArms];
    [self setDisplayName:@"Buttons" forProgress:progressButtons];
    [self setDisplayName:@"Joy" forProgress:progressJoy];
    [self setDisplayName:@"Victory Flurry" forProgress:progressFlurry];
}

+ (NSString*) getDisplayNameForProgress:(snowBuildProgress)progress {
    return [_displayNames objectForKey:[NSNumber numberWithInt:progress]];
}

+ (void) setDisplayName:(NSString*)name forProgress:(snowBuildProgress)progress {
    [_displayNames setObject:name forKey:[NSNumber numberWithInt:progress]];
}

+ (void) setImage:(artResource)image forProgress:(snowBuildProgress)progress {
    [_imageDictionary setObject:[NSNumber numberWithInt:image] forKey:[NSNumber numberWithInt:progress]];
}

+ (void) setThreshold:(snowBuildProgress)progress at:(int)numLevels {
    [_milestoneArray addObject:[NSNumber numberWithInt:progress]];
    [_thresholdDictionary setObject:[NSNumber numberWithInt:numLevels] forKey:[NSNumber numberWithInt:progress]];
}

+ (NSString*) getNextMilestoneName:(int)numCompleted {
    for (NSNumber *thresholdNum in _milestoneArray) {
        int minimumNeeded = [[_thresholdDictionary objectForKey:thresholdNum] intValue];
        if (numCompleted < minimumNeeded) {
            return [self getDisplayNameForProgress:[thresholdNum intValue]];
        }
    }
    [SquidLog warn:@"No next milestone in getNextMilestoneName"];
    return @"";
}

+ (int) getNextMilestoneGap:(int)numCompleted {
    for (NSNumber *thresholdNum in _milestoneArray) {
        int minimumNeeded = [[_thresholdDictionary objectForKey:thresholdNum] intValue];
        if (numCompleted < minimumNeeded) {
            return minimumNeeded - numCompleted;
        }
    }
    return 0;
}

+ (snowBuildProgress) getProgressLevel:(int)numCompleted {    
    snowBuildProgress bestYet = progressBall1;
    
    for (NSNumber *thresholdNum in _milestoneArray) {
        int minimumNeeded = [[_thresholdDictionary objectForKey:thresholdNum] intValue];
        if (numCompleted >= minimumNeeded) {
            bestYet = [thresholdNum intValue];
        }
    }
    return bestYet;
}

+ (void) makeProgressSnowmanAt:(CGPoint)snowManCenter completed:(int)numCompleted parent:(CCLayer*)parentLayer {
    snowBuildProgress overallProgress = [ProgressSnowman getProgressLevel:numCompleted];

    switch (overallProgress) {
        case progressFlurry: {
            WinExplosion *_winEmitter = [WinExplosion node];
            [_winEmitter setMenuScreenWinSprayDefaults];
            [_winEmitter setPosition:snowManCenter];
            [parentLayer addChild:_winEmitter z:-1];
        }
        case progressJoy:
            [self addMilestoneImage:progressJoy at:snowManCenter parent:parentLayer];
            break;
            
        default:
            for (NSNumber *thresholdNum in _milestoneArray) {
                int minimumNeeded = [[_thresholdDictionary objectForKey:thresholdNum] intValue];
                if (numCompleted >= minimumNeeded) {
                    [self addMilestoneImage:[thresholdNum intValue] at:snowManCenter parent:parentLayer];
                }
            }
    }
}

+ (void) addMilestoneImage:(snowBuildProgress)milestone at:(CGPoint)pos parent:(CCLayer*)parent {
    NSNumber *milestoneNum = [NSNumber numberWithInt:milestone];
    artResource image = [[_imageDictionary objectForKey:milestoneNum] intValue];
    CCSprite *sprite = [Art sprite:image];
    [sprite setPosition:pos];
    int depth = [[_thresholdDictionary objectForKey:milestoneNum] intValue];
    [parent addChild:sprite z:depth];
}

@end
