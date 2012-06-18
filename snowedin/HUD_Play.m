//
//  HUD_Play.m
//  Snowed In!!
//
//  Created by Matthew Webber on 7/12/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "HUD_Play.h"
#import "boxpusher.h"

@implementation HUD_Play

static HUD_Play *_singleton;
const float ADJUST_POINTS_DOWN = 270;
const float ADJUST_POINTS_UP = 90;
const float ADJUST_HUD_DURATION = 0.4;

static CGPoint HUD_DOWN_POSITION;
static CGPoint HUD_UP_POSITION;
static CGPoint HUD_EXTRA_UP_POSITION;

+ (void) initialize {
    HUD_DOWN_POSITION = [Dimensions isIPad] ? ccp(0,-130) : ccp(0,-64);
    HUD_UP_POSITION = ccp(0,0);
    HUD_EXTRA_UP_POSITION = [Dimensions isIPad] ? ccp(0,28) : ccp(0,15);
}

+ (HUD_Play*) getNewHUD:(hudConfiguration)config withScene:(Scene_Generic_BoxPusher*)scene {
    _singleton = [[HUD_Play alloc] initWithConfig:config scene:scene];
    return _singleton;
}

+ (HUD_Play*) getOldHUD {
    return _singleton;
}

- (id) initWithConfig:(hudConfiguration)config scene:(Scene_Generic_BoxPusher*)scene{
    if (( self = [super init] )) {
        
        if (config != configLevel) {
            [SquidLog error:@"HUD config not recognized: %i", config];
        }

        _hudState = stateDefault;

        _isTutorialLevel = [LevelManager isTutorialGroup:[BoxStorageLevels getCurrentLevelGroup]];
        _scene = scene;

        _hudMenu = [CCMenu menuWithItems: nil];
        [_hudMenu setPosition:CGPointZero];
        [self addChild:_hudMenu z:2];        

        _whenDoneUndoingPlayThis = hintNone;
        _whenDoneUndoingDoLag = NO; // arbitrary, will be overwritten
        
        [self initBottomButtons];

        _stateCountdown = UNDO_LAG;
        
        if (_isTutorialLevel) {
            [self drawTutorials];
        } else {
            // Add hint layer
            _hintLayer = [HintLayer makeHintLayerWithParent:self]; // changes a bottom button color
            [self addChild:_hintLayer z:5];
            _hintLayer.isTouchEnabled = YES;        
        }
    }
    return self;
}

- (void) setOriginalUndoLength:(int)originalLength {
    _originalUndoLength = originalLength;
    if (_hudState == stateDefault && originalLength > 0) {
        _hudState = stateUserMayReplayProgress;
        [self setIllumination];
    }
}

- (Scene_Play*) getPlayScene {
    return (Scene_Play*)_scene;
}

