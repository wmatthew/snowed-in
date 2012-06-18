//
//  AppDelegate.h
//  Snowed In!!
//
//  Created by Matthew Webber on 5/21/11.
//  Copyright SquidMixer 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController; // MW

+ (AppDelegate*) getSingleton;

@end
