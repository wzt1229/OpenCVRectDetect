//
//  TJLineModel.h
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/23.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define WuQiongDa 1.0/0.0

@interface TJLineModel : NSObject

//线段标示直线，线段中点
@property (nonatomic, assign) CGPoint centerPoint;


//直线斜率
@property (nonatomic, assign) CGFloat lineSlope;
//直线-斜截式，y=kx+b
@property (nonatomic, assign) CGFloat lineValueB;

//类方法
+(instancetype)newLineModelWithPoint1:(CGPoint)p1 point2:(CGPoint)p2;
//计算交叉点
-(CGPoint)computeIntersectLine1:(TJLineModel*)l1 line2:(TJLineModel*)l2;

@end
