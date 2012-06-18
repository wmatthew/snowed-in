//
//  Scene_MainMenu.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/25/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "Scene_MainMenu.h"
#import "Art.h"
#import "boxpusher.h"
#import "cocos2d.h"
#import "RootViewController.h"
#import "ProgressSnowman.h"

@implementation Scene_MainMenu

+ (void) initialize {
    // Cache images now so app is faster.
    [Art precacheCommonImages];
}

- (float) getSnowHeightPx:(snowHeight)height {
    if ([Dimensions isIPad]) {
        switch (height) {
            case snowHeightMin:
                return -190;
            case snowHeightMax:
                return -140;
            case snowHeightFull:
                return -90;
        }    
    }

    // iPhone/iPod touch
    switch (height) {
        case snowHeightMin:
            return -100;
        case snowHeightMax:
            return -75;
        case snowHeightFull:
            return -50;
    }
}

-(id) init
{
	if ((self = [super init])) {

        [LevelManager checkAllLevels];
        
        [BoxMusic tryToPlayMenuMusic];

        [self addChild:[HUD_Menu getNewHUD:configMainMenu withScene:self] z:10];

        bool VERSION_TITLE_HACK = NO;
        if (VERSION_TITLE_HACK) {
            [SquidLog warn:@"Showing version title- this should be dev only."];
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSString *titleString = [NSString stringWithFormat:@"version %@", version];
            [self addLabelAt:ccp(0.5,0.9) text:titleString fontSize:36];
        }
        
        // Add Trunks
        _contentLayer = [CCLayer node];
        [self addChild:_contentLayer z:2];

        _signMenu = [CCMenu menuWithItems: nil];
        _signMenu.position = CGPointZero;
        [_contentLayer addChild:_signMenu z:depthSignMenu];        

        _houseMenu = [CCMenu menuWithItems: nil];
        _houseMenu.position = CGPointZero;
        [_contentLayer addChild:_houseMenu z:depthHouseMenu];        

        float pageCenterX = 0.5;
        
        NSArray *_packsToDisplay = [LevelManager getAllPacks];
        for (NSNumber *currentPackContainer in _packsToDisplay) {

            levelPack currentPack = [currentPackContainer intValue];
            
            // Draw the houses
            [self drawPack:currentPack atOffset:pageCenterX];

            // Useful stats
            int numTotal = [LevelManager getTotalNumberOfLevelsInPack:currentPack];
            int numCompleted = [LevelManager getCompletedLevelsInPack:currentPack];

            CGPoint bigSignPos = ccp(pageCenterX+0.25, 0.43);
            CGPoint littleSignPos = ccp(pageCenterX+0.32, 0.25);
            
            //==========================================
            // Draw Signs
            NSNumber *firstPlayable = [LevelManager getFirstPlayableLevelInPack:currentPack];
            if (firstPlayable != nil) {

                // Details about the playable level.
                NSString *subtitle = [NSString stringWithFormat:@"%i / %i complete", numCompleted, numTotal];

                [self drawMainSign:[LevelManager getPackDisplayTitle:currentPack]
                          subtitle:subtitle 
                                at:bigSignPos
                            action:[SignAction make:actionPlayNextLevel pack:currentPack]];

                [self drawSignHelper:img_sign_box at:littleSignPos action:[SignAction make:actionPlayNextLevel pack:currentPack] post:postNone];
                [self drawSignText:@"Next:" at:ccp(pageCenterX+0.26, 0.28) fontSize:16]; // off-center; offset to left
                [BoxLevel loadLevel:[firstPlayable intValue]];
                [self drawSignText:[BoxLevel getTitle] at:ccp(pageCenterX+0.32, 0.24) fontSize:20];

            } else if ([LevelManager areAllLevelsLockedInPack:currentPack]) {

                // Details about why everything is locked
                NSString *subtitle = [NSString stringWithFormat:@"%i levels", numTotal];

                if ([Purchases didUserBuyLevelPack:currentPack]) {
                    
                    // It's unlocked but not ready yet; need to finish earlier levels first.
                    [self drawMainSign:[LevelManager getPackDisplayTitle:currentPack] 
                              subtitle:subtitle
                                    at:bigSignPos
                                action:[SignAction make:actionNextHill pack:currentPack]];

                    [self drawSignHelper:img_sign_box at:littleSignPos action:[SignAction make:actionNextHill pack:currentPack] post:postNone];
                    [self drawSignText:@"Locked" at:ccp(pageCenterX+0.32, 0.27) fontSize:20];
                    [self drawSignText:@"Try Later" at:ccp(pageCenterX+0.32, 0.23) fontSize:14];
                } else {

                    [self drawMainSign:[LevelManager getPackDisplayTitle:currentPack]
                              subtitle:subtitle 
                                    at:bigSignPos 
                                action:[SignAction make:actionPurchasePopup pack:currentPack]];

                    [self drawSignHelper:img_sign_mini at:ccpSub(littleSignPos, ccp(0.05,0)) action:[SignAction make:actionPurchasePopup pack:currentPack] post:postNone];
                    [self drawSignText:@"Add" at:ccp(pageCenterX+0.265, 0.26) fontSize:16];
                    [self drawSignText:@"Levels" at:ccp(pageCenterX+0.265, 0.23) fontSize:16];
                }
            } else {
                
                // This level pack is complete, move along please
                NSString *subtitle = [NSString stringWithFormat:@"%i / %i complete", numCompleted, numTotal];
                [self drawMainSign:[LevelManager getPackDisplayTitle:currentPack]
                          subtitle:subtitle
                                at:bigSignPos 
                            action:[SignAction make:actionNextHill pack:currentPack]];

                if (currentPack == packHowToPlay) {
                    
                    // Make it very explicit
                    [self drawSignHelper:img_sign_right at:littleSignPos action:[SignAction make:actionNextHill pack:currentPack] post:postNone];
                    [self drawSignText:@"More Levels" at:ccp(pageCenterX+0.32, 0.276) fontSize:16];
                    [self drawSignText:@"(swipe left)" at:ccp(pageCenterX+0.32, 0.236) fontSize:16];
                } else {
                    
                    [self drawSignHelper:img_sign_right at:littleSignPos action:[SignAction make:actionNextHill pack:currentPack] post:postNone];
                    [self drawSignText:@"Onward!" at:ccp(pageCenterX+0.32, 0.256) fontSize:16];
                }
            }

            //==========================================
            // Upgrades
            if (currentPack == packHowToPlay) {
                if (numCompleted == numTotal) {
                    float upgradeHeight = [Dimensions isIPad] ? 0.20 : 0.24;
                    [self drawSignHelper:img_sign_mini 
                                      at:ccp(pageCenterX-0.35, upgradeHeight)
                                  action:[SignAction make:actionPurchasePopup pack:currentPack]
                                    post:postStraight];
                    [self drawSignText:@"Upgrades" at:ccp(pageCenterX-0.355,upgradeHeight) fontSize:16];
                }
            }
            
            pageCenterX += 1.0f;
        }    

        _viewWidth = [[CCDirector sharedDirector] winSize].width;
        _pagesOfContent = [_packsToDisplay count] + 1; // +1 for overall progress screen
        _contentWidth = _viewWidth * _pagesOfContent;
        _scrollableWidth = _contentWidth - _viewWidth;
        
        // Dragging
        self.isTouchEnabled = YES;

        // Center on the proper pack.
        levelPack userFocusPack = [BoxStorageLevels getCurrentLevelPack];
        float xPosPx = [[LevelManager getAllPacks] indexOfObject:[NSNumber numberWithInt:userFocusPack]] * _viewWidth;
        [MenuScrollController reset:_scrollableWidth centerAt:xPosPx];
        [MenuScrollController addNode:_contentLayer movementSpeed:1.0f];
        
        [self addSnowAtDepth:-8 withSpeed:0.1f];
        [self addSnowAtDepth:-7 withSpeed:0.3f];
        [self addSnowAtDepth:-6 withSpeed:0.5f];
        [self addSnowAtDepth:-5 withSpeed:0.7f];
        [self addSnowAtDepth:-4 withSpeed:0.9f];
        [self addSnowAtDepth: 4 withSpeed:1.1f];
        [self addSnowAtDepth: 5 withSpeed:1.3f];

        CCLayer *hillLayer = [self addHillLayer];
        [self addOverallProgressHill];
        [MenuScrollController addNode:hillLayer movementSpeed:1.0f];

        [self addMountains];
        
        [self schedule:@selector(dragTick:) interval:0.02f];        
        [self dragTick:0.02f]; // do this to avoid flicker.
    }
	return self;
}

