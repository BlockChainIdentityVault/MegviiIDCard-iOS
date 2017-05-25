//
//  MGIDCardManager.h
//  MGIDCardKit
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGBaseKit/MGBaseKit.h>

#import "MGIDCardKitConfig.h"
#import "MGIDCardInfo.h"

@interface MGIDCardManager : NSObject

/**
 *  设置屏幕方向，默认水平方向 MGIDCardScreenOrientationPortrait；
 */
@property (nonatomic, assign) MGIDCardScreenOrientation screenOrientation;

@property (nonatomic, assign) BOOL flareType;

@property (nonatomic, assign) BOOL debug;


@property (nonatomic, assign) float isCard;
@property (nonatomic, assign) float inBound;
@property (nonatomic, assign) float clear;


/**
 *  开启身份证检测
 *
 *  @param ViewController 启动的界面，最后结束返回该界面
 *  @param finish         身份证检测完成 block
 *  @param error          用户检测取消
 */
- (void)IDCardStartDetection:(UIViewController *)ViewController
                      finish:(void(^)(MGIDCardInfo *model))finish
                        errr:(void(^)(MGIDCardCancelType errorType))error;


/**
 *  获取 身份证 SDK版本号
 *
 *  @return sdk 版本号
 */
+ (NSString *)IDCardVersion;


@end
