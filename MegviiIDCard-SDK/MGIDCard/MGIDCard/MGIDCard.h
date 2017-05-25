//
//  MGIDCard.h
//  MGIDCard
//
//  Created by 张英堂 on 16/9/7.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "MGIDCardCommon.h"

@class MGIDCardInfo;

@interface MGIDCard : NSObject

/**
 *  初始化方法，必须使用该方法
 *
 *  @param modelData model data
 *
 *  @return 实例化对象
 */
- (instancetype)initWithModel:(NSData *)modelData;


/**  是否为证件 默认值 0.9 （0 - 1.0）*/
@property (nonatomic, assign) float isCard;

/** 是否在引导框内 默认值 0.8（0 - 1.0）*/
@property (nonatomic, assign) float inBound;

/**  是否清晰 默认值 0.8 （0 - 1.0） */
@property (nonatomic, assign) float clear;

/**  被判定为阴影的最小面积 默认 300 （0 - 256*160）*/
@property (nonatomic, assign) float shadow_area_th;

/**  被判定为光斑的最小面积 默认值 300 */
@property (nonatomic, assign) float facula_area_th;

/**  被判定为身份证的最小面积，默认 20 */
@property (nonatomic, assign) float card_area_th;

/** 旋转角度 defalut 0, [0,90,180,270,360] */
@property (nonatomic, assign) int orientation;

/**  设置检测区域（为视频流原图的区域），默认为空，必须设置 */
@property (nonatomic, assign) MegIDCardROI detectROI;

/**  光斑检测是否过滤 默认 是 */
@property (nonatomic, assign) BOOL flareType;


/**
 *  检测每帧 - 异步进行
 *
 *  @param sampleBuffer        检测的图片
 */
- (MGIDCardInfo *)detectWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (MGIDCardInfo *)detectWithImage:(UIImage *)image;



#pragma mark - get sdk info
/**
 *  获取SDK授权终止时间
 *  @return 时间
 */
+ (NSDate *)getApiExpiration;


/** 获取API 联网授权使用 */
+ (NSUInteger)getAPIName;

/** 获取版本号 */
+ (NSString *)getVersion;

/* 获取SDK是否需要联网授权 */
+ (BOOL)needNetLicense;

@end
