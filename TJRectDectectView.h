//
//  TJRectDectectView.h
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/20.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import <UIKit/UIKit.h>


#define MainScreen_Width  [[UIScreen mainScreen]bounds].size.width
#define MainScreen_Height [[UIScreen mainScreen]bounds].size.height

@protocol TJRectDectectViewDelegate <NSObject>

-(void)changeDetectRect;
-(void)opencvTransformImage:(UIImage*)image transformName:(NSString*)transform;

@end

@interface TJRectDectectView : UIView


@property (nonatomic, strong) UIImage *originalImage;    //原图
@property (nonatomic, weak) id<TJRectDectectViewDelegate>delegate;


//开始裁剪 - 并透射成矩形
-(void)cutRectImageMat;

//恢复至第一次边缘检测得到的四个边角点
-(void)resetFirstRectDetectPoints;
//边角点扩大至图片视图大小
-(void)resetBiggestRectDetectPoints;


@end
