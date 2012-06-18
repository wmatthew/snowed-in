//
//  Art.m
//  Snowed In!!
//
//  Created by Matthew Webber on 6/2/11.
//  Copyright 2011 SquidMixer. All rights reserved.

#import "Art.h"
#import "boxpusher.h"

@implementation Art

+ (void) initialize {
    if ([Dimensions isIPad]) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"build-progress-hd.plist"]; // Force iPad to get HD images
    } else {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"build-progress.plist"];        
    }
}

+ (bool) isSpriteSheetImage:(artResource) resource {
    return (
            resource == img_progress_ball1 ||
            resource == img_progress_ball2 ||
            resource == img_progress_ball3 ||
            resource == img_progress_hat ||
            resource == img_progress_eyes ||
            resource == img_progress_carrot ||
            resource == img_progress_mouth ||
            resource == img_progress_arms ||
            resource == img_progress_buttons ||
            resource == img_progress_joy
            );
}

+ (CCSprite*) sprite:(artResource)resource {

    NSString *imageName = [self getImageNameStringCorrectForDevice:resource];
    //[SquidLog info:@"Getting sprite named: %@", imageName];

    CCSprite *ret;
    if ([self isSpriteSheetImage:resource]) {
        // Sprite in zwoptex spritesheet
        ret = [CCSprite spriteWithSpriteFrameName:imageName];
    } else {
        // Vanilla sprite
        ret = [CCSprite spriteWithFile:imageName];
    }
    
    // Some images are flipped horizontally
    if (resource == sm_redo || resource == sm_fast_forward || resource == sm_right_arrow) {
        [ret setFlipX:YES];
    }
    
    if (ret == nil) {
        [SquidLog error:@"image is nil: %@", imageName];
    }

    return ret;
}

+ (CCTexture2D*) texture:(artResource)resource {
    return [[CCTextureCache sharedTextureCache] addImage: [Art getImageNameStringCorrectForDevice:resource]];
}

+ (UIImage*) getUIImage:(artResource)resource {
    return [UIImage imageNamed:[Art getImageNameStringCorrectForDevice:resource]];
}

+ (NSString*) getImageNameStringCorrectForDevice:(artResource)resource {
    NSString *rawString = [self getImageNameStringRaw:resource];
    
    NSRange hdRange = [rawString rangeOfString:@"-hd.png"];
    if (hdRange.location != NSNotFound) {
        [SquidLog warn:@"raw image string is already using -hd version? %@", rawString];
        return rawString;
    }
    
    if ([Dimensions isIPad] == NO) {
        return rawString;
    }
    
    if ([self isSpriteSheetImage:resource]) {
        return rawString; // already using -hd spritesheet.
    }

    // These images have special ipad versions.
    if (resource == img_mountains ||
        resource == img_hill ||
        resource == img_hill_patches ||
        resource == img_hud_snow
        ) {
        return [rawString stringByReplacingOccurrencesOfString:@".png" withString:@"-ipad.png"];        
    }

    // These images have @2x versions (but not -hd versions0)
    if (resource == img_store_add ||
        resource == img_store_green_check ||
        resource == img_store_grey_check ||
        resource == img_store_question
        ) {
        return [rawString stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];        
    }

    return [rawString stringByReplacingOccurrencesOfString:@".png" withString:@"-hd.png"];    
}

