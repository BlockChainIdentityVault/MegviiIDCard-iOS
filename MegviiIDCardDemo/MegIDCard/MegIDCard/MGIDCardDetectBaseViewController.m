//
//  MGIDCardDetectBaseViewController.m
//  MGIDCard
//
//  Created by 张英堂 on 16/8/10.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardDetectBaseViewController.h"


@interface MGIDCardDetectBaseViewController ()
{
    BOOL _aaaaa;
    
}
@property (nonatomic, assign) BOOL detectFinish;

@end

@implementation MGIDCardDetectBaseViewController

-(void)dealloc{
    self.videoManager = nil;
    self.cardCheckManager = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.videoManager.videoDelegate != self) {
        [self.videoManager setVideoDelegate:self];
    }
    
    if (self.detectImageQueue == NULL) {
        self.detectImageQueue = dispatch_queue_create("com.megvii.image.detect", DISPATCH_QUEUE_SERIAL);
    }
    self.detectFinish = NO;
    
    _aaaaa = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.detectFinish = NO;
}


-(void)detectFrame:(MGIDCardInfo *)frameResult{
}

- (void)detectSucess:(MGIDCardInfo *)result{
}

- (void)detectSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    @autoreleasepool {
//        CMSampleBufferRef detectSampleBufferRef = NULL;
//        CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &detectSampleBufferRef);
        
        /* 进入检测人脸专用线程 */
//        dispatch_async(_detectImageQueue, ^{
        
            MGIDCardInfo *cardInfo = [self.cardCheckManager detectWithSampleBuffer:sampleBuffer];
        
        if (_aaaaa == YES) {
            if (cardInfo.clear <= 0.5) {
                _aaaaa = NO;
                
                if ([cardInfo cropIDCardImage]) {
                    UIImageWriteToSavedPhotosAlbum([cardInfo cropIDCardImage], nil, nil, nil);
                }
            }
        }
        
            if (cardInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cardInfo.errorType == MegIDCardFrameErrorNone) {
                        
                        if (self.detectFinish == NO) {
                            self.detectFinish = YES;
                            
                            [self detectSucess:cardInfo];
                        }
                        
                    }else{
                        if (self.detectFinish == NO) {
                            [self detectFrame:cardInfo];
                        }
                    }
                });
            }
//            CFRelease(detectSampleBufferRef);
//        });
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    @synchronized (self) {
        _aaaaa = YES;
    }
}


#pragma mark - videodelegate
-(void)MGCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    [self detectSampleBuffer:sampleBuffer];

}



@end
