//
//  MGIDCardInfo.m
//  MGIDCard
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardInfo.h"
#import "MGIDCardInfo_Creat.h"

@implementation MGIDCardInfo

-(void)setCardFrame:(MG_IDC_POLYGON )card{
    self.cardPointArray = [self MGIDCPointToCGPoint:card];
}

- (void)setShadows:(MG_IDC_POLYGONS )shadows{
    if (self.shadowsArray == nil) {
        self.shadowsArray = [NSMutableArray arrayWithCapacity:shadows.size];
    }
    
    for (int i = 0; i < shadows.size; i++) {
        MG_IDC_POLYGON points = shadows.polygon[i];
        
        NSArray *array = [self MGIDCPointToCGPoint:points];
        [self.shadowsArray addObject:array];
    }
}

- (void)setFaculae:(MG_IDC_POLYGONS )faculae{
    if (self.faculaeArray == nil) {
        self.faculaeArray = [NSMutableArray arrayWithCapacity:faculae.size];
    }
    
    for (int i = 0; i < faculae.size; i++) {
        MG_IDC_POLYGON points = faculae.polygon[i];
        
        NSArray *array = [self MGIDCPointToCGPoint:points];
        [self.faculaeArray addObject:array];
    }
}

- (NSArray *)MGIDCPointToCGPoint:(MG_IDC_POLYGON )points{
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:points.size];
    
    for (int i = 0; i < points.size; i++) {
        MG_POINT point = points.vertex[i];
        CGPoint tempPoint = CGPointMake(point.x, point.y);
        
        [tempArray addObject:[NSValue valueWithCGPoint:tempPoint]];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

-(UIImage *)cropIDCardImage{
    UIImage *returnImage = nil;
    
    if (self.image) {
        UIImage *tempImage = MGIDCardCroppedImage(self.image, self.detectRect);
        
        returnImage = MGIDCardFixOrientationWithImageOrientation(tempImage, self.orientation);
    }
    return returnImage;
}


CG_EXTERN UIImage* MGIDCardCroppedImage(UIImage *image, CGRect bounds){
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

CG_EXTERN UIImage* MGIDCardFixOrientationWithImageOrientation(UIImage *image, UIImageOrientation orientation){
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGFloat height = 0, width = 0;
    
    switch (orientation) {
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            transform = CGAffineTransformTranslate(transform, -image.size.width, 0);
            
            width = image.size.height;
            height = image.size.width;
        }
            break;
        default:
        {
            width = image.size.width;
            height = image.size.height;
        }
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             width,
                                             height,
                                             CGImageGetBitsPerComponent(image.CGImage),
                                             0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (image.imageOrientation) {
        case UIImageOrientationRight:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        }
            break;
        case UIImageOrientationRightMirrored:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        }
            break;
        default:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
        }
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *resultImage = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return resultImage;
}

@end
