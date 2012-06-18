//
//  Art.h
//  Snowed In!!
//
//  Created by Matthew Webber on 6/2/11.
//  Copyright 2011 SquidMixer. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCSprite, CCSpriteBatchNode, CCTexture2D;

typedef enum {
    
    img_error_no_such_image,
    
    // Tiles
    img_snowman,
    img_snowman_push,
    sm_snowflake,
    sm_invert,
    sm_blank,
    sm_square,
    sm_soft_square,
    
    // Buttons
    sm_music,
    sm_nomusic,
    sm_sound,
    sm_nosound,
    sm_left_arrow,
    sm_right_arrow,
    sm_pack,
    sm_rewind,
    sm_fast_forward,
    sm_undo,
    sm_redo,
    sm_bulb,
    sm_tip,
    img_replay,
    
    // Menu Art
    sm_houseBase,
    sm_houseTrim,
    sm_houseRoof,
    sm_houseLightSnow,
    sm_houseHeavySnow,
    sm_big_houseBase,
    sm_big_houseTrim,
    sm_big_houseRoof,
    sm_big_houseLightSnow,
    sm_big_houseHeavySnow,
    sm_fire,
    
    // Background images
    img_mountains,
    img_hud_snow,
    img_hill,
    img_hill_patches,
    img_progress_ball1,
    img_progress_ball2,
    img_progress_ball3,
    img_progress_hat,
    img_progress_eyes,
    img_progress_carrot,
    img_progress_mouth,
    img_progress_arms,
    img_progress_buttons,
    img_progress_joy,
    
    // Signs
    img_sign_right,
    img_sign_left,
    img_sign_mini,
    img_sign_box,
    img_sign_big,
    
    img_post_curve,
    img_post_straight,
    
    img_store_green_check,
    img_store_grey_check,
    img_store_question,
    img_store_add,
    
} artResource;

typedef enum {
    push1_sound,
    push2_sound,
    invert1_sound,
    invert2_sound,
    press_sound,
    undo_sound,
    redo_sound,
    win_sound,
    frustrate_sound,
} soundResource;

@interface Art : NSObject {    
}

+ (bool) isSpriteSheetImage:(artResource) resource;
+ (UIImage*) getUIImage:(artResource)resource;
+ (CCSprite*) sprite:(artResource)resource;
+ (NSString*) getImageNameStringRaw:(artResource)resource;
+ (NSString*) getImageNameStringCorrectForDevice:(artResource)resource;
+ (NSString*) getSound:(soundResource) sound;
+ (CCTexture2D*) texture:(artResource)resource;

+ (NSString*) menuMusic;
+ (NSString*) gameMusic;

+ (void) precacheCommonImages;

@end
