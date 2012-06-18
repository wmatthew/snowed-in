//
//  BoxOverlay.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/18/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "BoxOverlay.h"
#import "boxpusher.h"

@implementation BoxOverlay

- (void) draw {
    //[SquidLog info:@"drawing polygons..."];
    NSMutableArray *bounds = [[[NSMutableArray alloc] init ] autorelease]; // contains polygons

    // For each tile
    CGPoint size = [BoxLevel getLevelSize];
    for (int j=0-1; j<size.y; j++) {
        for (int i=0-1; i<size.x; i++) {
            tileType current = [GridLogicManager getTypeAt:ccp(i,j)];
            CGPoint base = [GridDisplayManager gridToPx:ccp(i,j)];
            if (current == tileWall) {
                NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
                [polygon addObject:[Vec2 x:base.x-50 y:base.y-50]];        
                [polygon addObject:[Vec2 x:base.x+50 y:base.y-50]];        
                [polygon addObject:[Vec2 x:base.x+50 y:base.y+50]];        
                [polygon addObject:[Vec2 x:base.x-50 y:base.y+50]];        
                [bounds addObject:polygon];
            } else {
                
                // Bottom Wall
                if ([GridLogicManager getTypeAt:ccp(i,j+1)] == tileWall) {
                    NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
                    [polygon addObject:[Vec2 x:base.x-70 y:base.y-30]];        
                    [polygon addObject:[Vec2 x:base.x+30 y:base.y-30]];        
                    [polygon addObject:[Vec2 x:base.x+50 y:base.y-50]];        
                    [polygon addObject:[Vec2 x:base.x-50 y:base.y-50]];        
                    [bounds addObject:polygon];
                }
                
                // Right Wall
                if ([GridLogicManager getTypeAt:ccp(i+1,j)] == tileWall) {
                    NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
                    [polygon addObject:[Vec2 x:base.x+30 y:base.y-30]];        
                    [polygon addObject:[Vec2 x:base.x+30 y:base.y+70]];        
                    [polygon addObject:[Vec2 x:base.x+50 y:base.y+50]];        
                    [polygon addObject:[Vec2 x:base.x+50 y:base.y-50]];        
                    [bounds addObject:polygon];
                }
            }
        }        
    }    

    // Add outer boundaries
    CGPoint topLeft = [GridDisplayManager gridToPx:ccp(-1,-1)];
    CGPoint botRight = [GridDisplayManager gridToPx:ccp(size.x, size.y)];
    float bigVal = 1000;
    
    // Left
    if (YES) {
        NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
        [polygon addObject:[Vec2 x:-bigVal y:-bigVal]];        
        [polygon addObject:[Vec2 x:-bigVal y:[Dimensions screenSizePx].y+bigVal]];        
        [polygon addObject:[Vec2 x:topLeft.x y:[Dimensions screenSizePx].y+bigVal]];        
        [polygon addObject:[Vec2 x:topLeft.x y:-bigVal]];        
        [bounds addObject:polygon];    
    }
    
    // Right
    if (YES) {
        NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
        [polygon addObject:[Vec2 x:[Dimensions screenSizePx].x+bigVal y:-bigVal]];        
        [polygon addObject:[Vec2 x:[Dimensions screenSizePx].x+bigVal y:[Dimensions screenSizePx].y+bigVal]];        
        [polygon addObject:[Vec2 x:botRight.x-50 y:[Dimensions screenSizePx].y+bigVal]];        
        [polygon addObject:[Vec2 x:botRight.x-50 y:-bigVal]];        
        [bounds addObject:polygon];    
    }
    
    // Top
    if (YES) {
        NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
        [polygon addObject:[Vec2 x:-bigVal y:[Dimensions screenSizePx].y+bigVal]];        
        [polygon addObject:[Vec2 x:-bigVal y:topLeft.y]];        
        [polygon addObject:[Vec2 x:[Dimensions screenSizePx].x+bigVal y:topLeft.y]];        
        [polygon addObject:[Vec2 x:[Dimensions screenSizePx].x+bigVal y:[Dimensions screenSizePx].y+bigVal]];        
        [bounds addObject:polygon];    
    }
    
    // Bottom
    if (YES) {
        NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
        [polygon addObject:[Vec2 x:-bigVal y:-bigVal]];        
        [polygon addObject:[Vec2 x:-bigVal y:botRight.y+50]];        
        [polygon addObject:[Vec2 x:[Dimensions screenSizePx].x+bigVal y:botRight.y+50]];        
        [polygon addObject:[Vec2 x:[Dimensions screenSizePx].x+bigVal y:-bigVal]];        
        [bounds addObject:polygon];    
    }
    
    [SingleArtist drawSolidPolygons:bounds withColor:ccc4(50,50,50,255)];
    //[SingleArtist drawPolygons:bounds texture:@"blue_snow.jpg"];
}

@end
