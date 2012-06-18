//
//  BoxControlRoom.m
//  Snowed In!!
//
//  Created by Matthew Webber on 10/30/11.
//  Copyright (c) 2011 SquidMixer. All rights reserved.
//

#import "BoxControlRoom.h"
#import "SquidLog.h"

@implementation BoxControlRoom

static NSString *FREE_BUNDLE_ID = @"com.squidmixer.snowedin.free";
static NSString *PAID_BUNDLE_ID = @"com.squidmixer.snowedin.standard";

+ (appVersion) getMyAppVersion {
    NSString *myBundle = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([myBundle isEqualToString:FREE_BUNDLE_ID]) {
        [SquidLog info:@"App is Free."];
        return appVersionFree;
    } else if ([myBundle isEqualToString:PAID_BUNDLE_ID]) {
        [SquidLog info:@"App is Paid."];
        return appVersionPaid;    
    } else {
        [SquidLog error:@"Unrecognized bundle ID- unclear if paid or free. Defaulting to paid."];
        return appVersionPaid;
    }
}

@end
