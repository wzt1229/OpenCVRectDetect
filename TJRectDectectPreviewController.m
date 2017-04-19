//
//  TJRectDectectPreviewController.m
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/21.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import "TJRectDectectPreviewController.h"

#define view_W (self.view.frame.size.width-20)
#define view_H (self.view.frame.size.height-(64+50+20))

@interface TJRectDectectPreviewController ()

@property (nonatomic, strong) UIImageView *imageView;
//保存
- (IBAction)saveCutImgBtnAction:(UIButton *)sender;
//顺时针旋转图片按钮事件
- (IBAction)clockWiseRotationImgBtnAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *counterClockwiseBtn;
- (IBAction)counterClockwiseBtn:(UIButton *)sender;

@end

@implementation TJRectDectectPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    //图片
    self.imageView = [[UIImageView alloc]init];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.frame = CGRectMake(10, 64+10, self.view.frame.size.width-20, self.view.frame.size.width-64-50-20);
    [self.view addSubview:self.imageView];
    
    //水平方向反转
    UIImage *btnImg = [UIImage imageNamed:@"rotation_icon.png"];
    btnImg = [self fixOrientation:btnImg rotation:UIImageOrientationUp];
    [_counterClockwiseBtn setImage:btnImg forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self resetSubviewsFrameWithImage:_resultImage];
    _imageView.image = _resultImage;
}

-(void)setResultImage:(UIImage *)resultImage
{
    _resultImage = resultImage;
}

- (IBAction)saveCutImgBtnAction:(UIButton *)sender {
    //保存图片
    //NSLog(@"保存图片");
    if (self.getImageRectDectectPreviewBlock) {
        UIImage *imgTemp = _imageView.image;
        self.getImageRectDectectPreviewBlock(imgTemp);
    }
    
    //返回上层控制器
    UIViewController *vc = nil;
    if (self.parentViewController.parentViewController) {
        vc = self.parentViewController.parentViewController;
    }else if (self.parentViewController){
        vc = self.parentViewController;
    }
    [self.navigationController popToViewController:vc animated:YES];
}

//旋转图片
- (IBAction)clockWiseRotationImgBtnAction:(UIButton *)sender {

    UIImage *imgTemp = _imageView.image;
    if (sender.tag == 1001) {
        imgTemp = [self image:imgTemp rotation:UIImageOrientationRight];
    }else{
        imgTemp = [self image:imgTemp rotation:UIImageOrientationLeft];
    }
    
    _imageView.image = imgTemp;
    [self resetSubviewsFrameWithImage:imgTemp];
}

-(void)resetSubviewsFrameWithImage:(UIImage*)newImg{
    
    CGFloat scaleImg = newImg.size.width/newImg.size.height;
    CGFloat img_W = view_W;
    CGFloat img_H = view_W/scaleImg;
    if (img_H>view_H) {
        
        img_H = view_H;
        img_W = view_H*scaleImg;
    }
    
    self.imageView.frame = CGRectMake(10+(view_W-img_W)/2, 74+(view_H-img_H)/2, img_W, img_H);
}
//旋转图片
- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
        rotate = M_PI_2;
        rect = CGRectMake(0, 0, image.size.height, image.size.width);
        translateX = 0;
        translateY = -rect.size.width;
        scaleY = rect.size.width/rect.size.height;
        scaleX = rect.size.height/rect.size.width;
        break;
        case UIImageOrientationRight:
        rotate = 3 * M_PI_2;
        rect = CGRectMake(0, 0, image.size.height, image.size.width);
        translateX = -rect.size.height;
        translateY = 0;
        scaleY = rect.size.width/rect.size.height;
        scaleX = rect.size.height/rect.size.width;
        break;
        case UIImageOrientationDown:
        rotate = M_PI;
        rect = CGRectMake(0, 0, image.size.width, image.size.height);
        translateX = -rect.size.width;
        translateY = -rect.size.height;
        break;
        default:
        rotate = 0.0;
        rect = CGRectMake(0, 0, image.size.width, image.size.height);
        translateX = 0;
        translateY = 0;
        break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

- (UIImage *)fixOrientation:(UIImage *)aImage rotation:(UIImageOrientation)orientation{
    
    UIImage *image = nil;
    switch (orientation) {
        case UIImageOrientationUp:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationUpMirrored];
            break;
        }
        case UIImageOrientationDown:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationDownMirrored];
            break;
        }
        case UIImageOrientationLeft:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationRightMirrored];
            break;
        }
        case UIImageOrientationRight:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationLeftMirrored];
            break;
        }
        case UIImageOrientationUpMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationUp];
            break;
        }
        case UIImageOrientationDownMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationDown];
            break;
        }
        case UIImageOrientationLeftMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationRight];
            break;
        }
        case UIImageOrientationRightMirrored:
        {
            image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationLeft];
            break;
        }
        default:
        break;
    }
    
    return image;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)counterClockwiseBtn:(UIButton *)sender {
}
@end
