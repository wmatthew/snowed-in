//
//  MenuScrollController.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/2/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "boxpusher.h"

@implementation MenuScrollController

//static CCLayer *_trunkLayer;
static NSMutableArray *_allLayers;

// ScrollView
static int _contentWidth;
static float _scrollRangeMin;
static float _scrollRangeMax;

static bool _isPaging;
static bool _isDragging;

static float _lastPosition;
static float _currentPosition;
static float _dragXSpeed;

static float _dragHistory1;
static float _dragHistory2;
static float _dragHistory3;

static bool _needsToShowWinScreen;

+ (void) initialize {
    _lastPosition = 0;
    _currentPosition = 0; // Start with an initial 'bump': [[CCDirector sharedDirector] winSize].width / 3;
    _allLayers = [[[NSMutableArray alloc] init] retain];
    _needsToShowWinScreen = NO;
}

+ (void) needsToShowWinScreen {
    _needsToShowWinScreen = YES;
}

+ (void) reset:(int)contentWidth centerAt:(float)xPosPx {
    [_allLayers release];
    _allLayers = [[[NSMutableArray alloc] init] retain];
    
    [SquidLog debug:@"Reset. Width=%i", contentWidth];
    _contentWidth = contentWidth;
    _scrollRangeMin = -contentWidth;
    _scrollRangeMax = 0;

    _isPaging = YES;
    _isDragging = NO;

    _lastPosition = _currentPosition;
    _currentPosition = -xPosPx;
    if (_needsToShowWinScreen) {
        [SquidLog info:@"Jumping to win screen in scroll container."];
        _currentPosition = -contentWidth;
        _needsToShowWinScreen = NO;
    }
    _dragXSpeed = 0.0;
 
    _dragHistory1 = 0;
    _dragHistory2 = 0;
    _dragHistory3 = 0;
    
    [self updateAllLayers];
}

+ (void) addNode:(CCNode*)node movementSpeed:(float)speed {
    ScrollLayer *container = [[[ScrollLayer alloc] initWithNode:node andSpeed:speed] autorelease];
    [_allLayers addObject:container];
}

+ (void) updateAllLayers {
    for (ScrollLayer *scrollLayer in _allLayers) {
        [scrollLayer setPosition:_currentPosition];
    }
}

+ (void) ccTouchesBegan: (NSSet *)touches withEvent: (UIEvent *)event {
    if ([self screenIsInBounds]) {
        _isDragging = YES;
    }
}

+ (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!_isDragging) {
        if (![self screenIsInBounds]) {
            return;
        }
        
        // back in bounds; start a drag.
        _isDragging = YES;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint a = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]];
	CGPoint b = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	_currentPosition += ( b.x - a.x );
}

+ (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    _isDragging = NO;
}

+ (float) averageIgnoreZeros:(float)a b:(float)b c:(float)c {
    int values = 0;
    if (a != 0) values ++;
    if (b != 0) values ++;
    if (c != 0) values ++;
    
    if (values == 0) return 0;
    else return (a+b+c) / values;
}

+ (bool) screenIsInBounds {
    return (_currentPosition <= _scrollRangeMax && _currentPosition >= _scrollRangeMin);
}

+ (void) bumpHardLeft {
    _isPaging = NO; // no longer locked on a page
    _dragXSpeed = [Dimensions isIPad] ? 500: 250;
}

+ (void) bumpOneScreenRight {
    _isPaging = NO; // no longer locked on a page
    _dragXSpeed = [Dimensions isIPad] ? -75: -25;
}

+ (void) dragTick:(ccTime)dt {
    float friction = 0.95;
    
    [SquidLog debug:@"  pos/speed %f / %f", _currentPosition, _dragXSpeed];
    
    if (_isDragging) {
        
        _isPaging = NO;
        
        _dragHistory3 = _dragHistory2;
        _dragHistory2 = _dragHistory1;
        _dragHistory1 = (_currentPosition - _lastPosition) / 2;

        _dragXSpeed = [self averageIgnoreZeros:_dragHistory1 b:_dragHistory2 c:_dragHistory3];
        
        //CCLOG(@"  pos/speed %f / %f (%f)", _trunkLayer.position.x, _dragXSpeed, _dragHistory1);
        
    } else {
        
        _dragXSpeed *= friction;
        _dragHistory1 = 0;
        _dragHistory2 = 0;
        _dragHistory3 = 0;

        _currentPosition += _dragXSpeed;
        
        // Spring at bounds
        float springRatio = 0.01;
        if (_currentPosition > _scrollRangeMax) {
            if (_dragXSpeed > 0) {
                // aggressive friction on way in
                _dragXSpeed *= 0.9;
            }
            _dragXSpeed -= (_currentPosition - _scrollRangeMax) * springRatio;
        } else if (_currentPosition < _scrollRangeMin) {
            if (_dragXSpeed < 0) {
                // aggressive friction on way in
                _dragXSpeed *= 0.9;
            }
            _dragXSpeed += ( _scrollRangeMin - _currentPosition ) * springRatio;
            _dragXSpeed *= friction;
        }
        
        // Once we slow down below this speed, start snapping to a page
        float minPagingSpeed = 10;
        
        if (_isPaging || (ABS(_dragXSpeed) < minPagingSpeed && [self screenIsInBounds])) {
        
            // We are actively snapping to a page.
            _isPaging = YES;
            
            float pagePos = _currentPosition;
            int viewWidth = [Dimensions screenSizePx].x;
            int justUnderHalfAScreen = (viewWidth / 2) -1;
            pagePos = MAX(_scrollRangeMin-justUnderHalfAScreen, pagePos);
            pagePos = MIN(_scrollRangeMax+justUnderHalfAScreen, pagePos);
            
            float pageDestination = round( pagePos / viewWidth) * viewWidth;
            
            float desiredSpeed = (pageDestination - pagePos)/10;
            float forcefulness = (minPagingSpeed - ABS(_dragXSpeed)) / (minPagingSpeed * 10); //  'Fade in' the paging effect as we slow. 0.1 is forceful. 0 is not forceful.
            _dragXSpeed = (_dragXSpeed * (1-forcefulness)) + (desiredSpeed * forcefulness);
            
            if (ABS(_currentPosition - pageDestination) < 0.2 && ABS(_dragXSpeed) < 0.5) {
                if (_dragXSpeed != 0) {
                    //CCLOG(@"Snap and stop. pos=%f", _currentPosition);
                }
                // snap and stop
                _dragXSpeed = 0;
                _currentPosition = pageDestination;
            }
        }
    }

    _lastPosition = _currentPosition;
    [self updateAllLayers];
}

@end