+ (NSString*) getImageNameStringRaw:(artResource)resource {
    switch (resource) {
            
        case img_snowman:
            return @"snowman.png";
        case img_snowman_push:
            return @"snowman-push.png";
        case sm_snowflake:
            return @"snowflake.png";
        case sm_invert:
            return @"snow-dark.png";
        case sm_blank:
            return @"blank.png";
        case sm_square:
            return @"square.png";
        case sm_soft_square:
            return @"SoftSquare.png";

        case sm_music:
            return @"music.png";
        case sm_nomusic:
            return @"nomusic.png";
        case sm_sound:
            return @"sound.png";
        case sm_nosound:
            return @"nosound.png";
        case sm_undo:
            return @"undo.png";
        case sm_redo:
            return @"undo.png"; // flipped later
        case sm_rewind:
            return @"rewind.png";
        case sm_fast_forward:
            return @"rewind.png"; // flipped later
        case sm_pack:
            return @"pack.png";
        case sm_left_arrow:
            return @"left_arrow.png";
        case sm_right_arrow:
            return @"left_arrow.png"; // flipped later
        case sm_bulb:
            return @"bulb.png";
        case sm_tip:
            return @"tip.png";
        case img_replay:
            return @"replay.png";
                        
        case sm_houseBase:
            return @"house-base.png";
        case sm_houseTrim:
            return @"house-trim.png";
        case sm_houseRoof:
            return @"house-roof.png";
        case sm_houseLightSnow:
            return @"house-light-snow.png";
        case sm_houseHeavySnow:
            return @"house-heavy-snow.png";

        case sm_big_houseBase:
            return @"bhouse-base.png";
        case sm_big_houseTrim:
            return @"bhouse-trim.png";
        case sm_big_houseRoof:
            return @"bhouse-roof.png";
        case sm_big_houseLightSnow:
            return @"bhouse-light-snow.png";
        case sm_big_houseHeavySnow:
            return @"bhouse-heavy-snow.png";

        case sm_fire:
            return @"fire.png";
            
        case img_mountains:
            return @"mountains.png";
        case img_hud_snow:
            return @"hud-snow.png";
        case img_hill:
            return @"hill.png";
        case img_hill_patches:
            return @"hill-patches.png";

        case img_progress_ball1:
            return @"build-ball1.png";
        case img_progress_ball2:
            return @"build-ball2.png";
        case img_progress_ball3:
            return @"build-ball3.png";
        case img_progress_hat:
            return @"build-hat.png";
        case img_progress_eyes:
            return @"build-eyes.png";
        case img_progress_carrot:
            return @"build-carrot.png";
        case img_progress_mouth:
            return @"build-mouth.png";
        case img_progress_arms:
            return @"build-arms.png";
        case img_progress_buttons:
            return @"build-buttons.png";
        case img_progress_joy:
            return @"build-joy.png";
            
        case img_sign_left:
            return @"sign-left-arrow.png";
        case img_sign_right:
            return @"sign-right-arrow.png";
        case img_sign_mini:
            return @"sign-mini.png";
        case img_sign_box:
            return @"sign-box.png";
        case img_sign_big:
            return @"sign-big.png";
        case img_post_curve:
            return @"post-curve.png";
        case img_post_straight:
            return @"post-straight.png";
            
        case img_store_green_check:
            return @"green-check.png";
        case img_store_grey_check:
            return @"grey-check.png";
        case img_store_question:
            return @"question.png";
        case img_store_add:
            return @"add.png";
            
        case img_error_no_such_image:
            [SquidLog error:@"'img_error_no_such_image' resource not found: %@", resource];            
            return nil;

        default:
            [SquidLog error:@"Art resource not found: %@", resource];
            return nil;
    }
}

+ (NSString*) getSound:(soundResource) sound {
    switch (sound) {
            
        case push1_sound:
            return @"push1.aif";
        case push2_sound:
            return @"push2.aif";
        case invert1_sound:
            return @"invert1.aif";
        case invert2_sound:
            return @"invert2.aif";
        case press_sound:
            return @"press.aif";
        case redo_sound:
            return @"new_redo.aif";
        case undo_sound:
            return @"new_undo.aif";
        case win_sound:
            return @"win_level.aif";
        case frustrate_sound:
            return @"frustrate.aif";
        default:
            [SquidLog error:@"Art resource not found: %@", sound];
    }
    return @"";
}

+ (NSString*) menuMusic { 
    return @"frost_32.caf";
}

+ (NSString*) gameMusic {
    return @"delib_32.caf";
}

+ (void) precacheCommonImages {
    // TODO: precache more, apparently this actually helps. lol.
    [Art texture:sm_big_houseBase];
    [Art texture:sm_big_houseTrim];
    [Art texture:sm_big_houseRoof];
    [Art texture:sm_big_houseLightSnow];
    [Art texture:sm_big_houseHeavySnow];
}

@end
