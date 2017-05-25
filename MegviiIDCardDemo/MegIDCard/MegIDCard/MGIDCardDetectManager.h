//
//  MGIDCardDetectManager.h
//  MGIDCardKit
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGIDCardKitConfig.h"
#import <CoreMedia/CoreMedia.h>

#import "MGIDCardInfo.h"


@interface MGIDCardDetectManager : NSObject


- (instancetype)initWithModelPath:(NSString *)modelPath;


@property (nonatomic, assign) MGIDCardScale IDCardScaleRect;

/**  是否为身份证 默认值 -1 （0 - 1.0， -1 为忽略该判断条件）*/
@property (nonatomic, assign) float isIdcard;

/** 是否在引导框内 默认值 （0 - 1.0）*/
@property (nonatomic, assign) float inBound;

/**  是否清晰 默认值 0.8 （0 - 1.0） */
@property (nonatomic, assign) float clear;

/**  被判定为阴影的最小面积 默认 300 （0 - 256*160）*/
@property (nonatomic, assign) float shadow_area_th;

/**  被判定为光斑的最小面积 默认值 300 */
@property (nonatomic, assign) float facula_area_th;

/**  被判定为身份证的最小面积，默认 20 */
@property (nonatomic, assign) float card_area_th;


/**  设置检测区域（为视频流原图的区域），默认为空，必须设置 */
@property (nonatomic, assign) MegIDCardROI detectROI;

/**  光斑检测是否过滤 默认 是 */
@property (nonatomic, assign) BOOL flareType;


/**
 *  如果检测为视频流，必须在检测之前设置该对象
 */
@property (nonatomic, assign) CGSize videoSize;


/**
 *  屏幕方向，默认横屏
 */
@property (nonatomic, assign) MGIDCardScreenOrientation screenOrientation;

/**
 *  设置图片的检测区域，为 未旋转 的区域，必须在设置 videoSize 和 screenOrientation 之后调用
 *  @return 是否设置成功
 */
- (BOOL)creatAndSetROI;

/**
 *  检测每帧
 *
 *  @param sampleBuffer        检测的图片
 */
- (MGIDCardInfo *)detectWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (MGIDCardInfo *)detectWithImage:(UIImage *)image;

/**
 *  停止所有检测
 */
- (void)stopDetect;

@end
