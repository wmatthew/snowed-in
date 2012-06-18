//
//  VecUtil.m
//  Snowed In!!
//
//  Created by Matthew Webber on 5/27/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "VecUtil.h"
#import "BoxLevel.h"

@implementation VecUtil

+ (bool) isIntPoint:(CGPoint)point {
    // Make sure both are round int values
    return (floor(point.x) == point.x) && (floor(point.y) == point.y);
}

+ (bool) isCardinalDirection:(CGPoint)direction {
    if (abs(direction.x)==1 && direction.y == 0) {
        return YES;
    }
    if (abs(direction.y)==1 && direction.x == 0) {
        return YES;
    }
    return NO;
}

+ (bool) isInBounds:(CGPoint)gridPos {
    if (gridPos.x < 0 || gridPos.y < 0) {
        return NO;
    }
    
    CGPoint size = [BoxLevel getLevelSize];
    if (gridPos.x >= size.x || gridPos.y >= size.y) {
        return NO;
    }
    return YES;
}

+ (bool) isExactGridPos:(CGPoint)gridPos {
    return [self isInBounds:gridPos] && [self isIntPoint:gridPos];
}

@end