- (void) initBottomButtons {

    // Container layers
    _allBottomContent = [[[CCLayer alloc] init] autorelease]; // TODO: is it ok to autorelease?
    _hudVCRButtons = [[[CCLayer alloc] init] autorelease];
    _currentOperationLayer = [[[CCLayer alloc] init] autorelease];
    [self addChild:_allBottomContent];
    [_allBottomContent addChild:_hudVCRButtons];
    [_allBottomContent addChild:_currentOperationLayer];

    // Note: if you change these, change the setBulbColor function too.
    ccColor3B buttonColor = ccc3(100,100,100);
    ccColor3B buttonHighlight = ccGRAY;

    // Background image
    CCSprite *buttonSnowBackground = [Art sprite:img_hud_snow];
    buttonSnowBackground.opacity = 240;
    CGPoint buttonSnowPos = [Dimensions isIPad] ? ccp(512,108) : ccp(240,48);
    
    [buttonSnowBackground setPosition:buttonSnowPos];
    [_allBottomContent addChild:buttonSnowBackground z:-5];

    const float _botRowY = 0.05; // alignment of all buttons/text on bottom row.
    const float _extraLowReplayY = _isTutorialLevel ? 0.03 : 0.04;
    
    [self addBottomButtonAt:ccp(0.1,_botRowY) 
                      label:@"Back"
                   function:@selector(goLevelGroup:) 
                      color:buttonColor
                   selColor:buttonHighlight
              defaultSprite:[Art sprite:sm_pack] 
             selectedSprite:[Art sprite:sm_pack]
                zoomOnPress:2.0];
    
    _adjustHUD = [self addBottomButtonAt:ccp(0.04,_botRowY * 3) 
                                   label:@"Hide"
                                function:@selector(raiseOrLowerHud:) 
                                   color:buttonColor 
                                selColor:buttonColor // don't change color on highlight bc this is animated
                           defaultSprite:[Art sprite:sm_left_arrow] 
                          selectedSprite:[Art sprite:sm_left_arrow]
                             zoomOnPress:2.0];
    _adjustHUD.rotation = ADJUST_POINTS_DOWN;
    
    _replay = [self addBottomButtonAt:ccp(0.5, _extraLowReplayY)
                                 label:@""
                              function:@selector(tryToReplayUserProgress:) 
                                 color:buttonColor 
                              selColor:buttonHighlight
                         defaultSprite:[Art sprite:img_replay] 
                       selectedSprite:[Art sprite:img_replay]
                          zoomOnPress:1.3];
    _replay.scale *= 5;
    
    _undoAll = [self addBottomButtonAt:ccp(0.26,_botRowY) 
                                 label:@"Undo All"
                              function:@selector(undoAll:) 
                                 color:buttonColor 
                              selColor:buttonHighlight
                         defaultSprite:[Art sprite:sm_rewind] 
                        selectedSprite:[Art sprite:sm_rewind]
                           zoomOnPress:2.0];
    
    _undo    = [self addBottomButtonAt:ccp(0.42,_botRowY) 
                                 label:@"Undo"
                              function:@selector(undo:)
                                 color:buttonColor 
                              selColor:buttonHighlight
                         defaultSprite:[Art sprite:sm_undo] 
                        selectedSprite:[Art sprite:sm_undo]
                           zoomOnPress:2.0];
    
    _redo    = [self addBottomButtonAt:ccp(0.58,_botRowY) 
                                 label:@"Redo"
                              function:@selector(redo:) 
                                 color:buttonColor 
                              selColor:buttonHighlight
                         defaultSprite:[Art sprite:sm_redo] 
                        selectedSprite:[Art sprite:sm_redo]
                           zoomOnPress:2.0];
    
    _redoAll = [self addBottomButtonAt:ccp(0.74,_botRowY) 
                                 label:@"Redo All"
                              function:@selector(redoAll:) 
                                 color:buttonColor 
                              selColor:buttonHighlight
                         defaultSprite:[Art sprite:sm_fast_forward] 
                        selectedSprite:[Art sprite:sm_fast_forward]
                           zoomOnPress:2.0];
    
    _isUndoAllAllowed = NO;
    _isUndoAllowed = NO;
    _isRedoAllowed = NO;
    _isRedoAllAllowed = NO;

    float tutorial_shift = _isTutorialLevel ? 0.025 : 0;
    _currentOperationTitle    = [self addCenteredLabelAt:ccp(0.5, 0.10 - tutorial_shift) text:@"" fontSize:20 parent:_currentOperationLayer];
    _currentOperationSubtitle = [self addCenteredLabelAt:ccp(0.5, 0.04 - tutorial_shift) text:@"" fontSize:16 parent:_currentOperationLayer];
    _currentOperationTitle.color = buttonColor;
    _currentOperationSubtitle.color = buttonColor;

    [self setIllumination];

    if (_isTutorialLevel) {
        _tutorialButton = [self addBottomButtonAt:ccp(0.9,_botRowY) 
                                     label:@"Tip"
                                  function:@selector(showHideTutorial:) 
                                     color:buttonColor 
                                  selColor:buttonHighlight
                             defaultSprite:[Art sprite:sm_tip] 
                                   selectedSprite:[Art sprite:sm_tip]
                                      zoomOnPress:2.0];
    
    } else {
        _hintBulbSprite = [Art sprite:sm_bulb];
        _bulb    = [self addBottomButtonAt:ccp(0.9,_botRowY) 
                                     label:@"Hints"
                                  function:@selector(showHintPopup:) 
                                     color:buttonColor 
                                  selColor:buttonHighlight
                             defaultSprite:_hintBulbSprite 
                            selectedSprite:[Art sprite:sm_bulb]
                               zoomOnPress:2.0];
        _bulb.scale *= 0.8;
    }
    
    if (_isTutorialLevel) {
        _allBottomContent.position = HUD_EXTRA_UP_POSITION;
        _hudMenu.position = HUD_EXTRA_UP_POSITION;
    }
}

