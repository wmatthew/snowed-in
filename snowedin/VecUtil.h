//
//  VecUtil.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/27/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VecUtil : NSObject {}

+ (bool) isInBounds:(CGPoint)gridPos;
+ (bool) isIntPoint:(CGPoint)point;
+ (bool) isCardinalDirection:(CGPoint)direction;
+ (bool) isInBounds:(CGPoint)gridPos;
+ (bool) isExactGridPos:(CGPoint)gridPos;

@end
