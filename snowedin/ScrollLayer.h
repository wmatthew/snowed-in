//
//  ScrollLayer.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/2/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCNode;

@interface ScrollLayer : NSObject {
    float _scrollSpeed;
    CCNode *_myNode;
    CGPoint _baselinePosition;
}

- (id) initWithNode:(CCNode*)node andSpeed:(float)speed;
- (void) setPosition:(float)newOffset;

@end
