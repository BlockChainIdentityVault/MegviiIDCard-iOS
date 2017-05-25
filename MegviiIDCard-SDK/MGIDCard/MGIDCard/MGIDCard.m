//
//  MGIDCard.m
//  MGIDCard
//
//  Created by 张英堂 on 16/9/7.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCard.h"
#import "MG_Common.h"
#import "MG_IDCard.h"
#import "MGIDCardInfo.h"
#import "MGIDCardInfo_Creat.h"

@interface MGIDCard ()
{
    MG_IDC_APIHANDLE _apiHandle;
    MG_IDC_IMAGEHANDLE _imageHandle;
    float _flareNum;
}
@end

@implementation MGIDCard

-(void)dealloc{
    if (_apiHandle != NULL) {
        mg_idcard.ReleaseApiHandle(_apiHandle);
    }
    if (_imageHandle != NULL) {
        mg_idcard.ReleaseImageHandle(_imageHandle);
    }
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSException raise:@"提示！" format:@"请使用 MGFacepp initWithModel: 初始化方式！"];
    }
    return self;
}
#pragma mark - init
- (instancetype)initWithModel:(NSData *)modelData
{
    self = [super init];
    if (self) {
        if (modelData.length > 0) {
            const void *modelBytes = modelData.bytes;
            MG_RETCODE initCode = mg_idcard.CreateApiHandle((MG_BYTE *)modelBytes, (MG_INT32)modelData.length, &_apiHandle);
            
            if (initCode != 0) {
                NSLog(@"initWithModel error! code %d", initCode);
                return nil;
            }
            
            MG_IDC_APICONFIG config;
            mg_idcard.GetAPIConfig(_apiHandle, &config);
            mg_idcard.SetAPIConfig(_apiHandle, &config);

            self.orientation = 0;
        }else{
            return nil;
        }
        
        self.isCard = -1.0;
        self.inBound = 0.8;
        self.clear = 0.8;
        
        self.shadow_area_th = 300;
        self.facula_area_th = 300;
        self.card_area_th = 20;
        
        self.flareType = YES;
    }
    return self;
}

#pragma mark - setting config
-(void)setOrientation:(int)orientation{
    _orientation = orientation;
    
    MG_IDC_APICONFIG config = [self getDetectConfig];
    config.orientation = orientation;
    [self setDetectConfig:config];
}

-(void)setDetectROI:(MegIDCardROI)detectROI{
    _detectROI = detectROI;
    
    MG_RECTANGLE angle;
    angle.left = detectROI.left;
    angle.top = detectROI.top;
    angle.right = detectROI.right;
    angle.bottom = detectROI.bottom;
        
    MG_IDC_APICONFIG config = [self getDetectConfig];
    config.roi = angle;
    [self setDetectConfig:config];
}

-(void)setShadow_area_th:(float)shadow_area_th{
    _shadow_area_th = shadow_area_th;
    
    MG_IDC_APICONFIG config = [self getDetectConfig];
    config.shadow_area_th = shadow_area_th;
    [self setDetectConfig:config];
}

- (void)setFacula_area_th:(float)facula_area_th{
    _facula_area_th = facula_area_th;
    
    MG_IDC_APICONFIG config = [self getDetectConfig];
    config.facula_area_th = facula_area_th;
    [self setDetectConfig:config];
}

-(void)setCard_area_th:(float)card_area_th{
    _card_area_th = card_area_th;
    MG_IDC_APICONFIG config = [self getDetectConfig];
    config.card_area_th = card_area_th;
    [self setDetectConfig:config];
}

- (MG_IDC_APICONFIG)getDetectConfig{
    MG_IDC_APICONFIG config;
    mg_idcard.GetAPIConfig(_apiHandle, &config);
    return config;
}

- (void)setDetectConfig:(MG_IDC_APICONFIG)config{
    MG_RETCODE code = mg_idcard.SetAPIConfig(_apiHandle, &config);
    if (code != MG_RETCODE_OK) {
        NSLog(@"参数设置失败！");
    }
}

#pragma mark - detect
-(MGIDCardInfo *)detectWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{

    @synchronized (self) {

        MegIDCardRawData tempRawData = MGIDCardRawDataFromSampleBuffer(sampleBuffer);
        
        MGIDCardInfo *cardInfo = [self detectWithTempRawData:tempRawData];
        UIImage *image = MGIDCardImageFromSampleBuffer(sampleBuffer, UIImageOrientationRight);
        cardInfo.image = image;
        
//        free(tempRawData.rawData);
        
        return cardInfo;
    }
}

- (MGIDCardInfo *)detectWithImage:(UIImage *)image{
    @synchronized (self) {
        
        CGImageRef imageRef = image.CGImage;
        
        MegIDCardRawData tempRawData = MGIDCardRawDataFromImageRef(imageRef);
        
        MGIDCardInfo *cardInfo = [self detectWithTempRawData:tempRawData];
        cardInfo.image = image;
        
        free(tempRawData.rawData);
        
        return cardInfo;
    }
}

