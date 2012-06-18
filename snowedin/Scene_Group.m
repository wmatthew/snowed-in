//
//  Scene_Group.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/31/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "Scene_Group.h"
#import "cocos2d.h"
#import "boxpusher.h"
#import "Art.h"

@implementation Scene_Group

static float BUTTON_SIZE_X;
static float BUTTON_SIZE_Y;
static float ADDITIONAL_SIGN_X;

bool _showedLocked;
bool _showedComplete;
bool _showedReady;

+ (void) initialize {
    BUTTON_SIZE_X = [Dimensions isIPad] ? 288 : 144;
    BUTTON_SIZE_Y = [Dimensions isIPad] ? 194 : 97;
    ADDITIONAL_SIGN_X = [Dimensions isIPad] ? 480 : 220;
}

-(id) init {
	if ((self = [super init])) {

        [BoxMusic tryToPlayMenuMusic];
        
        _levelTitleDictionary = [[[NSMutableDictionary alloc] init] retain];
        _levelSubtitleDictionary = [[[NSMutableDictionary alloc] init] retain];
        _currentGroup = [BoxStorageLevels getCurrentLevelGroup];
        [BoxStorageLevels setCurrentLevelPack:[LevelManager getParentOfGroup:_currentGroup]];

        [self reorderChild:_genMenu z:depthSignMenu]; // move it above sign posts, etc.
        
        // sky blue background color
        CCLayerColor *sky = [[[CCLayerColor alloc] initWithColor:ccc4(118,169,234,255)] autorelease];
        [self addChild:sky z:groupDepthSky];

        [self addAllHouseImages];
        [self addAllSigns];
        
        int size = [LevelManager getLevelGroupSizeRoot:_currentGroup];
        CGPoint offset = ccpAdd([Dimensions screenMiddlePx],
                                ccp(-BUTTON_SIZE_X * (size - 1) / 2, BUTTON_SIZE_Y * (size - 1) / 2));
        int index = 0;
        for (NSNumber* number in [LevelManager getLevelsIn:_currentGroup]) {
            int i = index % size;
            int j = index / size;
            CGPoint myOffset = ccpAdd(offset, ccp(i * BUTTON_SIZE_X, - j * BUTTON_SIZE_Y));
            [LevelButton makeButton:[number intValue] offset:myOffset scale:0.78 parent:self menu:_genMenu];
            index ++;
        }
    }
    return self;
}

// We try to link to some other playable level. First try current pack, then next pack, etc. Wrap around when you reach the final pack.
- (void) addNextPlayableSign {
    NSArray *allPacks = [LevelManager getAllPacks];
    levelPack _currentPack = [LevelManager getParentOfGroup:_currentGroup];
    int myPackIndex = [allPacks indexOfObject:[NSNumber numberWithInt:_currentPack]];
    
    for (int i=0; i<[allPacks count]; i++) {
        int futurePackIndex = (i + myPackIndex) % [allPacks count];
        levelPack futurePack = [[allPacks objectAtIndex:futurePackIndex] intValue];
        NSNumber *nextPlayable = [LevelManager getFirstPlayableLevelInPack:futurePack];

        if (nextPlayable != nil) {
            [SquidLog info:@"Next Playable Level: %i", [nextPlayable intValue]];
            [SignArtist drawSign:img_sign_right
                        at:ccp(0.5,0.75) 
                    action:[SignAction makePlayThisLevel:[nextPlayable intValue]]
                    parent:self
                      menu:_genMenu
                      post:postUpsideDownStraight 
                        delegate:self];
            [self drawSignText:@"skip to next" at:ccp(0.5,0.77) fontSize:14];
            [self drawSignText:@"unfinished level" at:ccp(0.5,0.74) fontSize:14];
            return;
        }
    }
    [SquidLog warn:@"Hmm, no next playable level to show! Did user really finish game?"];
}