- (void) drawMainSign:(NSString*)title subtitle:(NSString*)subtitle at:(CGPoint)pos action:(SignAction*)action {
    [self drawSignHelper:img_sign_big at:pos action:action post:postCurvy];
    
    CCLabelTTF *mainLabel = [self drawSignText:title at:ccpAdd(pos, ccp(0, 0.03)) fontSize:28];
    mainLabel.rotation = -5;

    [self drawSignText:subtitle at:ccpAdd(pos, ccp(-0.01, -0.05)) fontSize:18];
}

- (void) drawSignHelper:(artResource)image at:(CGPoint)pos action:(SignAction*)action post:(signPostType)post {
    [SignArtist drawSign:image at:pos action:action parent:_contentLayer menu:_signMenu post:post delegate:self];
}

- (void) tappedSign:(id)sender {
    [BoxMusic tryToPlaySound:press_sound];    

    CCMenuItemImage* image = (CCMenuItemImage*)sender;
    SignAction *theAction = (SignAction*)image.userData;
    if (theAction == nil) {
        [SquidLog warn:@"Sender has no action. Doing nothing."];
        return;
    }
    signActionType actionType = [theAction getActionType];
    
    switch (actionType) {
        case actionPurchasePopup: 
        {
            [BoxStorageLevels setCurrentLevelPack:[theAction getPack]];
            purchasableThing thing = [[BoxProduct getProductFromPack:[theAction getPack]] purchaseEnum];
            [PurchasePopup showPopup:self andFocusOn:thing];
            break;
        }
        case actionNextHill:
            [MenuScrollController bumpOneScreenRight];    
            break;
        case actionJumpLeft:
            [MenuScrollController bumpHardLeft];    
            break;
        case actionPlayNextLevel: 
        {
            [BoxStorageLevels setCurrentLevelPack:[theAction getPack]];
            NSNumber *nextLevel = [LevelManager getFirstPlayableLevelInPack:[theAction getPack]];
            if (nextLevel != nil) {
                [BoxMusic tryToPlaySound:press_sound];
                [BoxStorageLevels setCurrentLevelID:[nextLevel intValue]];
                [Scene_Generic_BoxPusher goToNextScene:[Scene_Play node]];
            } else {
                [SquidLog warn:@"tappedSign: no next level. Going to next screen instead."];
                [MenuScrollController bumpOneScreenRight];
            }    
            break;
        }
        case actionGoMainMenu:
        case actionPlayThisLevel:
            [SquidLog warn:@"didn't expect this action in the main menu! doing nothing."];
            break;
    }
}