// Override parent class; show labels
- (CCMenuItemImage*) addBottomButtonAt:(CGPoint)pos
                                 label:(NSString*)text
                              function:(SEL)selector
                                 color:(ccColor3B)color
                              selColor:(ccColor3B)selColor
                         defaultSprite:(CCSprite*)defaultSprite
                        selectedSprite:(CCSprite*)selectedSprite
                           zoomOnPress:(float)zoomFactor {
    
    CCMenuItemImage* ret = [super addBottomButtonAt:pos
                                              label:text
                                           function:selector
                                              color:color
                                           selColor:selColor
                                      defaultSprite:defaultSprite
                                     selectedSprite:selectedSprite
                                        zoomOnPress:zoomFactor];    

    if (_isTutorialLevel) {
        CGPoint posPx = [Dimensions convertScreensToPxBottomCentric:pos];
        CCLabelTTF *buttonLabel = [CCLabelTTF labelWithString:text fontName:[BoxFont getDefaultFont] fontSize:14 * [Dimensions doubleForIpad]];
        [buttonLabel setPosition:ccpAdd(ccp(0, -30 * [Dimensions doubleForIpad]), posPx)];
        buttonLabel.color = ccBLACK;
        [_hudVCRButtons addChild:buttonLabel];
        ret.userData = buttonLabel;
    }
    
    return ret;
}

+ (void) prepareToRunHintSolution:(hintType)hint {
    [_singleton prepareToRunHintSolution:hint];
}

- (void) prepareToRunHintSolution:(hintType)hint {
    [SquidLog debug:@"==Run Hint Solution=="];
    
    // If redo/undo is playing, stop it.
    // TODO: if we didn't interrupt it fast enough, it already played a move and we're going to crash...
    [self interruptAutoplay];
    
    _whenDoneUndoingPlayThis = hint;
    _whenDoneUndoingDoLag = NO;
    _hudState = stateRewindingToShowHint;
}

- (void) actuallyRunHintSolution:(hintType)hint {
    _whenDoneUndoingPlayThis = hintNone;

    // try to replace redo history
    NSString *fullSolution = [BoxLevel getParSolution];
    NSString *partialSolution = [fullSolution substringToIndex:[HintLayer getHintSize:hint fullSolution:[fullSolution length]]];
    bool success = [GridLogicManager replaceRedoHistory:partialSolution];
    
    if (success) {
        _redoLimit = -1; // no limit
        _hudState = stateReplayingHint;
    } else {
        [SquidLog warn:@"actuallyRunHintSolution: failed to replace history. Maybe you didn't undo all the way?"];
    }
}

- (void) showHintPopup:(id)sender {
    // TODO: turn off swipes, taps, other buttons, etc.
    //   or just swallow taps?
    [_hintLayer showHintLayer];
}

- (void) hideHintPopup:(id)sender {
    [_hintLayer hideHintLayer:nil];
}                           