- (void) addAllSigns {

    // Top Center
    NSNumber *firstPlayable = [LevelManager getFirstPlayableLevelInGroup:_currentGroup];
    if (firstPlayable == nil) {
        [self addNextPlayableSign];
    }
    
    // Back to menu
    CGPoint backSignPos = [Dimensions isIPad] ? ccp(0.3,0.21) : ccp(0.3,0.25);
    
    [SignArtist drawSign:img_sign_left
                at:backSignPos 
            action:[SignAction make:actionGoMainMenu pack:[LevelManager getParentOfGroup:_currentGroup]]
            parent:self
              menu:_genMenu
              post:postStraight
     delegate:self];
    [self drawSignText:@"back" at:ccpAdd(ccp(0,0.01), backSignPos) fontSize:20];

    // Bottom right
    if (firstPlayable != nil) {
        // Play next level (here)        
    } else if ([LevelManager areAllLevelsLockedInGroup:_currentGroup]) {
        if ([Purchases didUserBuyLevelPack:[LevelManager getParentOfGroup:_currentGroup]]) {
            // This back just isn't ready yet, check back later
        } else {
            // Buy these levels
            CGPoint addLevelsPos = [Dimensions isIPad] ? ccp(0.8,0.24) : ccp(0.85,0.24);
            
            [SignArtist drawSign:img_sign_mini
                        at:addLevelsPos
                    action:[SignAction make:actionPurchasePopup pack:[LevelManager getParentOfGroup:_currentGroup]] 
                    parent:self
                            menu:_genMenu
                      post:postNone
             delegate:self];
            [self drawSignText:@"Add" at:ccpAdd(ccp(-0.005, 0.01), addLevelsPos) fontSize:16];
            [self drawSignText:@"Levels" at:ccpAdd(ccp(-0.005, -0.02), addLevelsPos) fontSize:16];
        }
    }
    
    // Level Details (4 signs)
    int size = [LevelManager getLevelGroupSizeRoot:_currentGroup];
    CGPoint center = ccp(0.5,0.5);
    int index = 0;
    for (NSNumber* number in [LevelManager getLevelsIn:_currentGroup]) {
        int i = index % size;
        int j = index / size;
        float ii = 2 * i - 1;
        float jj = 2 * j - 1;
        
        CGPoint myOffset = ccpAdd(center, ccp(ii * ((BUTTON_SIZE_X+ADDITIONAL_SIGN_X)/(2*[Dimensions screenSizePx].x)), - jj * BUTTON_SIZE_Y/(2*[Dimensions screenSizePx].x)));

        CCMenuItemImage *img = [SignArtist drawSign:img_sign_box
                                           at:myOffset
                                       action:[SignAction makePlayThisLevel:[number intValue]]
                                       parent:self 
                                         menu:_genMenu
                                         post:(j==0) ? postCurvy : postNone
                                delegate:self];
        [BoxLevel loadLevel:[number intValue]];
        
        CCLabelTTF *titleLabel = [SignArtist drawSignText:[BoxLevel getTitle] at:ccpAdd(myOffset, ccp(0,  0.02)) fontSize:20 parent:self];
        [_levelTitleDictionary setObject:titleLabel forKey:number];
        
        CCLabelTTF *difficultyLabel = [SignArtist drawSignText:[BoxLevel getDifficulty] at:ccpAdd(myOffset, ccp(0,  -0.02)) fontSize:14 parent:self];
        [_levelSubtitleDictionary setObject:difficultyLabel forKey:number];

        if ([BoxStorageLevels getLevelState:[number intValue]] == LEVEL_LOCKED) {
            img.color = ccGRAY;
        }
                                                         
        index ++;
    }
}

// TODO: this is lame, because we're undoing the widthCentric position scaling. Find a better way.
- (CCLabelTTF*) drawSignTextPx:(NSString*)signText at:(CGPoint)pos fontSize:(float)size {
    return [self drawSignText:signText at:ccpMult(pos, 1/[Dimensions screenSizePx].x) fontSize:size];
}

