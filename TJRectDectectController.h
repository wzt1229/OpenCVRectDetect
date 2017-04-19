//
//  TJRectDectectController.h
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/20.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRectDectectView.h"


@interface TJRectDectectController : UIViewController

@property (nonatomic, strong) UIImage *originalImage;
//block属性
@property (copy, nonatomic) void (^getImageRectDectectPreviewBlock)(UIImage *rectDectectImg);

@end
