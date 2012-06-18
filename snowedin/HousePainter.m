//
//  HousePainter.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/20/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import "HousePainter.h"
#import "SquidLog.h"

@implementation HousePainter

static NSMutableDictionary *_houseColors;

+ (void) initialize {
    _houseColors = [[[NSMutableDictionary alloc] init] retain];
    [self setColor:groupIntro base:ccc3(143,217,250) trim:ccc3(0,99,173)]; // light blue

    [self setColor:groupInvert1 base:ccc3(224,149,206) trim:ccc3(194,42,156)]; // light purp
    [self setColor:groupInvert2 base:ccc3(194,42,156) trim:ccc3(224,149,206)]; // light purp inv

    [self setColor:groupB base:ccc3(141,168,81)  trim:ccc3(62,102,14)]; // olive

    [self setColor:groupC base:ccc3(252,189,186) trim:ccc3(152,59,54)]; // peach
    
    [self setColor:groupD base:ccc3(183,172,129) trim:ccc3(82,79,32)]; // beige
    [self setColor:groupE base:ccc3(179,147,131) trim:ccc3(84,36,15)]; // beige/brown
    
    [self setColor:groupF base:ccc3(249,155,148) trim:ccc3(76,20,18)]; // pink
    [self setColor:groupG base:ccc3(199,105,98) trim:ccc3(76,20,18)]; // darker pink
    [self setColor:groupH base:ccc3(249,155,148) trim:ccc3(76,20,18)]; // pink
    
    [self setColor:groupI base:ccc3(255,249,74)  trim:ccc3(121,95,29)]; // yellow
    [self setColor:groupJ base:ccc3(255,249,74)  trim:ccc3(121,95,29)]; // yellow
    [self setColor:groupK base:ccc3(233,2,23)    trim:ccc3(115,4,64)]; // red
    [self setColor:groupL base:ccc3(234,67,22)    trim:ccc3(60,20,10)]; // red
    [self setColor:groupM base:ccc3(255,122,41)   trim:ccc3(102,40,16)]; // orange
    [self setColor:groupN base:ccc3(255,249,74)  trim:ccc3(121,95,29)]; // yellow
    [self setColor:groupO base:ccc3(174,147,57)    trim:ccc3(60,60,60)]; // brown
    [self setColor:groupP base:ccc3(174,147,57)    trim:ccc3(60,60,60)]; // brown
    
    [self setColor:groupQ base:ccc3(101,208,254)   trim:ccc3(35,63,156)]; // pastel blue
    [self setColor:groupR base:ccc3(199,132,175)  trim:ccc3(80,30,80)]; // purple
    [self setColor:groupS base:ccc3(120,205,0)    trim:ccc3(22,74,0)]; // bright green
    [self setColor:groupT base:ccc3(199,233,158)    trim:ccc3(97,161,97)]; // bland green
    [self setColor:groupU base:ccc3(101,208,254)   trim:ccc3(35,63,156)]; // pastel blue 
    [self setColor:groupV base:ccc3(199,132,175)  trim:ccc3(80,30,80)]; // purp
    [self setColor:groupW base:ccc3(51,115,195)   trim:ccc3(15,25,94)]; // dark blue
    [self setColor:groupX base:ccc3(51,115,195)   trim:ccc3(15,25,94)]; // dark blue
}

+ (void) setColor:(levelGroup)house base:(ccColor3B)baseColor trim:(ccColor3B)trimColor {
    [_houseColors setObject:[[[HousePainter alloc] initWithBase:baseColor trim:trimColor] autorelease]
                     forKey:[NSNumber numberWithInt:house]];
}

- (id) initWithBase:(ccColor3B)baseColor trim:(ccColor3B)trimColor {
    if (( self = [super init] )) {
        _baseColor = baseColor;
        _trimColor = trimColor;    
    }
    return self;
}

+ (ccColor3B) getBaseColor:(levelGroup)group {
    HousePainter *painter = [_houseColors objectForKey:[NSNumber numberWithInt:group]];
    if (painter != nil) {
        return [painter getBaseColor];
    } else {
        [SquidLog warn:@"using default color for group %@", [LevelManager getGroupDisplayTitle:group]];
        return ccc3(200,200,250);
    }
}

+ (ccColor3B) getTrimColor:(levelGroup)group {
    HousePainter *painter = [_houseColors objectForKey:[NSNumber numberWithInt:group]];
    if (painter != nil) {
        return [painter getTrimColor];
    } else {
        [SquidLog warn:@"using default color for group %@", [LevelManager getGroupDisplayTitle:group]];
        return ccc3(150,150,200);
    }
}

- (ccColor3B) getBaseColor {
    return _baseColor;
}

- (ccColor3B) getTrimColor {
    return _trimColor;
}


@end
