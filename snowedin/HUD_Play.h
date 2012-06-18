//
//  HUD_Play.h
//  Snowed In!!
//
//  Created by Matthew Webber on 7/12/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "HUD_Generic.h"

@class Scene_Play;

@interface HUD_Play : HUD_Generic {
    hudState _hudState;

    CCMenuItemImage *_undo;
    CCMenuItemImage *_undoAll;
    CCMenuItemImage *_redo;
    CCMenuItemImage *_redoAll;
    CCMenuItemImage *_bulb;
    CCMenuItemImage *_tutorialButton;
    CCMenuItemImage *_adjustHUD;
    CCMenuItemImage *_replay;

    hintType _whenDoneUndoingPlayThis;
    bool _whenDoneUndoingDoLag;
    CCSprite *_hintBulbSprite;
    
    CCLayerColor *_tutorialBackdrop;
    CCLayer *_allBottomContent;
    CCLayer *_hudVCRButtons;
    
    CCLayer *_currentOperationLayer;
    CCLabelTTF *_currentOperationTitle;
    CCLabelTTF *_currentOperationSubtitle;
    
    bool _isTutorialLevel;
    
    bool _isUndoAllAllowed;
    bool _isUndoAllowed;
    bool _isRedoAllowed;
    bool _isRedoAllAllowed;
    int _originalUndoLength;
}

+ (HUD_Play*) getNewHUD:(hudConfiguration)config withScene:(Scene_Generic_BoxPusher*)scene;
+ (HUD_Play*) getOldHUD;

- (id) initWithConfig:(hudConfiguration)config scene:(Scene_Generic_BoxPusher*)scene;
- (void) initBottomButtons;
- (void) setOriginalUndoLength:(int)originalLength;

- (void) setHistoryOptions:(bool)canUndo redo:(bool)canRedo undoAll:(bool)canUndoAll redoAll:(bool)canRedoAll;

+ (void) interruptAutoplay;
- (void) interruptAutoplay;
- (void) setIllumination;
- (void) displayOperation:(NSString*)operationTitle subtitle:(NSString*)operationSubtitle;
- (void) setButtonVisibility:(CCMenuItemImage*)button visible:(bool)visible;

- (void) redoAll:(id)sender;
- (void) undoAll:(id)sender;
- (void) tryToReplayUserProgress:(id)sender;

+ (void) prepareToRunHintSolution:(hintType)hint;
- (void) prepareToRunHintSolution:(hintType)hint;

- (void) showHintPopup:(id)sender;
- (void) hideHintPopup:(id)sender;

- (void) playerTick:(ccTime)dt;
- (void) setHintBulbColor:(ccColor3B)color;

- (void) drawTutorials;
- (CCLabelTTF*) addCenteredLabelAt:(CGPoint)screenPos text:(NSString*)text fontSize:(int)fontSize parent:(CCLayer*)parentLayer;

- (Scene_Play*) getPlayScene;

@end
