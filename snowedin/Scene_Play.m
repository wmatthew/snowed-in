//
//  Scene_Play.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/21/11.
//  Copyright SquidMixer 2011. All rights reserved.

#import "Scene_Play.h"
#import "boxpusher.h"

// Scene_Play implementation
@implementation Scene_Play

static float ZOOM_MIN;
static float ZOOM_MAX;
const float WIN_SEQ_LENGTH = 3.0;
float winWait;
bool _startedWinExplosion;

+ (void) initialize {
    ZOOM_MAX = 2.0;
    ZOOM_MIN = [Dimensions isIPad] ? 0.42 : 0.36;
}

-(id) init
{
	if ((self = [super init])) {

        // Constants, Logging, Music
        self.isTouchEnabled = YES;
        winWait = WIN_SEQ_LENGTH;
        _startedWinExplosion = NO;
        [SquidLog setLoggingLevel:LOG_INFO];
        [BoxMusic tryToPlayGameMusic];

        // Load the level
        [BoxLevel loadLevel:[BoxStorageLevels getCurrentLevelID]];

        [Entity reset];
        [GridInputManager reset:self];

        _myHUDPlay = [HUD_Play getNewHUD:configLevel withScene:self];
        [self addChild:_myHUDPlay z:20];
        
        [GridLogicManager reset]; // Updates HUD; depends on BoxLevel loaded.

        _playLayerPositionOffset = [Dimensions screenMiddlePx];
        _playLayer = [GridDisplayManager reset];
        _playLayer.scale = [BoxStorageLevels getZoom:(ZOOM_MIN + ZOOM_MAX) / 2];
        [self addChild:_playLayer];

        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(orientationChanged:) 
													 name:UIDeviceOrientationDidChangeNotification 
												   object:nil];

        [self schedule: @selector(tick:)];

        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(makepinch:)];  
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:_pinch];
        _pinchBaseline = _playLayer.scale;
        
        [self tick:0.02f]; // lame, but removes flicker.
        
        [SquidLog info:@"Loaded %@ (level %i)", [BoxLevel getTitle], [BoxStorageLevels getCurrentLevelID]];
	}
	return self;
}

- (void) dealloc {
    [BoxStorageLevels setZoom:_playLayer.scale];
    [_pinch release];
    _pinch = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    //[self unscheduleAllSelectors];
    [super dealloc];
}

-(void)makepinch:(UIPinchGestureRecognizer*)pinch
{
    if ([GridLogicManager didWin]) {
        // Ignore pinch during win sequence.
        return;
    }
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        _pinchBaseline = _playLayer.scale;        
    }
    
    if (pinch.scale != NAN && pinch.scale > 0.0) {
        float newZoomLevel = _pinch.scale * _pinchBaseline;
        [self setZoomLevel:newZoomLevel];
    }
}

- (void) setZoomLevel:(float)zoomLevel {
    zoomLevel = MAX(ZOOM_MIN, zoomLevel);
    zoomLevel = MIN(ZOOM_MAX, zoomLevel);
    _playLayer.scale = zoomLevel;
}

-(void) tick: (ccTime) dt {
    
    [Entity tick:dt]; // move entities
     
    if ([GridLogicManager didWin]) {
        [self continueWin:dt];
    } else {
        [GridInputManager tick:dt]; // sense new inputs
        [_myHUDPlay playerTick:dt]; // continue undoAll / redoAll
    }
    
    //======================================
    // Position the level appropriately
    CGPoint avatarCentered = ccpSub(_playLayerPositionOffset, [[GridLogicManager getAvatar] getSprite].position);
    CGPoint levelCentered = ccpSub(_playLayerPositionOffset, [GridDisplayManager getLevelCenterPx]);

    // How important is it to center on the level center, and not the avatar?
    //  when zoomed out/MIN: level importance is high (1.0)
    //  when zoomed  in/MAX: level importance is low (0.0)
    float levelImportance = (ZOOM_MAX - _playLayer.scale) / (ZOOM_MAX - ZOOM_MIN);
    levelImportance = levelImportance * levelImportance;
    CGPoint mixCentered = ccpAdd(ccpMult(avatarCentered, 1-levelImportance), ccpMult(levelCentered, levelImportance));
    _playLayer.position = ccpMult(mixCentered, _playLayer.scale);
}

- (void) continueWin:(ccTime)dt {
    winWait -= dt;

    if (winWait < 0) {
        [self finishWin];
    }

    CCSprite *avSprite = [[GridLogicManager getAvatar] getSprite];
    if (avSprite == nil) {
        return; 
    }
    
    if (_startedWinExplosion == NO) {
        _myHUDPlay.visible = NO;
        [self removeAd];

        _startedWinExplosion = YES;
        _winEmitter = [WinExplosion node];
        [_winEmitter setWinBoxLevelDefaults:ccWHITE];
        [_playLayer addChild:_winEmitter];

        // spin around like the girl in the exorcist
        [[GridLogicManager getAvatar] unfrustrate];
        [avSprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:0.1 angle:90]]];
        
        // fade to white
        _winWhiteFadeLayer = [[CCLayerColor alloc] initWithColor:ccc4(255,255,255,0)];
        [self addChild:_winWhiteFadeLayer z:100];
        [_winWhiteFadeLayer runAction:[CCFadeIn actionWithDuration:WIN_SEQ_LENGTH-0.3]];
    }
    
    // keep up with (possibly still moving) avatar
    _winEmitter.position = avSprite.position;
}

