//
//  MGLicenseHandle.h
//  MGSDKV2Test
//
//  Created by 张英堂 on 16/9/7.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MGNetConfig.h"


@interface MGLicenseHandle : NSObject

/**
 *  获取当前SDK是否授权--- 子类需要重写该方法，通过该类获取的 是否授权无法全部包括使用的SDK
 *
 *  @return 是否授权
 */
+ (BOOL)getLicense;

+ (NSDate *)getLicenseDate;

/**
 *  只有当授权时间少于 1 小时的时候，才会进行授权操作
 *
 *  @param finish 
 */
+ (void)licenseForNetWokrFinish:(void(^)(bool License, NSDate *sdkDate))finish;


@end
