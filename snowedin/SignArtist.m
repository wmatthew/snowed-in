//
//  SignArtist.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/31/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import "SignArtist.h"
#import "Art.h"
#import "boxpusher.h"

@implementation SignArtist

+ (CCMenuItemImage*) drawSign:(artResource)signImage at:(CGPoint)pos action:(SignAction*)action parent:(CCLayer*)parentLayer menu:(CCMenu*)parentMenu post:(signPostType)post  delegate:(id)delegate {
    
    if (post == postCurvy) {
        CCSprite *postSprite = [Art sprite:img_post_curve];
        postSprite.position = ccpAdd([Dimensions convertScreensToPx:pos withConversion:widthCentric], ccp(0, -[postSprite boundingBox].size.height/2));
        [parentLayer addChild:postSprite z:depthSignPost];    
    } else if (post == postStraight) {
        CCSprite *postSprite = [Art sprite:img_post_straight];
        postSprite.position = ccpAdd([Dimensions convertScreensToPx:pos withConversion:widthCentric], ccp(0, -[postSprite boundingBox].size.height/2));
        [parentLayer addChild:postSprite z:depthSignPost];    
    } else if (post == postUpsideDownStraight) {
        // Doesn't actually flip image, just moves it higher up
        CCSprite *postSprite = [Art sprite:img_post_straight];
        postSprite.position = ccpAdd([Dimensions convertScreensToPx:pos withConversion:widthCentric], ccp(0, [postSprite boundingBox].size.height/2));
        [parentLayer addChild:postSprite z:depthSignPost];        
    }
    
    CCSprite *signSprite = [Art sprite:signImage];
    CCSprite *bigSprite = [Art sprite:signImage];
    
    // Expand a bit when tapped.
    bigSprite.scale *= 1.1;
    bigSprite.position =
    ccp([signSprite boundingBox].size.width/2  - [bigSprite boundingBox].size.width/2,
        [signSprite boundingBox].size.height/2 - [bigSprite boundingBox].size.height/2);

    CCMenuItemImage *_image = [CCMenuItemImage itemFromNormalSprite:signSprite selectedSprite:bigSprite target:delegate selector:@selector(tappedSign:)];
    
    _image.userData = action;
    [_image setPosition:[Dimensions convertScreensToPx:pos withConversion:widthCentric]];
    
    [parentMenu addChild:_image];
    return _image;
}

+ (CCLabelTTF*) drawSignText:(NSString*)signText at:(CGPoint)pos fontSize:(float)size parent:(CCLayer*)parentLayer {
    CCLabelTTF *packLabel = [CCLabelTTF labelWithString:signText fontName:[BoxFont getDefaultFont] fontSize:size * [Dimensions doubleForIpad]];
    [parentLayer addChild:packLabel z:depthSignText];
    [packLabel setColor:ccc3(65,42,17)]; // Dark wood color
    [packLabel setPosition:[Dimensions convertScreensToPx:pos withConversion:widthCentric]];
    return packLabel;
}

@end