- (void) finishWin {

    // Did we just finish the final level?
    if ([LevelManager getCompletedLevelsOverall] == [LevelManager getTotalNumberOfLevelsOverall] &&
        [LevelManager getDidShowWinScreen] == NO) {

        [SquidLog info:@"User just won; showing win screen."];
        [LevelManager setDidShowWinScreen:YES];
        [MenuScrollController needsToShowWinScreen];
        [Scene_Generic_BoxPusher goToNextScene:[Scene_MainMenu node]];                

    } else {
        [Scene_Generic_BoxPusher goToNextScene:[Scene_Group node]];        
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [GridInputManager ccTouchesBegan:touches withEvent:event];
}
- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [GridInputManager ccTouchesMoved:touches withEvent:event];
}
- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [GridInputManager ccTouchesEnded:touches withEvent:event];
}

-(void) orientationChanged:(NSNotification *)notification
{	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
	//Transform Ad to adjust it to the current orientation
	[self fixBannerToDeviceOrientation:orientation];
}

#pragma mark -
#pragma mark ADBannerView

- (void)fixBannerToDeviceOrientation:(UIDeviceOrientation)orientation
{
    [SquidLog debug:@"Ad: fixBannerToDeviceOrientation"];
	//Don't rotate ad if it doesn't exist
	if (adBannerView != nil)
	{
		//Set the transformation for each orientation
		switch (orientation) 
		{
			case UIDeviceOrientationPortrait:
			{
				//[adBannerView setTransform:CGAffineTransformIdentity];
				//[adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
				//[adBannerView setCenter:CGPointMake(160, 455)];
			}
				break;
			case UIDeviceOrientationPortraitUpsideDown:
			{
				//[adBannerView setTransform:CGAffineTransformIdentity];
				//[adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
				//[adBannerView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(180))];
				//[adBannerView setCenter:CGPointMake(160, 25)];
			}
				break;
			case UIDeviceOrientationLandscapeLeft:
			{
				[adBannerView setTransform:CGAffineTransformIdentity];
				[adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
				[adBannerView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90))];
                if ([Dimensions isIPad]) {
                    [adBannerView setCenter:CGPointMake(735, 512)]; // 66px high
                } else {
                    [adBannerView setCenter:CGPointMake(304, 240)]; // 32px high               
                }
			}
				break;
			case UIDeviceOrientationLandscapeRight:
			{
				[adBannerView setTransform:CGAffineTransformIdentity];
				[adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
				[adBannerView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90))];
                if ([Dimensions isIPad]) {
                    [adBannerView setCenter:CGPointMake(33, 512)]; // 66px high      
                } else {
                    [adBannerView setCenter:CGPointMake(16, 240)]; // 32px high
                }
			}
				break;
			default:
				break;
		}
	}
}

- (void)onEnter 
{
	[super onEnter];
    
    if (![Purchases shouldDisplayAds]) {
        return;
    }
	
	//Initialize the class manually to make it compatible with iOS < 4.0
	Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) 
	{
		adBannerView = [[classAdBannerView alloc] initWithFrame:CGRectZero];
		[adBannerView setDelegate:self];
		[adBannerView setRequiredContentSizeIdentifiers: [NSSet setWithObjects: 
                                                          ADBannerContentSizeIdentifierLandscape, 
                                                          ADBannerContentSizeIdentifierPortrait, nil]];
		
		//Add the bannerView to the openGLView which is the view of our UIViewController
		[[[CCDirector sharedDirector] openGLView] addSubview:adBannerView];
		
		//Transform bannerView
		[self fixBannerToDeviceOrientation:(UIDeviceOrientation)[[CCDirector sharedDirector] deviceOrientation]];
		
		//Set bannerView to hidden so it shows only when it is loaded.
		[adBannerView setHidden:YES];
		
	}
	else
	{
		//No iAd Framework, iOS < 4.0
		CCLOG(@"No iAds avaiable for this version");
	}
    
}

- (void) removeAd {
	//Completely remove the bannerView
	[adBannerView setDelegate:nil];
	[adBannerView removeFromSuperview];
	[adBannerView release];
	adBannerView = nil;
}

- (void)onExit 
{	
    [self removeAd];
	[super onExit];
}

#pragma mark -
#pragma mark ADBannerViewDelegate

- (BOOL)allowActionToRun
{
	return TRUE;
}

- (void) stopActionsForAd
{
    [BoxMusic pauseMusic]; // Pause Music
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

- (void) startActionsForAd
{
    [BoxMusic tryToPlayGameMusic]; // Resume music if paused
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	BOOL shouldExecuteAction = [self allowActionToRun];
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
		[self stopActionsForAd];
    }
    return shouldExecuteAction;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	//Show the bannerView
	[adBannerView setHidden:NO];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	//Hide the bannerView if it fails to load
	[adBannerView setHidden:YES];
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	//Set the device orientation to cocos2d orientation
	//If I don't do this, the interface gets stuck with portrait orientation when the ad finished showing for the first time.
	UIDeviceOrientation orientation = (UIDeviceOrientation)[[CCDirector sharedDirector] deviceOrientation];
	[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
	[self fixBannerToDeviceOrientation:orientation];
	
	[self startActionsForAd];
}



@end
