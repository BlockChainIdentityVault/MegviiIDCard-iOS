//
//  MGIDCardDetectManager.m
//  MGIDCardKit
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardDetectManager.h"

#import "MGIDCard.h"

@interface MGIDCardDetectManager ()

@property (nonatomic, strong) MGIDCard *cardDetect;

@property (nonatomic, assign) BOOL canDetect;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, assign) UIImageOrientation Orientation;


@end


@implementation MGIDCardDetectManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSException raise:@"警告！" format:@"请使用 MGIDCardDetectManager initWithModelPath： 初始化！"];
    }
    return nil;
}

- (instancetype)initWithModelPath:(NSString *)modelPath
{
    self = [super init];
    if(self) {
      
        NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
        if (!modelData) {
            [NSException raise:@"警告！" format:@"请输入正确的 modelPath!"];
            return nil;
        }
        
        self.cardDetect = [[MGIDCard alloc] initWithModel:modelData];
        self.IDCardScaleRect = MGIDCardScaleZero();
        
        self.isIdcard = 0.5;
        self.inBound = 0.8;
        self.clear = 0.9;
        
        self.screenOrientation = MGIDCardScreenOrientationPortrait;
        self.canDetect = YES;
    }
    return self;
}

-(void)setScreenOrientation:(MGIDCardScreenOrientation)screenOrientation{
    _screenOrientation = screenOrientation;
    
    switch (screenOrientation) {
        case MGIDCardScreenOrientationPortrait:
        {
            self.Orientation = UIImageOrientationRight;
        }
            break;
        case MGIDCardScreenOrientationLandscapeLeft:
        {
            self.Orientation = UIImageOrientationUp;
        }
            break;
        default:
            break;
    }
}

- (BOOL)creatAndSetROI{
    if (CGSizeEqualToSize(CGSizeZero, self.videoSize) == YES){
        NSLog(@"error MGIDCardDetectManager -> 请设置 videosize！");
        return NO;
    }
    if (MGIDCardScaleIsZero(self.IDCardScaleRect) == YES) {
        NSLog(@"error MGIDCardDetectManager -> 请设置 IDCardScaleRect！");
        return NO;
    }
    CGSize videoSize = self.videoSize;
    
    CGFloat angeleL, angeleT, angeleH, angeleW;
    
    if (self.Orientation == UIImageOrientationUp) {
        angeleH = videoSize.height* (1-self.IDCardScaleRect.y*2);
        angeleW = angeleH * self.IDCardScaleRect.WHScale;
        
        angeleL = videoSize.width * self.IDCardScaleRect.x;
        angeleT = videoSize.height* self.IDCardScaleRect.y;
    }else{
        angeleL = videoSize.width * self.IDCardScaleRect.y;
        angeleT = videoSize.height* self.IDCardScaleRect.x;
        angeleH = videoSize.height * (1-self.IDCardScaleRect.x*2);
        angeleW = angeleH / self.IDCardScaleRect.WHScale;
    }
    
    CGRect noScaleRect = CGRectMake(angeleL, angeleT, angeleW, angeleH);
    CGRect scaleRect = [self expandFaceRect:noScaleRect imageSize:videoSize scale:(16.0/13.0-1)];
    
//    NSLog(@"显示区域:%@", NSStringFromCGRect(noScaleRect));
//    NSLog(@"裁剪区域:%@", NSStringFromCGRect(scaleRect));

    self.cropRect = scaleRect;
    
    MegIDCardROI rectangle;
    rectangle.left = scaleRect.origin.x;
    rectangle.top = scaleRect.origin.y;
    rectangle.right = scaleRect.origin.x + scaleRect.size.width;
    rectangle.bottom = scaleRect.origin.y + scaleRect.size.height;

    [self.cardDetect setDetectROI:rectangle];
    
    int orientation = [self orientationChange:self.Orientation];
    [self.cardDetect setOrientation:orientation];
    
    return YES;
}

-(void)setInBound:(float)inBound{
    _inBound = inBound;
    
    [self.cardDetect setInBound:_inBound];
}

-(void)setIsIdcard:(float)isIdcard{
    _isIdcard = isIdcard;
    
    [self.cardDetect setIsCard:_isIdcard];
}
-(void)setClear:(float)clear{
    _clear = clear;
    
    [self.cardDetect setClear:_clear];
}

- (void)setShadow_area_th:(float)shadow_area_th{
    _shadow_area_th = shadow_area_th;
    [self.cardDetect setShadow_area_th:shadow_area_th];
}

-(void)setCard_area_th:(float)card_area_th{
    _card_area_th = card_area_th;
    [self.cardDetect setCard_area_th:card_area_th];
}

-(void)setFacula_area_th:(float)facula_area_th{
    _facula_area_th = facula_area_th;
    [self.cardDetect setFacula_area_th:facula_area_th];
}

-(void)setFlareType:(BOOL)flareType{
    _flareType = flareType;
    
    [self.cardDetect setFlareType:flareType];
}

#pragma mark - detect
-(MGIDCardInfo *)detectWithImage:(UIImage *)image{
    [self setVideoSize:image.size];
    
    if (self.canDetect) {
        MGIDCardInfo *info = [self.cardDetect detectWithImage:image];
        info.orientation = self.Orientation;
        info.detectRect = self.cropRect;

        return info;
    }
    return nil;
}

-(MGIDCardInfo *)detectWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (self.canDetect) {
        MGIDCardInfo *info = [self.cardDetect detectWithSampleBuffer:sampleBuffer];
        info.orientation = self.Orientation;
        info.detectRect = self.cropRect;

        return info;
    }
    return nil;
}

-(void)stopDetect{
    self.canDetect = NO;
}

#pragma mark - 扩大裁剪框
-(CGRect)expandFaceRect:(CGRect)rect imageSize:(CGSize )size scale:(CGFloat)scale{
    if (scale <= 0) {
        return  CGRectZero;
    }
    CGRect tempRect = CGRectZero;
    
    CGFloat left = rect.origin.x;
    CGFloat top = rect.origin.y;
    CGFloat right = size.width - rect.origin.x - rect.size.width;
    CGFloat bottom = size.height - rect.origin.y - rect.size.height;
    
    CGFloat minWidth = (left > right ? right :left);
    CGFloat minHeight = (top > bottom ? bottom :top);
    
    CGFloat maxSW = (rect.size.width * scale > minWidth ? minWidth/rect.size.width :scale);
    CGFloat maxSH = (rect.size.height * scale > minHeight ? minHeight/rect.size.height :scale);
    
    CGFloat sScale = maxSW > maxSH ? maxSH : maxSW;
    
    CGFloat scaleWidth = rect.size.width * sScale   *1.0;
    CGFloat scaleHeight = rect.size.height * sScale *1.0;
    
    tempRect.origin.x = rect.origin.x-scaleWidth;
    tempRect.origin.y = rect.origin.y-scaleHeight;
    tempRect.size.width = rect.size.width + scaleWidth*2;
    tempRect.size.height = rect.size.height + scaleHeight*2;
    
    return tempRect;
}

- (int)orientationChange:(UIImageOrientation)orientation{
    int a = 0;
    switch (orientation) {
        case UIImageOrientationRight:
            a = 90;
            break;
        case UIImageOrientationLeft:
            a = 270;
            break;
        default:
            a = 0;
            break;
    }
    return a;
}

@end
