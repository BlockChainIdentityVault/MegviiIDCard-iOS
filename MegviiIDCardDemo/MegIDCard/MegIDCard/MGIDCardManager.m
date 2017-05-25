//
//  MGIDCardManager.m
//  MGIDCardKit
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardManager.h"
#import "MGIDCard.h"
#import "MGIDCardDetectManager.h"
#import "MGIDCardViewController.h"

@implementation MGIDCardManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setScreenOrientation:MGIDCardScreenOrientationLandscapeLeft];
        self.flareType = YES;
    }
    return self;
}

- (void)IDCardStartDetection:(UIViewController *)ViewController
                      finish:(void(^)(MGIDCardInfo *model))finish
                        errr:(void(^)(MGIDCardCancelType errorType))error{
#if TARGET_IPHONE_SIMULATOR
    if (error)
        error(MGIDCardErrorSimulator);
#else
    NSString *modelPaht = [[NSBundle mainBundle] pathForResource:IDCardModelName ofType:IDCardModelType];
    
    MGIDCardDetectManager *cardCheckManager = [[MGIDCardDetectManager alloc] initWithModelPath:modelPaht];
    [cardCheckManager setVideoSize:[MGAutoSessionPreset autoSessionPresetSize]];

    [cardCheckManager setInBound:self.inBound];
    [cardCheckManager setClear:self.clear];
    [cardCheckManager setIsIdcard:self.isCard];
    [cardCheckManager setFlareType:self.flareType];
    
    NSString *sessionFrame = [MGAutoSessionPreset autoSessionPreset];
    
    MGVideoManager *videoManager = [MGVideoManager videoPreset:sessionFrame
                                                devicePosition:AVCaptureDevicePositionBack
                                                   videoRecord:NO
                                                    videoSound:NO];
    
    MGIDCardViewController *first = [[MGIDCardViewController alloc] initWithNibName:nil bundle:nil];
    [first setVideoManager:videoManager];
    [first setCardCheckManager:cardCheckManager];
    [first setDebug:self.debug];

    [first setFinishBlock:finish];
    [first setErrorBlcok:error];
    
    if (MG_IOS_SysVersion < 8.0) {
        [first setScreenOrientation:MGIDCardScreenOrientationPortrait];
    }else{
        [first setScreenOrientation:self.screenOrientation];
    }
    
    [ViewController presentViewController:first animated:YES completion:nil];
#endif
}



/**
 *  获取 身份证 SDK版本号
 *
 *  @return sdk 版本号
 */
+ (NSString *)IDCardVersion{
    
    return [MGIDCard getVersion];
}

@end