- (CCLabelTTF*) drawSignText:(NSString*)signText at:(CGPoint)pos fontSize:(float)size {
    return [SignArtist drawSignText:signText at:pos fontSize:size parent:self];
}

- (void) tappedSign:(id)sender {

    [BoxMusic tryToPlaySound:press_sound];

    CCMenuItemImage* image = (CCMenuItemImage*)sender;
    SignAction *theAction = (SignAction*)image.userData;
    signActionType actionType = [theAction getActionType];

    switch (actionType) {
        case actionGoMainMenu:
            [Scene_Generic_BoxPusher goToNextScene:[Scene_MainMenu node]];
            break;
        case actionPurchasePopup:
        {
            [BoxStorageLevels setCurrentLevelPack:[theAction getPack]];
            purchasableThing thing = [[BoxProduct getProductFromPack:[theAction getPack]] purchaseEnum];
            [PurchasePopup showPopup:self andFocusOn:thing];
            break;
        }         
        case actionPlayThisLevel:
        {
            if ([Purchases didUserBuyLevelPack:[theAction getPack]] == NO) {
                [BoxStorageLevels setCurrentLevelPack:[theAction getPack]];
                purchasableThing thing = [[BoxProduct getProductFromPack:[theAction getPack]] purchaseEnum];
                [PurchasePopup showPopup:self andFocusOn:thing];                
                break;
            }
            
            int nextLevelID = [theAction getLevelID];            
            if ([BoxStorageLevels getLevelState:nextLevelID] == LEVEL_LOCKED) {
                CCLabelTTF *title = [_levelTitleDictionary objectForKey:[NSNumber numberWithInt:nextLevelID]];
                [title setString:@"Locked"];
                CCLabelTTF *subtitle = [_levelSubtitleDictionary objectForKey:[NSNumber numberWithInt:nextLevelID]];
                [subtitle setString:@"Try Later"];
            } else {
                // Play the next level
                [BoxStorageLevels setCurrentLevelID:nextLevelID];
                [Scene_Generic_BoxPusher goToNextScene:[Scene_Play node]];            
            }
        }
        default:
            break;
    }
}

- (void) addAllHouseImages {
    
    [self addHouseImage:sm_big_houseBase depth:groupDepthHouse color:[HousePainter getBaseColor:_currentGroup]];
    [self addHouseImage:sm_big_houseTrim depth:groupDepthTrim color:[HousePainter getTrimColor:_currentGroup]];
    [self addHouseImage:sm_big_houseRoof depth:groupDepthRoof color:ccWHITE];

    int numCompleted = [LevelManager getCompletedLevelsInGroup:_currentGroup];
    if (numCompleted == 1) {
        [self addHouseImage:sm_big_houseLightSnow depth:groupDepthLightSnow color:ccWHITE];    
    } else if (numCompleted > 1) {
        [self addHouseImage:sm_big_houseHeavySnow depth:groupDepthHeavySnow color:ccWHITE];    
    }
}

- (void) addHouseImage:(artResource)art depth:(depthGroupScene)depth color:(ccColor3B)color {
    CCSprite *house = [Art sprite:art];
    house.color = color;

    CGPoint housePosition = [Dimensions isIPad] ? ccp(520,520) : ccp(244,228);
    [house setPosition:housePosition];
    
    [self addChild:house z:depth];
}

- (void) showPurchasePopup:(id)sender {
    levelPack _currentPack = [LevelManager getParentOfGroup:[BoxStorageLevels getCurrentLevelGroup]];
    [PurchasePopup showPopup:self andFocusOn:[[BoxProduct getProductFromPack:_currentPack] purchaseEnum]];
}

- (void) refreshBecauseSomethingWasPurchased {
    [Scene_Generic_BoxPusher goToNextScene:[Scene_Group node]];    
}

@end
