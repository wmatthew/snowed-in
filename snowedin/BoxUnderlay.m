//
//  BoxUnderlay.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/18/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import "BoxUnderlay.h"
#import "boxpusher.h"

// Draws left and top walls, for recessed '3D' effect.
@implementation BoxUnderlay

- (void) draw {
    //[SquidLog info:@"drawing polygons..."];
    NSMutableArray *leftBounds = [[[NSMutableArray alloc] init ] autorelease]; // contains polygons
    NSMutableArray *topBounds = [[[NSMutableArray alloc] init ] autorelease]; // contains polygons
    
    // For each tile
    CGPoint size = [BoxLevel getLevelSize];
    for (int j=0; j<size.y+1; j++) {
        for (int i=0; i<size.x+1; i++) {
            tileType current = [GridLogicManager getTypeAt:ccp(i,j)];
            CGPoint base = [GridDisplayManager gridToPx:ccp(i,j)];
            if (current == tileWall) {
                // do nothing
            } else {
                
                // Top Wall
                if ([GridLogicManager getTypeAt:ccp(i,j-1)] == tileWall) {
                    bool blockOnRight = ([GridLogicManager getTypeAt:ccp(i+1,j)] == tileWall);
                    NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
                    [polygon addObject:[Vec2 x:base.x-70 y:base.y+70]];        
                    [polygon addObject:[Vec2 x:base.x+30 y:base.y+70]];        
                    [polygon addObject:[Vec2 x:base.x+(blockOnRight?30:50) y:base.y+50]];        
                    [polygon addObject:[Vec2 x:base.x-50 y:base.y+50]];        
                    [topBounds addObject:polygon];
                }
                
                // Left Wall
                if ([GridLogicManager getTypeAt:ccp(i-1,j)] == tileWall) {
                    bool blockBelow = ([GridLogicManager getTypeAt:ccp(i,j+1)] == tileWall);
                    NSMutableArray* polygon = [[[NSMutableArray alloc] init] autorelease];
                    [polygon addObject:[Vec2 x:base.x-70 y:base.y-30]];        
                    [polygon addObject:[Vec2 x:base.x-70 y:base.y+70]];        
                    [polygon addObject:[Vec2 x:base.x-50 y:base.y+50]];        
                    [polygon addObject:[Vec2 x:base.x-50 y:base.y-(blockBelow?30:50)]];        
                    [leftBounds addObject:polygon];
                }
            }
        }        
    }    
    
    [SingleArtist drawSolidPolygons:leftBounds withColor:ccc4(100,100,100,255)];
    [SingleArtist drawSolidPolygons:topBounds  withColor:ccc4(200,200,200,255)];

    //[SingleArtist drawPolygons:topBounds texture:@"leather.jpg"];
    //[SingleArtist drawPolygons:leftBounds texture:@"leather.jpg"];
}

@end
