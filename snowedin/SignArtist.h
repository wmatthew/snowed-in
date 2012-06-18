//
//  SignArtist.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/31/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Art.h"

@class CCMenu;
@class CCLabelTTF;
@class CCLayer;
@class CCMenuItemImage;
@class SignAction;

typedef enum {
    postNone,
    postCurvy,
    postStraight,
    postUpsideDownStraight,
} signPostType;

@interface SignArtist : NSObject

+ (CCMenuItemImage*) drawSign:(artResource)signImage at:(CGPoint)pos action:(SignAction*)action parent:(CCLayer*)parentLayer menu:(CCMenu*)parentMenu post:(signPostType)post delegate:(id)delegate;

+ (CCLabelTTF*) drawSignText:(NSString*)signText at:(CGPoint)pos fontSize:(float)size parent:(CCLayer*)parentLayer;

@end
