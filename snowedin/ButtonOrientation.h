//
//  ButtonOrientation.h
//  Snowed In!!
//
//  Created by Matthew Webber on 10/3/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import <Foundation/Foundation.h>
@class CCNode;

@interface ButtonOrientation : NSObject {
    float _rotation;
    CGPoint _offset;
}

+ (ButtonOrientation*) make:(CGPoint)offset rot:(float)rotation;
- (id) initWithOffset:(CGPoint)offset andRotation:(float)rotation;
- (void) applyToNode:(CCNode*)node pos:(bool)doPos rot:(bool)doRot;
- (void) addOffset:(CGPoint)additionalOffset;

@end
