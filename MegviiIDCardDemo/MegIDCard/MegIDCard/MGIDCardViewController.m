//
//  VideoViewController.m
//  MegIDCardDev
//
//  Created by 张英堂 on 16/8/29.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardViewController.h"
#import <MGBaseKit/MGBaseKit.h>

@interface MGIDCardViewController ()

@property (nonatomic, assign) NSInteger errorNoCardNum;
@property (nonatomic, strong) NSDictionary *errorDic;

@end

@implementation MGIDCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.cardCheckManager setScreenOrientation:self.screenOrientation];

    if (self.screenOrientation == MGIDCardScreenOrientationPortrait) {
        self.IDCardScale = MGIDCardScaleMake(0.1, 0.3);
    }else{
        self.IDCardScale = MGIDCardDefaultScale();
    }
    [self creatView];
    self.cardCheckManager.IDCardScaleRect = self.IDCardScale;
    
    [self.cardCheckManager creatAndSetROI];
    
    self.errorDic = @{@"0":@"",
                      @"1":@"",
                      @"2":@"请将证件对准引导框",
                      @"3":@"请握稳定手机",
                      @"4":@"请减少证件反光",
                      @"5":@"请减少证件反光",
                      @"6":@"",
                      };
    
    self.errorNoCardNum = 0;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.videoManager startRecording];
    [self setUpCameraLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)creatView{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    switch (self.screenOrientation) {
        case MGIDCardScreenOrientationPortrait:
        {
            [self creatOrientationPortraitView];
        }
            break;
        case MGIDCardScreenOrientationLandscapeLeft:
        {
            [self creatOrientationLeftView];
        }
            break;
        default:
        {
            [self creatOrientationLeftView];
        }
            break;
    }
}

//加载图层预览
- (void)setUpCameraLayer
{
    if (self.previewLayer == nil) {
        self.previewLayer = [self.videoManager videoPreview];
        CALayer * viewLayer = [self.view layer];
        
        if (self.screenOrientation != MGIDCardScreenOrientationPortrait)
            [self.previewLayer setFrame:CGRectMake(0, 0, MG_WIN_HEIGHT, MG_WIN_WIDTH)];
        else
            [self.previewLayer setFrame:CGRectMake(0, 0, MG_WIN_WIDTH, MG_WIN_HEIGHT)];
        
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    }
    
    if (self.screenOrientation != MGIDCardScreenOrientationPortrait)
        self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
}

- (void)creatOrientationPortraitView{
    self.checkErroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, MG_WIN_WIDTH, 40)];
    [self.checkErroLabel setFont:[UIFont systemFontOfSize:20]];
    [self.checkErroLabel setTextAlignment:NSTextAlignmentCenter];
    [self.checkErroLabel setTextColor:[UIColor whiteColor]];
//    self.checkErroLabel.hidden = YES;
    
    self.backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBTN setFrame:CGRectMake(MG_WIN_WIDTH-70, MG_WIN_HEIGHT-60, 50, 50)];
//    [self.backBTN setImage:[UIImage imageNamed:@"cut_cancel_btn"] forState:UIControlStateNormal];
    [self.backBTN setTitle:@"退出" forState:UIControlStateNormal];
//    [self.backBTN.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.backBTN setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.backBTN addTarget:self action:@selector(cancelIDCardDetect) forControlEvents:UIControlEventTouchUpInside];

    self.debugView = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, MG_WIN_WIDTH-80, 80)];
    [self.debugView setFont:[UIFont systemFontOfSize:14]];
    [self.debugView setTextAlignment:NSTextAlignmentLeft];
    [self.debugView setNumberOfLines:0];
    [self.debugView setTextColor:[UIColor whiteColor]];
    [self.debugView setText:@""];
    
    [self.view addSubview:self.debugView];
    [self.view addSubview:self.messageView];
    [self.view addSubview:self.checkErroLabel];
    [self.view addSubview:self.backBTN];
    
    
    self.IDCardBoxRect = CGRectMake(MG_WIN_WIDTH * self.IDCardScale.x,
                                    MG_WIN_HEIGHT * self.IDCardScale.y,
                                    MG_WIN_WIDTH * (1-self.IDCardScale.x*2),
                                    MG_WIN_WIDTH * (1-self.IDCardScale.x*2) / self.IDCardScale.WHScale);
    self.boxLayer.IDCardBoxRect = self.IDCardBoxRect;
    
    self.boxLayer = [[MGIDBoxLayer alloc] initWithFrame:self.view.bounds];
    [self.boxLayer setIDCardBoxRect:self.IDCardBoxRect];
    [self.view addSubview:self.boxLayer];
    [self.view sendSubviewToBack:self.boxLayer];
}

