//
//  MGIDBoxLayer.h
//  MGIDCard
//
//  Created by 张英堂 on 16/8/11.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MGBaseKit/MGBaseKit.h>

typedef NS_ENUM(NSInteger, BoxLayerStyle) {
    BoxLayerStyleNoShadow = 0,
    BoxLayerStyleShadow = 1,
};



@interface MGIDBoxLayer : UIView


/**
 *  身份证区域
 */
@property (nonatomic, assign) CGRect IDCardBoxRect;


@property (nonatomic, assign) BoxLayerStyle style;


@end