// Continue any ongoing redoall/undoall operation
- (void) playerTick:(ccTime)dt {
    _stateCountdown -= dt;
    
    if (_stateCountdown > 0) {
        return;
    }

    // Otherwise, we are done waiting and can act.
    if (_hudState == stateUndoAll || _hudState == stateRewindingToShowHint) {
        _stateCountdown = UNDO_LAG;
        bool didComplete = ![GridLogicManager undoMove];
        if (didComplete) {
            _hudState = stateDefault;
            if (_whenDoneUndoingPlayThis != hintNone) {
                if (_whenDoneUndoingDoLag) {
                    _stateCountdown = REPLAY_HINT_BIG_LAG;
                } else {
                    _stateCountdown = REPLAY_HINT_SMALL_LAG;
                }
                [self actuallyRunHintSolution:_whenDoneUndoingPlayThis];
            }
        } else {
            // Undo did one move and is still going
            if (_whenDoneUndoingPlayThis != hintNone) {
                _whenDoneUndoingDoLag = YES;
            }
        }
    } else if (_hudState == stateRedoAll || _hudState == stateReplayingHint || _hudState == stateReplayingProgress) {
        _stateCountdown = REDO_LAG;
        _redoLimit --;
        bool didComplete = ![GridLogicManager redoMove] || _redoLimit == 0; // don't do _redoLimit <= 0; we use _redoLimit = -1 to mean unlimited redos.
        if (didComplete) {
            _hudState = stateDefault;
        }
    }
    [self setIllumination];
}

// Interrupt an undo/redo sequence
+ (void) interruptAutoplay {
    [_singleton interruptAutoplay];
}

- (void) interruptAutoplay {
    _hudState = stateDefault;
    _whenDoneUndoingPlayThis = hintNone;
    [self setIllumination];
}

- (void) setHistoryOptions:(bool)canUndo redo:(bool)canRedo undoAll:(bool)canUndoAll redoAll:(bool)canRedoAll {
    _isUndoAllAllowed = canUndoAll;
    _isUndoAllowed = canUndo;
    _isRedoAllowed = canRedo;
    _isRedoAllAllowed = canRedoAll;
    [self setIllumination];
}

- (void) undoAll:(id)sender {
    _hudState = stateUndoAll;
}

- (void) setButtonVisibility:(CCMenuItemImage*)button visible:(bool)visible {
    if (_hudState != stateDefault) {
        // If we're doing something, we hide these buttons.
        visible = NO;
    }
    
    button.visible = visible;
    if (button.userData != nil) {
        CCLabelTTF *buttonLabel = button.userData;
        buttonLabel.visible = visible;
    }
}

- (void) tryToReplayUserProgress:(id)sender {
    
    if ([GridLogicManager didAnyMoveYet]) {
        [SquidLog warn:@"Tried to replay user progress, but user had already moved."];
        _hudState = stateDefault;
        return;    
    }

    if (_originalUndoLength == 0) {
        [SquidLog warn:@"Tried to replay user progress, but it was 0 moves long."];
        _hudState = stateDefault;
        return;
    }
    
    if (_hudState != stateUserMayReplayProgress) {
        [SquidLog warn:@"Tried to replay user progress, but was already undoing/redoing."];
        return;
    }
    
    _redoLimit = _originalUndoLength;
    _hudState = stateReplayingProgress;
}

- (void) redoAll:(id)sender {
    _redoLimit = -1; // no limit
    _hudState = stateRedoAll;
}

- (void) undo:(id)sender {
    _hudState = stateDefault;
    [GridLogicManager undoMove];    
}

- (void) redo:(id)sender {
    _hudState = stateDefault;
    [GridLogicManager redoMove];
}

- (void) showHideTutorial:(id)sender {
    [BoxMusic tryToPlaySound:press_sound];
    _tutorialBackdrop.visible = !_tutorialBackdrop.visible;
}