-(void)creatOrientationLeftView{
    self.checkErroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MG_WIN_HEIGHT, 30)];
    [self.checkErroLabel setFont:[UIFont systemFontOfSize:20]];
    [self.checkErroLabel setTextAlignment:NSTextAlignmentCenter];
    [self.checkErroLabel setTextColor:[UIColor whiteColor]];
//    self.checkErroLabel.hidden = YES;
    
    self.backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBTN setFrame:CGRectMake(MG_WIN_HEIGHT-70, MG_WIN_WIDTH-60, 50, 50)];
    [self.backBTN setTitle:@"退出" forState:UIControlStateNormal];
//    [self.backBTN.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.backBTN setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.backBTN addTarget:self action:@selector(cancelIDCardDetect) forControlEvents:UIControlEventTouchUpInside];

    self.debugView = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, MG_WIN_WIDTH-80, 80)];
    [self.debugView setFont:[UIFont systemFontOfSize:14]];
    [self.debugView setTextAlignment:NSTextAlignmentLeft];
    [self.debugView setNumberOfLines:0];
    [self.debugView setTextColor:[UIColor whiteColor]];
    [self.debugView setText:@""];
    
    [self.view addSubview:self.debugView];
    [self.view addSubview:self.messageView];
    [self.view addSubview:self.checkErroLabel];
    [self.view addSubview:self.backBTN];
    
    CATransform3D transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
    self.view.layer.transform = transform;
    
    CGFloat boxHeight = (1.0-self.IDCardScale.y*2)*MG_WIN_WIDTH;
    CGFloat boxWidth = boxHeight * self.IDCardScale.WHScale;
    CGFloat boxY = MG_WIN_WIDTH * self.IDCardScale.y;
    CGFloat boxX = MG_WIN_HEIGHT*self.IDCardScale.x;
    
    self.IDCardBoxRect = CGRectMake(boxX, boxY, boxWidth, boxHeight);
    
    self.boxLayer = [[MGIDBoxLayer alloc] initWithFrame:CGRectMake(0, 0, MG_WIN_HEIGHT, MG_WIN_WIDTH)];
    [self.boxLayer setIDCardBoxRect:self.IDCardBoxRect];
    [self.view addSubview:self.boxLayer];
    [self.view sendSubviewToBack:self.boxLayer];
}

#pragma  mark -
-(void)detectSucess:(MGIDCardInfo *)result{
    [self cancelIDCardDetect];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.finishBlock) {
            self.finishBlock(result);
        }
    });
}

-(void)detectFrame:(MGIDCardInfo *)frameResult{
    @autoreleasepool {
        
        if (self.debug) {
            NSString *debuMessage = [NSString stringWithFormat:@"isIdcard:%.2f\ninBound:%.2f\nclear:%.2f\n检测耗时:%.2f",frameResult.isIdcard, frameResult.inBound, frameResult.clear, frameResult.timeUsed];
            
            self.debugView.text = debuMessage;
            debuMessage = nil;
        }
        
        if (frameResult.errorType == MegIDCardFrameErrorNoCard ||
            frameResult.errorType == MegIDCardFrameErrorOffset) {
            if (self.errorNoCardNum < 8) {
                self.errorNoCardNum ++;
            }else{
                [self.boxLayer setStyle:BoxLayerStyleNoShadow];
            }

        }else{
            self.errorNoCardNum = 0;
            
            [self.boxLayer setStyle:BoxLayerStyleShadow];
            self.checkErroLabel.text = [self.errorDic valueForKey:[NSString stringWithFormat:@"%zi",frameResult.errorType]];
        }
    }
}

-(void)showErrorMessage:(NSString *)errorString{
}

#pragma mark -
//停止身份证检测
- (void)stopIDCardDetect{
    [self.cardCheckManager stopDetect];
    
    [self.videoManager stopRunning];
    [self.checkErroLabel setHidden:YES];
}

- (void)cancelIDCardDetect{
    [self stopIDCardDetect];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