- (CCLabelTTF*) drawSignText:(NSString*)signText at:(CGPoint)pos fontSize:(float)size {
    return [SignArtist drawSignText:signText at:pos fontSize:size parent:_contentLayer];
}

- (void) drawPack:(levelPack)pack atOffset:(float)offset {
    
    NSArray *groupsOnCurrentPage = [LevelManager getLevelGroupsInPack:pack];

    NSArray *orientations = [self getOrientations:[groupsOnCurrentPage count]];
        
    for (int i=0; i<[groupsOnCurrentPage count]; i++) {
        levelGroup group = [[groupsOnCurrentPage objectAtIndex:i] intValue];
        ButtonOrientation *orient = [orientations objectAtIndex:i];
        CGPoint offsetPos = ccp(offset, 0.5);
        [orient addOffset:offsetPos];
        [GroupButton makeButton:group orientation:orient parent:_contentLayer menu:_houseMenu menuDepth:i];
    }
}

- (NSArray*) getOrientations:(int) houseCount {
    NSMutableArray *orientations = [NSMutableArray array];
    
    if ([Dimensions isIPad]) {
        switch (houseCount) {
            case 1:
                [orientations addObject:[ButtonOrientation make:ccp(-.03,.22) rot: -4]];
                break;
            case 2:
                [orientations addObject:[ButtonOrientation make:ccp(-.13, .19) rot: -25]];
                [orientations addObject:[ButtonOrientation make:ccp(.14, .15) rot: 25]];
                break;
            case 3:
                [orientations addObject:[ButtonOrientation make:ccp(-.31,-.05) rot: -60]];
                [orientations addObject:[ButtonOrientation make:ccp(-0.1,   .21) rot: -20]];
                [orientations addObject:[ButtonOrientation make:ccp(.2, 0.13) rot: 35]];
                break;
            case 8:
                // Since houses overlap, they're presented in depth order low to high.
                // Order of houses on hill from left to right 1...7
                [orientations addObject:[ButtonOrientation make:ccp(-.08,.18) rot: -15]]; // 3
                
                [orientations addObject:[ButtonOrientation make:ccp(0.16,.11) rot: 30]]; // 4            
                [orientations addObject:[ButtonOrientation make:ccp(-.37,-0.22) rot: 0]]; // 1
                [orientations addObject:[ButtonOrientation make:ccp(-.25, 0.03) rot: -45]]; // 2
                
                [orientations addObject:[ButtonOrientation make:ccp(0.01,0.0) rot: 0]]; // center right
                
                [orientations addObject:[ButtonOrientation make:ccp(-.1, -.12) rot: -15]]; // center left
                
                [orientations addObject:[ButtonOrientation make:ccp(-.22, -.25) rot:-10]]; // bottom left
                [orientations addObject:[ButtonOrientation make:ccp( .12, -.25) rot: 10]]; // bottom right
                break;
            default:
                [SquidLog error:@"Unrecognized pack size: %i", houseCount];
        }

    } else { // iPhone/iPod touch  
        switch (houseCount) {
            case 1:
                [orientations addObject:[ButtonOrientation make:ccp(0,.12) rot: -3]];
                break;
            case 2:
                [orientations addObject:[ButtonOrientation make:ccp(-.12, .1) rot: -20]];
                [orientations addObject:[ButtonOrientation make:ccp(.13, .1) rot: 15]];
                break;
            case 3:
                [orientations addObject:[ButtonOrientation make:ccp(-.26,-.05) rot: -60]];
                [orientations addObject:[ButtonOrientation make:ccp(0,   .1) rot: -7]];
                [orientations addObject:[ButtonOrientation make:ccp(.23, 0.05) rot: 35]];
                break;
            case 8:
                // Since houses overlap, they're presented in depth order low to high.
                // Order of houses on hill from left to right 1...7
                [orientations addObject:[ButtonOrientation make:ccp(-.03,.11) rot: -5]]; // 3
                
                [orientations addObject:[ButtonOrientation make:ccp(0.16,.06) rot: 30]]; // 4            
                [orientations addObject:[ButtonOrientation make:ccp(-.37,-0.22) rot: -25]]; // 1
                [orientations addObject:[ButtonOrientation make:ccp(-.18, 0.02) rot: -35]]; // 2
                
                [orientations addObject:[ButtonOrientation make:ccp(0.01,-.1) rot: 0]]; // center right
                
                [orientations addObject:[ButtonOrientation make:ccp(-.15, -.13) rot: -15]]; // center left
                
                [orientations addObject:[ButtonOrientation make:ccp(-.22,  -.25) rot:-10]]; // bottom left
                [orientations addObject:[ButtonOrientation make:ccp( .12, -.25) rot: 10]]; // center right
                break;
            default:
                [SquidLog error:@"Unrecognized pack size: %i", houseCount];
        }
    }
    
    if ([orientations count] != houseCount) {
        [SquidLog error:@"Pack size mismatch: %i %i", [orientations count], houseCount];
    }
    
    return orientations;
}

