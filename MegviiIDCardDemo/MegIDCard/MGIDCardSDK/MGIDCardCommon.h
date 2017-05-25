//
//  MegIDCardConfig.h
//  MegIDCard
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#ifndef MegIDCardConfig_h
#define MegIDCardConfig_h

typedef NS_ENUM(NSInteger, MegIDCardFrameErrorType) {
    MegIDCardFrameErrorNone,
    MegIDCardFrameErrorNoCard,
    MegIDCardFrameErrorOffset,
    MegIDCardFrameErrorClear,
    MegIDCardFrameErrorFlare,
    MegIDCardFrameErrorShadow
};

typedef struct {
    int left;
    int top;
    int right;
    int bottom;
}MegIDCardROI;


typedef struct {
    int width;
    int height;
    void *rawData;
}MegIDCardRawData;

CG_INLINE MegIDCardRawData MegIDCardRawDataMake(int width, int height, void *rawData){
    MegIDCardRawData d;
    d.width = width;
    d.height = height;
    d.rawData = rawData;
    return d;
}


#endif /* MegIDCardConfig_h */
