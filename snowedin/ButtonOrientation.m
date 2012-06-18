//
//  ButtonOrientation.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/3/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "ButtonOrientation.h"
#import "boxpusher.h"

@implementation ButtonOrientation

+ (ButtonOrientation*) make:(CGPoint)offset rot:(float)rotation {
    return [[[ButtonOrientation alloc] initWithOffset:offset andRotation:rotation] autorelease];
}

- (id) initWithOffset:(CGPoint)offset andRotation:(float)rotation {
    if (( self = [super init] )) {
        _offset = offset;
        _rotation = rotation;
    }
    return self;
}

- (void) applyToNode:(CCNode*)node pos:(bool)doPos rot:(bool)doRot {
    if (doPos) {
        CGPoint actualOffset = [Dimensions convertScreensToPx:_offset withConversion:widthCentric];
        CGPoint pos = node.position;
        node.position = ccpAdd(pos, actualOffset);
    }
    if (doRot) {
        node.rotation += _rotation;
    }
}

- (void) addOffset:(CGPoint)additionalOffset {
    _offset = ccpAdd(_offset, additionalOffset);
}

@end
