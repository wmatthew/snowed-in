//
//  HintEnums.h
//  Snowed In!!
//
//  Created by Matthew Webber on 7/12/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

typedef enum {
    hintNone = 0,
    hintSmall = 1,
    hintMed = 2,
    hintLarge = 3,
    hintComplete = 4,
} hintType;

typedef enum {
    stateDefault, // doing nothing
    stateUserMayReplayProgress,
    
    stateUndoAll,
    stateRewindingToShowHint,

    stateRedoAll,
    stateReplayingProgress,
    stateReplayingHint,

} hudState;

typedef enum {
    configMainMenu,
    configLevel,    
} hudConfiguration;

typedef enum {
    hintStatusUsed,
    hintStatusForSale,
    hintStatusReadyToUse,
    hintStatusLocked,
} hintStatus;
