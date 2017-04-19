//
//  TJLineModel.m
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/23.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import "TJLineModel.h"



@interface TJLineModel ()
{
    CGPoint _point1;
    CGPoint _point2;
    CGPoint _centerPoint;
}
//已知直线上两点
@property (nonatomic, assign) CGPoint point1;
@property (nonatomic, assign) CGPoint point2;




@end

@implementation TJLineModel

+(instancetype)newLineModelWithPoint1:(CGPoint)p1 point2:(CGPoint)p2
{
    TJLineModel *newLM = [TJLineModel new];
    newLM.point1 = p1;
    newLM.point2 = p2;
    
    if (newLM.point1.x == newLM.point2.x) {
        newLM.lineValueB = 0;
    }else if (newLM.point1.y == newLM.point2.y)
    {
        newLM.lineValueB = WuQiongDa;
    }else
    {
        newLM.lineValueB = (newLM.point1.y-newLM.point1.x*(newLM.point1.y-newLM.point2.y)/(newLM.point1.x-newLM.point2.x));
    }
    
    return newLM;
}

//已知直线上两点
-(void)setPoint1:(CGPoint)point1
{
    _point1 = point1;
}
-(void)setPoint2:(CGPoint)point2
{
    _point2 = point2;
}

//两点之间中点
-(CGPoint)centerPoint
{
    _centerPoint = CGPointMake((self.point1.x+self.point2.x)/2, (self.point1.y+self.point2.y)/2);
    return _centerPoint;
}
/* 
   直线平移，斜率不变：y=kb+b
   中点:(Cx0,Cy0)-->(Cx=Cx0+dx, Cy=Cy0+dy)
   db=dy-dx*(ay-by)/(ax-bx)
 */
-(void)setCenterPoint:(CGPoint)centerPoint
{
    //原来的两点之间的中点
    CGPoint originCenter = self.centerPoint;
    //新的中点
    _centerPoint = centerPoint;
    
    
    //更新直线的参数
    /*
     分为几种情况:
     1.l1为垂直于x轴的直线
     2.l1为垂直于y轴的直线
     3.l1直线斜率均存在且不为0
     */
    //1.为垂直于x轴的直线
    if (_point1.x == _point2.x) {
        _point1 = CGPointMake(_centerPoint.x, _point1.y);
        _point2 = CGPointMake(_centerPoint.x, _point2.y);
    }
    //2.为垂直于y轴的直线
    if (_point1.y == _point2.y) {
        _point1 = CGPointMake(_point1.x, _centerPoint.y);
        _point2 = CGPointMake(_point2.x, _centerPoint.y);
    }
    //3.直线斜率均存在且不为0
    if (_point1.x!=_point2.x && _point1.y!=_point2.y) {
        //位移
        CGFloat dx = centerPoint.x-originCenter.x;
        CGFloat dy = centerPoint.y-originCenter.y;
        
        CGFloat dValueB = dy+dx*(self.point2.y-self.point1.y)/(self.point1.x-self.point2.x);
        self.lineValueB += dValueB;
    }
}

//斜率
-(CGFloat)lineSlope
{
    _lineSlope = (self.point1.y-self.point2.y)/(self.point1.x-self.point2.x);
    if (_lineSlope==0) {
        _lineSlope = 0.001;
    }
    if (_lineSlope==WuQiongDa) {
        _lineSlope = tan(M_PI/2-0.0001);
    }
    return _lineSlope;
}
//斜截式b--y=kx+b
-(CGFloat)lineValueB
{
    return _lineValueB;
}


//计算交叉点 已知：直线斜截式公式，求两直线交点
-(CGPoint)computeIntersectLine1:(TJLineModel*)l1 line2:(TJLineModel*)l2 {
    
    /*
       分为几种情况:
       1.(1)l1为垂直于x轴的直线
         (2)l1为垂直于y轴的直线
       2.(1)l2为垂直于x轴的直线
         (2)l3为垂直于y轴的直线
       3. l1、l2直线斜率均存在且不为0
     */
    //1.(1)l1垂直于x轴的直线
    if (l1.point1.x == l1.point2.x) {
        
        //A
        if (l2.point1.x == l2.point2.x) {
            //l2垂直于x轴的直线 - 无交点
            return CGPointMake(-1, -1);
        }
        //B
        if (l2.point1.y == l2.point2.y) {
            //l2垂直于y轴的直线
            return CGPointMake(l1.point1.x, l2.point1.y);
        }
        return CGPointMake(l1.point1.x, l2.lineSlope*l1.point1.x+l2.lineValueB);
    }
    //1.(2)l1垂直于y轴的直线
    if (l1.point1.y == l1.point2.y) {
        
        //A
        if (l2.point1.x == l2.point2.x) {
            //l2垂直于x轴的直线
            return CGPointMake(l2.point1.x, l1.point1.y);
        }
        //B
        if (l2.point1.y == l2.point2.y) {
            //l2垂直于y轴的直线 - 无交点
            return CGPointMake(-1, -1);
        }
        return CGPointMake((l1.point1.y-l2.lineValueB)/l2.lineSlope, l1.point1.y);
    }
    //2.(1)//l2垂直于x轴的直线
    if (l2.point1.x == l2.point2.x) {
        return CGPointMake(l2.point1.x, l1.lineSlope*l2.point1.x+l1.lineValueB);
    }
    //2.(2)//l2垂直于y轴的直线
    if (l2.point1.y == l2.point2.y) {
        return CGPointMake((l2.point1.y-l1.lineValueB)/l1.lineSlope, l2.point1.y);
    }
    
    //3.l1、l2直线斜率均存在且不为0
    CGFloat x = (l1.lineValueB-l2.lineValueB)/(l2.lineSlope-l1.lineSlope);
    CGFloat y = l1.lineValueB+l1.lineSlope*(l1.lineValueB-l2.lineValueB)/(l2.lineSlope-l1.lineSlope);
    return CGPointMake(x, y);
}

@end
