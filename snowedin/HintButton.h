//
//  HintButton.h
//  Snowed In!!
//
//  Created by Matthew Webber on 9/28/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HintEnums.h"
@class CCLayer;
@class CCLabelTTF;
@class CCSprite;
@class CCMenuItemImage;

@interface HintButton : NSObject {
    CCLabelTTF *_topLabel;
    hintType _hintType;
    CCSprite *_sprite;
}

- (id) initWithPos:(CGPoint)pos
            parent:(CCLayer*)parent
              type:(hintType)hintType
          function:(SEL)selector;

- (hintType) getHintType;
- (CCSprite*) getSprite;
+ (NSString*) getHintSizeName:(hintType)type;

- (void) setHintStatus:(hintStatus)hintStatus;

@end
