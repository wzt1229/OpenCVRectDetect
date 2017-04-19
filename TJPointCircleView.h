//
//  TJPointCircleView.h
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/20.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TJPointCircleViewDelegate <NSObject>

-(void)changeDetectRect;

@end

@interface TJPointCircleView : UIView

@property (nonatomic, strong) NSMutableArray *pointsArray;
@property (nonatomic, strong) NSMutableArray *cornerPoints;
@property (nonatomic, weak) id<TJPointCircleViewDelegate>delegate;

@property (nonatomic, assign) BOOL isInQuadrilateral;     //是否是内四边形
//清空之前的绘制
-(void)clearBeforeCircleAndLines;

@end
