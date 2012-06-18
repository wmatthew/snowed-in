//
//  HintLayer.m
//  Snowed In!!
//
//  Created by Matthew Webber on 7/6/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "HintLayer.h"
#import "boxpusher.h"

@implementation HintLayer

NSString *ERR_LOCKED = @"that hint is locked";
NSString *ERR_ALSO_LOCKED = @"that hint is also locked";

+ (HintLayer*) makeHintLayerWithParent:(HUD_Play*)playHUD {
    HintLayer *newLayer = [[[HintLayer alloc] initHintWithColor:ccc4(55, 55, 55, 230) andHUD:playHUD] autorelease];
    [newLayer addHintSign];
    [newLayer hideHintLayer:nil];
    return newLayer;
}

- (id) initHintWithColor:(ccColor4B)color andHUD:(HUD_Play*) playHUD {
    if (( self = [super initWithColor:color] )) {
        _playHUD = playHUD;
        _hintMenu = [CCMenu menuWithItems: nil];
        [_hintMenu setPosition:CGPointZero];
        [self addChild:_hintMenu];        
        
        _biggestHintSeenYet = [BoxStorageLevels getHintLevel:[BoxStorageLevels getCurrentLevelID]]; 
        _hintButtons = [[NSMutableArray alloc] init];
        
        [self addHintButtonAt:ccp(0.2,0.5) type:hintSmall   ];
        [self addHintButtonAt:ccp(0.4,0.5) type:hintMed     ];
        [self addHintButtonAt:ccp(0.6,0.5) type:hintLarge   ];
        [self addHintButtonAt:ccp(0.8,0.5) type:hintComplete];
        [self updateHintColors];
    }
    return self;
}

- (void) addHintSign {
    CGPoint signPos = ccp(0.5,0.8);
    _signText = [self addLabelAt:signPos text:@"Want a hint?" fontSize:24 conversion:heightCentric];
}

- (void) addHintButtonAt:(CGPoint)pos type:(hintType)hintType {
    HintButton *newButton = [[[HintButton alloc] initWithPos:pos
                                                     parent:self
                                                       type:hintType
                                                   function:@selector(hintButtonPressed:)] autorelease];

    [_hintButtons addObject:newButton];
}

- (hintStatus) getHintStatus:(hintType)hintType {
    
    if (hintType <= _biggestHintSeenYet) {
        return hintStatusUsed;

    } else if ([Purchases didUserUnlockAllHintsOfType:hintType]) {
        return hintStatusReadyToUse;

    } else if ([self isFreebieHint:hintType]) {
        return hintStatusReadyToUse;
        
    } else {
        return hintStatusForSale;
    
    }
}

- (bool) isFreebieHint:(hintType)hintType {
    if (hintType == hintSmall || hintType == hintMed) {  
        int currentLevel = [BoxStorageLevels getCurrentLevelID];
        if (currentLevel == 94 || // Spinner (3rd hill)
            currentLevel == 10 || // Cat (4th hill)
            currentLevel == 51) { // Inject (5th hill)
            return YES;
        }
    }
    return NO;
}

- (CCMenuItemImage*) addButtonAt:(CGPoint)pos
                      conversion:(screenConversionType)conversion
                        function:(SEL)selector
                           color:(ccColor3B)color
                        selColor:(ccColor3B)selColor
                   defaultSprite:(CCSprite*)defaultSprite
                  selectedSprite:(CCSprite*)selectedSprite {
    
    defaultSprite.color = color;
    selectedSprite.color = selColor;
    
    CCMenuItemImage *menuImage = [CCMenuItemImage itemFromNormalSprite:defaultSprite selectedSprite:selectedSprite target:self selector:selector];
    CGPoint posPx = [Dimensions convertScreensToPx:pos withConversion:conversion];
    menuImage.scale = 0.2;
    [menuImage setPosition:posPx];
    [_hintMenu addChild:menuImage];
    return menuImage;
}

- (void) hintButtonPressed:(id)sender {
    
    if (!self.visible) {
        [SquidLog warn:@"Trying to run a hint when hint layer isn't visible?! This swallowed a tap or swipe!"];
        return;
    }

    CCMenuItemImage *source = (CCMenuItemImage*) sender;
    hintType myType = source.tag;
    hintStatus myStatus = [self getHintStatus:myType];
    
    switch (myStatus) {
        case hintStatusLocked:
            [SquidLog warn:@"Tried to buy locked hint! What does locked even mean? Falling through to purch popup."];            
        case hintStatusForSale:
            [SquidLog info:@"Clicked a hint that was for sale. Opening popup."];
            [[_playHUD getPlayScene] removeAd]; // we're going to obscure this so get rid of it first.
            [PurchasePopup showPopup:self andFocusOn:[Purchases getPurchaseableThingThatUnlocks:myType]];
            break;
            
        case hintStatusReadyToUse:
        case hintStatusUsed:

            // Update biggest hint seen yet on this level.
            if (_biggestHintSeenYet < myType) {        
                [BoxStorageLevels setHintLevel:myType forLevel:[BoxStorageLevels getCurrentLevelID]];
                _biggestHintSeenYet = myType; 
                [self updateHintColors];
            }    
            [HUD_Play prepareToRunHintSolution:myType];
            [self hideHintLayer:nil];    
            break;
    }
}

- (void) showHintLayer {
    [_playHUD interruptAutoplay];
    self.visible = YES;
    _hintMenu.visible = YES;
}

- (void) hideHintLayer:(id)sender {
    self.visible = NO;
    _hintMenu.visible = NO;
}

- (void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!self.visible) {
        return NO;
    }

    if ([_hintMenu ccTouchBegan:touch withEvent:event]) {
        [SquidLog debug:@"Hint menu button was tapped."];
        // hint menu will handle this
    } else {
        [SquidLog info:@"Stray tap. Dismissing hint layer."];
        [self hideHintLayer:nil];
    }
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!self.visible) {
        return;
    }
    [_hintMenu ccTouchEnded:touch withEvent:event];
}

// TODO: make this take, return a string.
+ (int) getHintSize:(hintType)type fullSolution:(int)fullLength {
    if (type == hintNone) {
        [SquidLog warn:@"why are we getting hint size of hintNone?"];    
    }

    int length = fullLength - 1; // one short of the end
    int hintSize = length * (type / (float)hintComplete);
    [SquidLog debug:@"Hint Trimmed: %i / %i", hintSize, length];
    return hintSize;
}

- (CCLabelTTF*) addLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize conversion:(screenConversionType)conversionType {
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:[BoxFont getDefaultFont] fontSize:fontSize * [Dimensions doubleForIpad]];
    [label setPosition:[Dimensions convertScreensToPx:screenPos withConversion:conversionType]];
    [self addChild:label z:15];
    return label;
}

- (void) updateHintColors {
    bool areAnyHintsReadyAndUnseen = NO;
    for (HintButton *button in _hintButtons) {
        hintStatus curStatus = [self getHintStatus:[button getHintType]]; 
        [button setHintStatus:curStatus];
        if (curStatus == hintStatusReadyToUse) {
            areAnyHintsReadyAndUnseen = YES;
        }
    }
    
    // if you change these colors, make sure they fit with other HUD buttons.
    if (areAnyHintsReadyAndUnseen) {
        [_playHUD setHintBulbColor:ccYELLOW];
    } else {
        [_playHUD setHintBulbColor:ccc3(100,100,100)];
    }
}

- (void) refreshBecauseSomethingWasPurchased {
    [self updateHintColors];
}

@end
