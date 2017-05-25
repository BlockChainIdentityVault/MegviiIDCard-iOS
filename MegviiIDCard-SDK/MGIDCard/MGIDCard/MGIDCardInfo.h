//
//  MGIDCardInfo.h
//  MGIDCard
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGIDCardCommon.h"

@interface MGIDCardInfo : NSObject

/**  检测失败类型 */
@property (nonatomic, assign) MegIDCardFrameErrorType errorType;

@property (nonatomic, assign) float isIdcard;
@property (nonatomic, assign) float inBound;
@property (nonatomic, assign) float clear;

@property (nonatomic, assign) double timeUsed;


/**  身份证边框点的数组 */
@property (nonatomic, strong) NSArray <NSValue *>*cardPointArray; //CGPoint

/** 阴影框的数组 */
@property (nonatomic, strong) NSMutableArray <NSArray *>*shadowsArray; //CGPoint

/** 光斑框的数组 */
@property (nonatomic, strong) NSMutableArray <NSArray *>*faculaeArray; //CGPoint

/**  图片的检测方向 （需要根据该方向进行裁剪图片） */
@property (nonatomic, assign) UIImageOrientation orientation;

/**  检测的图片，整图 */
@property (nonatomic, strong) UIImage *image;

/**  图片的裁剪区域 */
@property (nonatomic, assign) CGRect detectRect;

/**
 *  获取只有身份证的区域，
 *  @return 图片
 */
-(UIImage *)cropIDCardImage;



@end
