//
//  GroupButton.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "GroupButton.h"
#import "boxpusher.h"

@implementation GroupButton

- (id) init {
    if (( self = [super init] )) {
        _basicSprite = [Art sprite:sm_houseBase];
        _selectedSprite = [Art sprite:sm_houseBase];

        _menuImage = [CCMenuItemImage itemFromNormalSprite:_basicSprite selectedSprite:_selectedSprite target:self selector:@selector(hitButton:)];
        _menuImage.scale = [self butScale];
        if ([Dimensions isIPad]) {
            // Houses are bigger on iPad and there are problems with hit tests.
            // scale down the tap target to (kinda) deal with this.
            _menuImage.scale *= 0.6;
        }
    }
    return self;
}

- (float) butScale {
    return [Dimensions isIPad] ? 0.8 : 0.5;
}

+ (GroupButton*) makeButton:(levelGroup)group orientation:(ButtonOrientation*)orient parent:(CCLayer*)parent menu:(CCMenu*)menu menuDepth:(int)menuDepth {

    GroupButton *newBut = [[[GroupButton alloc] init] autorelease];
    [newBut setGroup:group];

    [menu addChild:[newBut getMenuImage] z:-menuDepth];
    [orient applyToNode:[newBut getMenuImage] pos:YES rot:NO];
    [parent addChild:newBut z:depthHouseImagery]; // defined in main menu!
    [orient applyToNode:newBut pos:YES rot:NO];

    [newBut drawGroup];
    [newBut drawLabel];

    [newBut setAnchorPoint: CGPointZero];
    
    [orient applyToNode:newBut pos:NO rot:YES];
    [orient applyToNode:[newBut getMenuImage] pos:NO rot:YES];

    // Set colors
    [newBut setHouseColors];
    return newBut;
}

- (void) setHouseColors {
    _basicSprite.visible = NO;
}

- (void) setGroup:(levelGroup)group {
    _myGroup = group;
}

- (void) drawGroup {

    //============================
    // Draw House Itself
    
    _baseSprite = [Art sprite:sm_houseBase];
    _baseSprite.scale = [self butScale];
    _baseSprite.color = [HousePainter getBaseColor:_myGroup];
    [self addChild:_baseSprite z:depthHouseTrim];
    
    _trimSprite = [Art sprite:sm_houseTrim];
    _trimSprite.scale = [self butScale];
    _trimSprite.color = [HousePainter getTrimColor:_myGroup];
    [self addChild:_trimSprite z:depthHouseTrim];

    _roofSprite = [Art sprite:sm_houseRoof];
    _roofSprite.scale = [self butScale];
    [self addChild:_roofSprite z:depthHouseRoof];

    int numCompleted = [LevelManager getCompletedLevelsInGroup:_myGroup];
    
    if (numCompleted == 1) {
        _lightSnowSprite = [Art sprite:sm_houseLightSnow];
        _lightSnowSprite.scale = [self butScale];
        [self addChild:_lightSnowSprite z:depthLightSnow];
    } else if (numCompleted > 1) {    
        _heavySnowSprite = [Art sprite:sm_houseHeavySnow];
        _heavySnowSprite.scale = [self butScale];
        [self addChild:_heavySnowSprite z:depthHeavySnow];
    }
        
    //===============================
    // Draw Windows
    float BUTTON_SIZE_X = [Dimensions isIPad] ? 75 : 23; // horiz space between windows
    float BUTTON_SIZE_Y = [Dimensions isIPad] ? 51 : 16;
    
    int size = [LevelManager getLevelGroupSizeRoot:_myGroup];
    CGPoint basePositionPx = [Dimensions isIPad] ? ccp(-2, -36) : ccp(-1, -11.5);
    CGPoint upperLeftOffset = ccp(-BUTTON_SIZE_X * (size - 1) / 2,BUTTON_SIZE_Y * (size - 1) / 2);

    CGPoint offset = ccpAdd(basePositionPx, upperLeftOffset);
    int index = 0;
    for (NSNumber* number in [LevelManager getLevelsIn:_myGroup]) {
        int i = index % size;
        int j = index / size;
        CGPoint myOffset = ccpAdd(offset, ccp(i * BUTTON_SIZE_X, - j * BUTTON_SIZE_Y));
        CCSprite *blank = [Art sprite:sm_soft_square];
        int levelState = [BoxStorageLevels getLevelState:[number intValue]];
        
        if (levelState == LEVEL_LOCKED) {
            blank.color = ccBLACK;
        } else if (levelState == LEVEL_READY) {
            blank.color= ccGRAY;
        } else {
            blank.color = ccWHITE;
        }
        
        blank.scale = [Dimensions isIPad] ? 0.8 : 0.5;
        [blank setPosition:myOffset];
        [self addChild:blank z:depthHouseWindows];
        index ++;
    }
}

- (void) drawLabel {
    bool DRAW_HOUSE_LABELS_HACK = NO; // Should be set to NO normally.
    if (DRAW_HOUSE_LABELS_HACK) {
        [SquidLog warn:@"Draw house labels- debug only."];
        CCLabelTTF *label = [CCLabelTTF labelWithString:[LevelManager getGroupDisplayTitle:_myGroup] fontName:[BoxFont getDefaultFont] fontSize:15];
        [label setPosition:ccp(0,15)];
        [label setColor:ccBLACK];
        [self addChild:label z:100];
    }

    // Only do this for first group... because it's annoying.
    if (_myGroup == groupIntro && [SquidStorageLevels getLevelState:[BoxStorageLevels getFirstLevelID]] == LEVEL_READY) {
        
        float timeBeforeFade = 15;
        
        // draw moving arrow and add text
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Tap Here" fontName:[BoxFont getDefaultFont] fontSize:20 * [Dimensions doubleForIpad]];
        [label2 setPosition:ccp([Dimensions isIPad] ? -300 : -135, 0 )];
        [self addChild:label2];
        label2.opacity = 0;
        [label2 runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:timeBeforeFade],
          [CCFadeIn actionWithDuration:1],
          nil]
         ];

        CCSprite *arrow = [Art sprite:sm_left_arrow];
        arrow.scale *= 0.2;
        arrow.opacity = 0;
        arrow.rotation = 180;
        [arrow setPosition:ccp([Dimensions isIPad] ? -170 : -70, 0)];
        [self addChild:arrow];
        
        [arrow runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:timeBeforeFade],
          [CCFadeIn actionWithDuration:1],
          nil]
         ];
        
        [arrow runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCMoveBy actionWithDuration:0.5 position:ccp(10 * [Dimensions doubleForIpad], 0)],
           [CCMoveBy actionWithDuration:0.5 position:ccp(-10 * [Dimensions doubleForIpad], 0)],
           nil]]
         ];
    }
}

- (void) hitButton:(id)sender {
    [BoxMusic tryToPlaySound:press_sound];
    [BoxStorageLevels setCurrentLevelGroup:_myGroup];
    [Scene_Generic_BoxPusher goToNextScene:[Scene_Group node]];
}

@end

