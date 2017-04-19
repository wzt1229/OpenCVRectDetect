//
//  TJRectDectectPreviewController.h
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/21.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJRectDectectPreviewController : UIViewController

@property (nonatomic, strong) UIImage *resultImage; //边缘检测裁剪后的图片
//block属性
@property (copy, nonatomic) void (^getImageRectDectectPreviewBlock)(UIImage *rectDectectImg);

@end
