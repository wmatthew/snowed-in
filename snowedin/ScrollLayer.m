//
//  ScrollLayer.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/2/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "ScrollLayer.h"
#import "boxpusher.h"

@implementation ScrollLayer

- (id) initWithNode:(CCNode*)node andSpeed:(float)speed {
    if ((self = [super init])) {
        _scrollSpeed = speed;
        _myNode = node;
        _baselinePosition = _myNode.position;
    }
    return self;
}

- (void) setPosition:(float)newOffset {
    CGPoint pos = _baselinePosition;
    pos.x += newOffset * _scrollSpeed;
    _myNode.position = pos;
}

- (void) dealloc {
    [_myNode release];
    _myNode = nil;
    [super dealloc];
}

@end