- (void) addMountains {
    CCSprite *mountains = [Art sprite:img_mountains];
    [self addChild:mountains z:-20];
    CGPoint pos = [Dimensions screenMiddlePx];
    [mountains setPosition:pos];
}

- (void) addOverallProgressHill {

    int pageIndex = [[LevelManager getAllPacks] count];
    float pageCenterX = pageIndex + 0.5;

    int numCompleted = [LevelManager getCompletedLevelsOverall];
    int numTotal = [LevelManager getTotalNumberOfLevelsOverall];
    
    SignAction *jumpBack = [SignAction make:actionJumpLeft pack:packHowToPlay];

    // Sign explaining progress so far
    NSString *subtitle = [NSString stringWithFormat:@"%i/%i complete", numCompleted, numTotal];
    NSString *title = @"Progress";
    
    if (numCompleted == numTotal) {
        title = @"You Win!";
        // keep subtitle the same
    }
    
    [self drawMainSign:title
              subtitle:subtitle 
                    at:ccp(pageCenterX + 0.25, 0.43)
                action:jumpBack];
    
    int nextGap = [ProgressSnowman getNextMilestoneGap:numCompleted];
    if (nextGap > 0) {
        [self drawSignHelper:img_sign_box at:ccp(pageCenterX + 0.25, 0.25) action:jumpBack post:postNone];
        
        [self drawSignText:[NSString stringWithFormat:@"Win %i more", nextGap] at:ccp(pageCenterX + 0.25, 0.285) fontSize:14];
        [self drawSignText:[NSString stringWithFormat:@"%@ to get:", (nextGap == 1) ? @"level" : @"levels"] at:ccp(pageCenterX + 0.25, 0.255) fontSize:14];
        [self drawSignText:[ProgressSnowman getNextMilestoneName:numCompleted] at:ccp(pageCenterX + 0.25, 0.225) fontSize:14];
    }

    // Hill and snowman
    float progressLevel = 1.0f * numCompleted / numTotal;
    [self addOneHillAt:pageIndex snowLevel:progressLevel];
    
    CGPoint snowManCenter = [Dimensions convertScreensToPxWidthCentric:ccp(pageCenterX - 0.05, 0.55)];
    CCLayer *snowManLayer = [[[CCLayer alloc] init] autorelease];
    [ProgressSnowman makeProgressSnowmanAt:snowManCenter completed:numCompleted parent:snowManLayer];
    [_contentLayer addChild:snowManLayer];
}


