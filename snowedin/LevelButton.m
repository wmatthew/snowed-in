//
//  LevelButton.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/1/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "LevelButton.h"
#import "boxpusher.h"

@implementation LevelButton

- (id) init {
    if (( self = [super initBlank] )) {
            // Initialize
    }
    return self;
}

+ (LevelButton*) makeButton:(int)levelID offset:(CGPoint)offset scale:(float)scale parent:(Scene_Group*)parent menu:(CCMenu*)menu {
    
    LevelButton *newBut = [[[LevelButton alloc] init] autorelease];
    [newBut setLevelID:levelID];
    [newBut setParent:parent];
    
    [newBut getMenuImage].scale *= scale;
    [[newBut getMenuImage] setPosition:offset];
    [menu addChild:[newBut getMenuImage]];
    [newBut drawLevel:scale];

    [newBut getMenuImage].userData = [SignAction makePlayThisLevel:levelID];
    
    [newBut setPosition:offset];
    [parent addChild:newBut z:depthSignText];
    return newBut;
}

- (void) setParent:(Scene_Group*)parent {
    _parent = parent;
}

- (void) setLevelID:(int)levelID {
    _levelID = levelID;
    int levState = [SquidStorageLevels getLevelState:_levelID];
    _locked = levState == LEVEL_LOCKED;
    if (_locked) {
        [self setColors:ccc3(50,50,50) selected:ccc3(200,50,50)];
    } else if (levState == LEVEL_READY) {
        [self setColors:ccc3(125, 125, 125) selected:ccc3(175,175,175)];   // normally ccc3(200, 100, 50) + ccORANGE
        _basicSprite.opacity = 255;
    } else {
        // finished!
        [self setColors:ccWHITE selected:ccc3(200,200,200)];    
        _basicSprite.opacity = 255;
    }
}

- (void) drawLevel:(float)scale {
    
    scale *= [Dimensions doubleForIpad];
    float spriteSizePx = 200 * [Dimensions doubleForIpad];
    
    [BoxLevel loadLevel:_levelID];
    CGPoint levelSize = [BoxLevel getLevelSize];
    
    float totalSize = scale * 60;
    int maxDim = MAX(levelSize.x, levelSize.y);
    float tileSize = totalSize / maxDim;
    
    CGPoint _offset = ccp(- (levelSize.x - 1) * tileSize / 2,
                          + (levelSize.y - 1) * tileSize / 2);

    float HIDE_LINES = 1.01;

    // on non-retina displays: skip the black border
    float BLACK_BORDER = 1.4;
    bool showBlackBorder = [Dimensions isRetina] || [Dimensions isIPad];
    
    for (int i=0; i<levelSize.x; i++) {
        for (int j=0; j<levelSize.y; j++) {
            tileType type = [BoxLevel getBasicTypeAt:ccp(i,j)];
            CGPoint myOffset = ccpAdd(_offset, ccpMult(ccp(i,-j), tileSize));
            levelGroup parentGroup = [LevelManager getParentOfLevel:_levelID];
            
            if (type == tileBlock) {
                [self addSprite:[Art sprite:sm_square] at:myOffset scale:HIDE_LINES * tileSize / spriteSizePx color:[HousePainter getTrimColor:parentGroup] z:0];
                if (showBlackBorder) {
                    [self addSprite:[Art sprite:sm_square] at:myOffset scale:BLACK_BORDER * tileSize / spriteSizePx color:ccBLACK z:-1];
                }
            } else if (type == tileWall) {
                // do nothing
            } else {
                [self addSprite:[Art sprite:sm_square] at:myOffset scale:HIDE_LINES * tileSize / spriteSizePx color:[HousePainter getBaseColor:parentGroup] z:0];
                if (showBlackBorder) {
                    [self addSprite:[Art sprite:sm_square] at:myOffset scale:BLACK_BORDER * tileSize / spriteSizePx color:ccBLACK z:-1];
                }
            } 
        }
    }
}



- (void) addSprite:(CCSprite*)tileSprite at:(CGPoint)pos scale:(float)scale color:(ccColor3B)color z:(int)depth {
    [self addChild:tileSprite z:depth];
    tileSprite.scale = scale;
    
    if (_locked) {
        tileSprite.color = ccBLACK;
    } else {
        tileSprite.color = color;
    }

    [tileSprite setPosition:pos];
}

- (void) hitButton:(id)sender {
    [_parent tappedSign:[self getMenuImage]];
}

- (void) dealloc {
    if (_menuImage.userData != nil) {
        NSObject *obj = _menuImage.userData;
        [obj release];
    }
    [super dealloc];
}

@end