- (MGIDCardInfo *)detectWithTempRawData:(MegIDCardRawData)tempRawData{
    @synchronized (self) {
        @autoreleasepool {

            NSDate *date1, *date2;
            date1 = [NSDate date];
            
            MGIDCardInfo *cardInfo = [[MGIDCardInfo alloc] init];

            int width = tempRawData.width;
            int height = tempRawData.height;
            
            if (NULL == _imageHandle) {
                MG_RETCODE imageCode = mg_idcard.CreateImageHandle(width, height, &_imageHandle);
            }
            
            unsigned char *GrayTargetData = (unsigned char*)tempRawData.rawData;
            MG_RETCODE setImageCode = mg_idcard.SetImageData(_imageHandle, GrayTargetData, MG_IMAGEMODE_RGBA);
//            NSLog(@"setImageCode -> %zi --%zi", setImageCode, sizeof(GrayTargetData));
            
            
            MG_IDC_CONFIDENCE confidence;
            MG_RETCODE detectCode = mg_idcard.Detect(_apiHandle, _imageHandle, &confidence);
//            NSLog(@"detect -> %zi", detectCode);
            
            cardInfo.isIdcard = confidence.is_idcard;
            cardInfo.inBound = confidence.in_bound;
            cardInfo.clear = confidence.clear;
            
            MegIDCardFrameErrorType errorType = MegIDCardFrameErrorNone;
            
            if (confidence.is_idcard >= self.isCard &&
                confidence.in_bound >= self.inBound &&
                confidence.clear >= self.clear) {
                
                MG_IDC_QUALITY *quality;
                mg_idcard.CalculateQuality(_apiHandle, _imageHandle, self.flareType, &quality, nil, nil, nil);
                
                [cardInfo setCardFrame:quality->idcard];
                [cardInfo setShadows:quality->shadow];
                [cardInfo setFaculae:quality->faculae];
                
                if (quality->faculae.size > 0) {
                    errorType = MegIDCardFrameErrorFlare;
                }else if (quality->shadow.size > 0) {
                    errorType = MegIDCardFrameErrorShadow;
                }
                
                mg_idcard.ReleaseQuality(quality);
            }else{
                if (confidence.in_bound < self.inBound){
                    errorType = MegIDCardFrameErrorOffset;
                }else if (confidence.is_idcard < self.isCard) {
                    errorType = MegIDCardFrameErrorNoCard;
                }else if (confidence.clear < self.clear){
                    errorType = MegIDCardFrameErrorClear;
                }
            }
            date2 = [NSDate date];
            double timeUsed = [date2 timeIntervalSinceDate:date1]*1000;

            cardInfo.errorType = errorType;
            cardInfo.timeUsed = timeUsed;
            
            return cardInfo;
        }
    }
}

-(void)stopDetect{
    
}

#pragma mark - get sdk info
+ (NSDate *)getApiExpiration{
    uint64_t time = mg_idcard.GetApiExpiration();
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    return date;
}

//获取API 联网授权使用
+ (NSUInteger)getAPIName{
    NSUInteger result = (NSUInteger)mg_idcard.GetApiVersion;
    return result;
}

+ (NSString *)getVersion{
    const char *tempStr = mg_idcard.GetApiVersion();
    NSString *string = [NSString stringWithCString:tempStr encoding:NSUTF8StringEncoding];
    
    return string;
}

+ (BOOL)needNetLicense{
    MG_SDKAUTHTYPE type = mg_idcard.GetSDKAuthType();
    if (MG_ONLINE_AUTH == type) return YES;
    
    return NO;
}


#pragma mark - 工具
CG_EXTERN MegIDCardRawData MGIDCardRawDataFromSampleBuffer(CMSampleBufferRef sampleBuffer){
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    return MegIDCardRawDataMake((int)width, (int)height, baseAddress);
}

CG_EXTERN MegIDCardRawData MGIDCardRawDataFromImageRef(CGImageRef imageRef){
    MegIDCardRawData rawData;
    rawData.rawData = MGIDCardGetRGBAData(imageRef);
    
    rawData.width = (int)CGImageGetWidth(imageRef);
    rawData.height = (int)CGImageGetHeight(imageRef);
    
    return rawData;
}

CG_EXTERN unsigned char *MGIDCardGetRGBAData(CGImageRef imageRef){
    
//    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
//    NSData *data = (__bridge NSData*)CGDataProviderCopyData(provider);
//    
//    const unsigned char *rawData = [data bytes];
//    
//    CGDataProviderRelease(provider);
    int RGBA = 4;
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) malloc(width*height*4*sizeof(unsigned char));
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return rawData;
}

CG_EXTERN UIImage* MGIDCardImageFromSampleBuffer(CMSampleBufferRef sampleBuffer, UIImageOrientation orientation){
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:orientation];
    
    CGImageRelease(quartzImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

@end