- (void) raiseOrLowerHud:(id)sender {
    [BoxMusic tryToPlaySound:press_sound];
    float angle = _adjustHUD.rotation;

    CGPoint myUpPosition = _isTutorialLevel ? HUD_EXTRA_UP_POSITION : HUD_UP_POSITION;
    
    if (angle == ADJUST_POINTS_DOWN) {
        [_adjustHUD runAction:[CCRotateTo actionWithDuration:ADJUST_HUD_DURATION angle:ADJUST_POINTS_UP]];
        [_allBottomContent runAction:[CCMoveTo actionWithDuration:ADJUST_HUD_DURATION position:HUD_DOWN_POSITION]];
        [_hudMenu runAction:[CCMoveTo actionWithDuration:ADJUST_HUD_DURATION position:HUD_DOWN_POSITION]];
    } else {
        [_adjustHUD runAction:[CCRotateTo actionWithDuration:ADJUST_HUD_DURATION angle:ADJUST_POINTS_DOWN]];    
        [_allBottomContent runAction:[CCMoveTo actionWithDuration:ADJUST_HUD_DURATION position:myUpPosition]];
        [_hudMenu runAction:[CCMoveTo actionWithDuration:ADJUST_HUD_DURATION position:myUpPosition]];
    }
}

// Highlight/unhighlight undoall/redoall buttons
- (void) setIllumination {
    
    [self setButtonVisibility:_undoAll visible:_isUndoAllAllowed];
    [self setButtonVisibility:_undo    visible:_isUndoAllowed];
    [self setButtonVisibility:_redo    visible:_isRedoAllowed];
    [self setButtonVisibility:_redoAll visible:_isRedoAllAllowed];

    _replay.visible = (_hudState == stateUserMayReplayProgress);

    switch (_hudState) {

        case stateDefault:
            _currentOperationLayer.visible = NO;
            break;

        case stateUserMayReplayProgress:
            _currentOperationLayer.visible = NO;
            break;
            
        case stateUndoAll:
            [self displayOperation:@"Undoing" subtitle:@"tap anywhere to stop"];
            break;

        case stateRewindingToShowHint:
        case stateReplayingHint:
            [self displayOperation:@"Playing Hint" subtitle:@"tap anywhere to stop"];
            break;
            
        case stateRedoAll:
            [self displayOperation:@"Redoing" subtitle:@"tap anywhere to stop"];
            break;

        case stateReplayingProgress:
            [self displayOperation:@"Replaying Progress" subtitle:@"tap anywhere to stop"];
            break;
    }
}

- (void) displayOperation:(NSString*)operationTitle subtitle:(NSString*)operationSubtitle {
    [_currentOperationTitle setString:operationTitle];
    [_currentOperationSubtitle setString:operationSubtitle];
    _currentOperationLayer.visible = YES;
}

- (void) setHintBulbColor:(ccColor3B)color {
    _hintBulbSprite.color = color;
}

- (void) drawTutorials {
    _tutorialBackdrop = [[CCLayerColor alloc] initWithColor:ccc4(0,0,0,155)];
    [_tutorialBackdrop setPosition:ccp(0,[Dimensions screenSizePx].y * 0.8)];
    [self addChild:_tutorialBackdrop z:15];        
    
    if ([BoxLevel getTutorialOne] != nil) {
        [self addCenteredLabelAt:ccp(0.5,0.15) text:[BoxLevel getTutorialOne] fontSize:20 parent:_tutorialBackdrop];
    }
    if ([BoxLevel getTutorialTwo] != nil) {
        [self addCenteredLabelAt:ccp(0.5,0.05) text:[BoxLevel getTutorialTwo] fontSize:16 parent:_tutorialBackdrop];
    }
}

- (CCLabelTTF*) addCenteredLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize parent:(CCLayer*)parentLayer {
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:[BoxFont getDefaultFont] fontSize:fontSize * [Dimensions doubleForIpad]];
    [label setPosition:[Dimensions convertScreensToPxHeightCentric:screenPos]];
    [parentLayer addChild:label];
    return label;
}

@end