- (CCLayer*) addHillLayer {
    
    _hillLayer = [[CCLayer alloc] init];

    NSArray *_packsToDisplay = [LevelManager getAllPacks];
    for (int index=0; index<[_packsToDisplay count]; index++) {
        levelPack currentPack = [[_packsToDisplay objectAtIndex:index] intValue];

        float numTotal = [LevelManager getTotalNumberOfLevelsInPack:currentPack];
        float numCompleted = [LevelManager getCompletedLevelsInPack:currentPack];
        float snowLevel = numCompleted / numTotal;
        [self addOneHillAt:index snowLevel:snowLevel];
    }

    [self addChild:_hillLayer z:1];
    return _hillLayer;
}

- (void) addOneHillAt:(int)pageIndex snowLevel:(float)snowLevel {
    bool addSplotches = NO;
    float snowHeightPx = [self getSnowHeightPx:snowHeightMin];
    ccColor3B snowWhite = ccWHITE; // if you change this, change house images elsewhere to match (eg GroupButton)
    ccColor3B hillColor = snowWhite;

    if (snowLevel == 0) {
        hillColor = ccc3(111,156,75); // green
    } else if (snowLevel <= 0.25) {
        hillColor = ccc3(111,156,75); // green
        addSplotches = YES;
    } else if (snowLevel < 1) {
        // Snow gets progressively deeper
        float fraction = (snowLevel - 0.25) / 0.75;
        snowHeightPx = [self getSnowHeightPx:snowHeightMin] + fraction * ([self getSnowHeightPx:snowHeightMax] - [self getSnowHeightPx:snowHeightMin]);
    } else {
        if (snowLevel != 1.0) {
            [SquidLog warn:@"Unexpected snow level: %f", snowLevel];
        }
        snowHeightPx = [self getSnowHeightPx:snowHeightFull];
    }
    
    CCSprite *currentHill = [Art sprite:img_hill];
    currentHill.color = hillColor;
    
    CGPoint middleOfCurrentScreen = ccpAdd([Dimensions screenMiddlePx], ccpMult(ccp(_viewWidth, 0), pageIndex));
    CGPoint vertOffsetPx = ccp(10, snowHeightPx);
    CGPoint hillPosition = ccpAdd(middleOfCurrentScreen, vertOffsetPx);
    
    [currentHill setPosition:hillPosition];
    [_hillLayer addChild:currentHill z:-pageIndex * 2]; // early hills are higher
    
    if (addSplotches) {
        CCSprite *splotches = [Art sprite:img_hill_patches];
        splotches.color = snowWhite;
        [splotches setPosition:hillPosition];
        [_hillLayer addChild:splotches z:-pageIndex * 2 + 1];            
    }

}

- (void) addSnowAtDepth:(int)depth withSpeed:(float)movementSpeed {

    float viewWidth = [[CCDirector sharedDirector] winSize].width;
    float effectiveWidth = _viewWidth + _scrollableWidth * movementSpeed;
    
    Snowfall *emitter = [Snowfall node];
    emitter.startSize *= (0.6 + movementSpeed / 2);
    emitter.startSizeVar *= movementSpeed ;
    [SquidLog debug:@"Snow Size %f (var %f)", emitter.startSize, emitter.startSizeVar];
    emitter.positionType = kCCPositionTypeGrouped; // keeps them tied to emitter pos - MW
    emitter.position = (CGPoint) {
        effectiveWidth / 2,
        [[CCDirector sharedDirector] winSize].height + 10
    };
    emitter.posVar = ccp( viewWidth + effectiveWidth / 2, 0 ); 
    [self addChild:emitter z:depth];
    [MenuScrollController addNode:emitter movementSpeed:movementSpeed];
}

- (void) ccTouchesBegan: (NSSet *)touches withEvent: (UIEvent *)event {
    [MenuScrollController ccTouchesBegan:touches withEvent:event];
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [MenuScrollController ccTouchesMoved:touches withEvent:event];
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [MenuScrollController ccTouchesEnded:touches withEvent:event];
}

- (void) dragTick:(ccTime)dt {
    [MenuScrollController dragTick:dt];
}

- (void) refreshBecauseSomethingWasPurchased {
    [Scene_Generic_BoxPusher goToNextScene:[Scene_MainMenu node]];    
}

@end








