//
//  MGIDCardDetectBaseViewController.h
//  MGIDCard
//
//  Created by 张英堂 on 16/8/10.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGBaseKit/MGBaseKit.h>

#import "MGIDCardDetectManager.h"


@interface MGIDCardDetectBaseViewController : UIViewController<MGVideoDelegate>

/**
 *  不使用默认配置设置的时候，必须设置该对象
 */
@property (nonatomic, strong) MGVideoManager *videoManager;
@property (nonatomic, strong) MGIDCardDetectManager *cardCheckManager;

@property (nonatomic) dispatch_queue_t detectImageQueue;;


/**
 *  视频预览layer
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


/**
 *  屏幕方向 默认竖屏模式
 */
@property (nonatomic, assign) MGIDCardScreenOrientation screenOrientation;


/**
 *  检测到每一帧的错误
 *  子类重写即可
 *  @param frameResult 错误列表
 */
-(void)detectFrame:(MGIDCardInfo *)frameResult;

/**
 *  身份证检测成功
 *  子类重写
 *  @param result 检测结果
 */
- (void)detectSucess:(MGIDCardInfo *)result;


@end
