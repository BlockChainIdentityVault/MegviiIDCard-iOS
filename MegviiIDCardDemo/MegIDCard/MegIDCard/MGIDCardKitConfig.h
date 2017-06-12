//
//  MGIDCardKitConfig.h
//  MGIDCardKit
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#ifndef MGIDCardKitConfig_h
#define MGIDCardKitConfig_h

#import <UIKit/UIKit.h>

@class MGIDCardInfo;

static NSString *const IDCardModelName = @"megviiidcard_0_3_0_model";
static NSString *const IDCardModelType = @"";

/**
 *  身份证检测失败类型
 */
typedef NS_ENUM(NSInteger, MGIDCardCancelType) {
    /** 模拟器 */
    MGIDCardErrorSimulator,
    /**  取消检测 */
    MGIDCardErrorCancel,
};

/**
 *  身份证检测屏幕样式
 */
typedef NS_ENUM(NSInteger, MGIDCardScreenOrientation) {
    /**  屏幕竖直 样式 */
    MGIDCardScreenOrientationPortrait,
    /**  左横屏 样式 */
    MGIDCardScreenOrientationLandscapeLeft,
};

typedef void(^VoidBlock_error)(MGIDCardCancelType errorType);
typedef void(^VoidBlock_result)(MGIDCardInfo *model);

/**
 *  身份证区域相对于图片整体比例
 */
typedef struct {
    CGFloat x;              //距离左边的偏移，除去身份证宽度剩余部分的相对值(在竖屏模式下，直接为宽度的比例，该值必须大于0.094)
    CGFloat y;              //距离顶部的偏移 相对值
    CGFloat WHScale;        //身份证宽度与高度的比例 （85.6/54.0 固定值）
}MGIDCardScale;

CG_INLINE MGIDCardScale MGIDCardScaleMake(CGFloat x, CGFloat y){
    MGIDCardScale s;
    s.y = y;
    s.x = x;
    s.WHScale = 85.6 / 54.0;
    return s;
}

CG_INLINE BOOL MGIDCardScaleIsZero(MGIDCardScale scale){
    return !(scale.y || scale.x || scale.WHScale);
}

/**
 *  默认的身份证区域比例
 */
CG_INLINE  MGIDCardScale  MGIDCardDefaultScale(){
    return MGIDCardScaleMake(0.2, 0.2);
}
CG_INLINE  MGIDCardScale  MGIDCardScaleZero(){
    return MGIDCardScaleMake(0, 0);
}


#ifdef DEBUG
#define MGLog(FORMAT, ...) fprintf(stderr,"%s:%d   \t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define MGLog(...)
#endif


#endif /* MGIDCardKitConfig_h */
