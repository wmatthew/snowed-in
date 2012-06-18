//
//  Scene_Pack.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/31/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "Scene_Generic_BoxPusher.h"
#import "Art.h"

typedef enum {
    groupDepthSky = -10,
    groupDepthHouse = -8,
    groupDepthTrim = -6,
    groupDepthRoof = -4,
    groupDepthLightSnow = -2,
    groupDepthHeavySnow = -1,
} depthGroupScene;

@interface Scene_Group : Scene_Generic_BoxPusher {
    levelGroup _currentGroup;
    NSMutableDictionary *_levelTitleDictionary;
    NSMutableDictionary *_levelSubtitleDictionary;
}

- (void) showPurchasePopup:(id)sender;

- (void) addAllHouseImages;
- (void) addAllSigns;
- (void) addNextPlayableSign;

- (void) addHouseImage:(artResource)art depth:(depthGroupScene)depth color:(ccColor3B)color;
- (CCLabelTTF*) drawSignText:(NSString*)signText at:(CGPoint)pos fontSize:(float)size;
- (void) tappedSign:(id)sender;

@end
