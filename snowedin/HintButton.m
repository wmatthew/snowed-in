//
//  HintButton.m
//  Snowed In!!
//
//  Created by Matthew Webber on 9/28/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "HintButton.h"
#import "boxpusher.h"

@implementation HintButton

- (id) initWithPos:(CGPoint)pos
            parent:(HintLayer*)parent
              type:(hintType)hintType
          function:(SEL)selector {
    if (( self = [super init])) {

        _hintType = hintType;
        
        _topLabel = [parent addLabelAt:CGPointMake(pos.x, pos.y+0.1)
                                  text:[HintButton getHintSizeName:hintType]
                              fontSize:12
                            conversion:widthCentric];

        _sprite = [Art sprite:sm_bulb];
        
        // Label is above button
        [_sprite setPosition:[Dimensions convertScreensToPx:pos withConversion:widthCentric]];
        _sprite.scale = 0.1 * (int)hintType;
        [parent addChild:_sprite];
        
        CCMenuItemImage *_hintImage = [parent addButtonAt:pos
                                               conversion:widthCentric
                                                 function:selector
                                                    color:ccGRAY
                                                 selColor:ccWHITE
                                            defaultSprite:[Art sprite:sm_blank]
                                           selectedSprite:[Art sprite:sm_blank]];
        
        _hintImage.tag = _hintType;
        _hintImage.scale *= 2;
    }

    return self;
}

- (hintType) getHintType {
    return _hintType;
}

- (CCSprite*) getSprite {
    return _sprite;
}

+ (NSString*) getHintSizeName:(hintType)type {
    switch (type) {
        case hintSmall: return @"Small";
        case hintMed: return @"Medium";
        case hintLarge: return @"Large";
        case hintComplete: return @"Solution";

        case hintNone:
        default:
            NSLog(@"Error, bad hint type: %i", type);
            return @"";    
    }
}

- (void) setHintStatus:(hintStatus)hintStatus {

    switch (hintStatus) {
        case hintStatusUsed:
            _sprite.color = ccWHITE;
            break;
        case hintStatusReadyToUse:
            _sprite.color = ccYELLOW;
            break;
        case hintStatusForSale:
            _sprite.color = ccBLACK;
            break;
        case hintStatusLocked:
            _sprite.color = ccBLACK;
            break;
    }
}


@end
