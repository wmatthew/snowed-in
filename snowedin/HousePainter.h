//
//  HousePainter.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/20/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelManager.h"
#import "cocos2d.h"

@interface HousePainter : NSObject {
    ccColor3B _baseColor;
    ccColor3B _trimColor;
}

+ (ccColor3B) getBaseColor:(levelGroup)group;
+ (ccColor3B) getTrimColor:(levelGroup)group;

+ (void) setColor:(levelGroup)house base:(ccColor3B)baseColor trim:(ccColor3B)trimColor;

- (id) initWithBase:(ccColor3B)baseColor trim:(ccColor3B)trimColor;
- (ccColor3B) getBaseColor;
- (ccColor3B) getTrimColor;

@end
