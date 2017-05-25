//
//  MGIDBoxLayer.m
//  MGIDCard
//
//  Created by 张英堂 on 16/8/11.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDBoxLayer.h"
#import "MGIDCardKitConfig.h"

@interface MGIDBoxLayer ()

//@property (nonatomic, strong) UIImage *messageImage;
//
//@property (nonatomic, strong) UIImageView *messageImageView;
@property (nonatomic, strong) UILabel *messageTextView;

@end

@implementation MGIDBoxLayer

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = BoxLayerStyleNoShadow;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}


//-(UIImage *)messageImage{
//    if (!_messageImage) {
//        NSString *imageName = @"card_front";
//        
//        _messageImage = [UIImage imageNamed:imageName];
//    }
//    return _messageImage;
//}
//
//-(UIImageView *)messageImageView{
//    if (!_messageImageView) {
//        _messageImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        [_messageImageView setContentMode:UIViewContentModeScaleAspectFit];
//        [_messageImageView setClipsToBounds:YES];
//        
//        [self addSubview:_messageImageView];
//    }
//    return _messageImageView;
//}

-(UILabel *)messageTextView{
    if (!_messageTextView) {
        _messageTextView = [[UILabel alloc] initWithFrame:CGRectZero];
        [_messageTextView setFont:[UIFont systemFontOfSize:20]];
        [_messageTextView setTextColor:[UIColor whiteColor]];
        [_messageTextView setNumberOfLines:0];
        [_messageTextView setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:_messageTextView];
    }
    return _messageTextView;
}
//
//- (void)drawImage:(UIImage *)image rect:(CGRect)rect{
//    
//    [self.messageImageView setFrame:rect];
//    [self.messageImageView setImage:image];
//}

-(void)setStyle:(BoxLayerStyle)style{
    if (_style != style) {
        _style = style;
        
        [self setNeedsDisplay];
    }
}

- (void)drawtext:(NSString *)text rect:(CGRect)rect{
    
    [self.messageTextView setFrame:rect];
    [self.messageTextView setText:text];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    
    [self drawLayerCornerFrame:self.IDCardBoxRect Context:ctx];

    if (self.style == BoxLayerStyleShadow) {
        [self drawBox:self.IDCardBoxRect Context:ctx];
        self.messageTextView.text = @"";
    }else{
        NSString *messageText = @"请将身份证置于框内";
        
        CGRect textRect = CGRectMake(CGRectGetMinX(self.IDCardBoxRect),
                                     CGRectGetMidY(self.IDCardBoxRect)-20,
                                     CGRectGetWidth(self.IDCardBoxRect),
                                     40);
        
        
        [self drawtext:messageText rect:textRect];
    }
}

/**
 *  绘制一块区域，该区域为透明色，其余位置为半透明
 *
 *  @param box 区域
 *  @param ctx contextref
 */
- (void)drawBox:(CGRect)box Context:(CGContextRef)ctx{
    CGColorRef bgColor = CGColorCreateCopyWithAlpha([UIColor blackColor].CGColor, 0.6);
    
    CGContextSetFillColorWithColor(ctx, bgColor);
    CGContextFillRect(ctx, self.bounds);
    CGContextClearRect(ctx, box);
    
    CGColorRelease(bgColor);
}

/**
 *  在一个长方形内画四个边角
 *
 *  @param ctx  CGContextRef
 *  @param rect 长方形区域
 */
- (void)drawLayerCornerFrame:(CGRect)rect Context:(CGContextRef )ctx{
    CGContextSetStrokeColorWithColor(ctx, MGColorWithRGB(51, 207, 255, 1).CGColor);
    CGContextSetLineWidth(ctx, 2.5f);
    
    CGFloat cHeight = rect.size.height * 0.2;
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect)+cHeight);
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+cHeight, CGRectGetMinY(rect));
    
    CGContextMoveToPoint(ctx, CGRectGetMaxX(rect)-cHeight, CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect)+cHeight);
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect)-cHeight);
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+cHeight, CGRectGetMaxY(rect));
    
    CGContextMoveToPoint(ctx, CGRectGetMaxX(rect)-cHeight, CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-cHeight);
    
    CGContextDrawPath(ctx, kCGPathStroke);
}
@end
