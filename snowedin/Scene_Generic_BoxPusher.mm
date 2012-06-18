//
//  Scene_Generic_BoxPusher.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/25/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "Scene_Generic_BoxPusher.h"
#import "cocos2d.h"
#import "SquidLog.h"
#import "boxpusher.h"

@implementation Scene_Generic_BoxPusher

CCSprite *_table;

+ (void) goToNextScene:(CCScene*)nextScene {
    [[CCDirector sharedDirector] replaceScene:nextScene];
}

- (void) addLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize {
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:[BoxFont getDefaultFont] fontSize:fontSize * [Dimensions doubleForIpad]];
    [label setPosition:[Dimensions convertScreensToPxHeightCentric:screenPos]];
    [self addChild:label z:15];
}

- (void) addBottomLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize {
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:[BoxFont getDefaultFont] fontSize:fontSize * [Dimensions doubleForIpad]];
    [label setPosition:[Dimensions convertScreensToPx:screenPos withConversion:bottomCentric]];
    [self addChild:label];
}

- (void) refreshBecauseSomethingWasPurchased {
    [SquidLog error:@"Not implemented"];
}

@end
