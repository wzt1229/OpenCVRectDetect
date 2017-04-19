//
//  TJRectDectectView.m
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/20.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import "TJRectDectectView.h"
#import "TJPointCircleView.h"
#import "UIImage+fixOrientation.h"

#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>     //OpenCV3.2.0
//#import <opencv2/imgcodecs/ios.h> //OpenCV3.0.0
//#import <opencv2/core/mat.hpp>
//#import <opencv2/imgproc/types_c.h>
//#import <opencv2/highgui/ios.h>
//#include <stdlib.h>
//#import <QuartzCore/QuartzCore.h>

#define View_Width self.frame.size.width
#define View_Height self.frame.size.height


using namespace cv;
using namespace std;

@interface TJRectDectectView ()<TJPointCircleViewDelegate>
{
    vector<Point2f> cornerPoint;
    
    
    
    //边缘检测设置参数
    UIImage *originImage;
    cv::Mat img;
    double scale;
}
@property (nonatomic, strong) UIImageView *imageView;
//第一次边缘检测得到的四个边角点
@property (nonatomic, strong) NSMutableArray *originalCornerPoints;
//四个点视图
@property (nonatomic, strong) TJPointCircleView *pointView;


@end

@implementation TJRectDectectView

#pragma mark 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        //图片
        self.imageView = [[UIImageView alloc]init];
        self.imageView.backgroundColor = [UIColor redColor];
        self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        [self addSubview:self.imageView];
        
        //画点视图
        self.pointView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        
    }
    return self;
}
#pragma mark set get
-(void)setOriginalImage:(UIImage *)originalImage
{
    _originalImage = originalImage;
    _imageView.image = _originalImage;
    [self resetSubviewsFrameWithImage:_originalImage];
    
    //边缘检测-放到子线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //边缘检测
        if(_originalImage)
        {
            //开始四边形边缘检测
            [self beginRectDetectWithOriginalImage:_originalImage];
        }
    });
    
}
-(TJPointCircleView*)pointView
{
    if (!_pointView) {
        _pointView = [TJPointCircleView new];
        _pointView.frame = self.imageView.frame;
        _pointView.delegate = self;
        [self addSubview:_pointView];
    }
    return _pointView;
}
//设置控件frame
-(void)resetSubviewsFrameWithImage:(UIImage*)newImg{
    
    CGFloat view_W = self.frame.size.width;
    CGFloat view_H = self.frame.size.height;
    CGFloat scaleImg = newImg.size.width/newImg.size.height;
    CGFloat img_W = view_W;
    CGFloat img_H = view_W/scaleImg;
    if (img_H>view_H) {
        
        img_H = view_H;
        img_W = view_H*scaleImg;
    }
    
    self.imageView.frame = CGRectMake((view_W-img_W)/2, (view_H-img_H)/2, img_W, img_H);
    self.pointView.frame = CGRectMake((view_W-img_W)/2, (view_H-img_H)/2, img_W, img_H);
}

#pragma mark OpenCV 四边形检测
//canny边缘检测
void getCanny(Mat gray, Mat &canny) {
    Mat thres;
    double high_thres = threshold(gray, thres, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU), low_thres = high_thres * 0.5;
    Canny(gray, canny, low_thres, high_thres);
}

struct Line {
    cv::Point _p1;
    cv::Point _p2;
    cv::Point _center;
    
    //Line的构造函数
    Line(cv::Point p1, cv::Point p2) {
        _p1 = p1;
        _p2 = p2;
        _center = cv::Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
    }
};

bool cmp_y(const Line &p1, const Line &p2) {
    return p1._center.y < p2._center.y;
}

bool cmp_x(const Line &p1, const Line &p2) {
    return p1._center.x < p2._center.x;
}

//计算交叉点
Point2f computeIntersect(Line l1, Line l2) {
    int x1 = l1._p1.x, x2 = l1._p2.x, y1 = l1._p1.y, y2 = l1._p2.y;
    int x3 = l2._p1.x, x4 = l2._p2.x, y3 = l2._p1.y, y4 = l2._p2.y;
    if (float d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)) {
        Point2f pt;
        pt.x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / d;
        pt.y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / d;
        return pt;
    }
    return Point2f(-1, -1);
}

//开始四边形检测
-(void)beginRectDetectWithOriginalImage:(UIImage*)oriImg
{
    if (!oriImg) {
        return;
    }
    
    //第二种检测四边形边缘的OpenCV算法
    [self detectRectEdge_SecondMethodWithImage:oriImg];
}
-(CGFloat)setMaxMinValue:(CGFloat)value max:(CGFloat)maxValue
{
    CGFloat newValue = value>maxValue?maxValue:value;
    newValue = newValue<0?0:newValue;
    return newValue;
}

#pragma mark 对外接口
//恢复至第一次边缘检测得到的四个边角点
-(void)resetFirstRectDetectPoints
{
    //赋值给绘图视图
    self.pointView.pointsArray = _originalCornerPoints;
}
//边角点扩大至图片视图大小
-(void)resetBiggestRectDetectPoints
{
    CGFloat imgW = _imageView.bounds.size.width;
    CGFloat imgH = _imageView.bounds.size.height;
    self.pointView.pointsArray = [NSMutableArray arrayWithArray:
                                  @[
                                    @[[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0]],
                                    @[[NSNumber numberWithFloat:imgW],[NSNumber numberWithFloat:0]],
                                    @[[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:imgH]],
                                    @[[NSNumber numberWithFloat:imgW],[NSNumber numberWithFloat:imgH]]
                                    ]];
}
//开始裁剪 - 并透射成矩形
-(void)cutRectImageMat
{
    if (_pointView.isInQuadrilateral) {
        
        [self showToastTips];
        
    }else{
        //开始裁剪-放到子线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self beginToCutImageInTheRectAction];
        });
    }
}



-(void)beginToCutImageInTheRectAction
{
    //2.手势调整后的坐标点
    vector<Point2f> img_pts;
    CGFloat scaleX = _imageView.bounds.size.width/_originalImage.size.width;
    CGFloat scaleY = _imageView.bounds.size.height/_originalImage.size.height;
    
    Point2f pfA, pfB, pfC, pfD;
    //要让y轴最小的点做A点，不然会镜像翻转
    NSArray *cornersPoints = _pointView.cornerPoints;//_pointView.pointsArray;//
    NSLog(@"\nA:%@\nB:%@\nC:%@\nD:%@",cornersPoints[0],cornersPoints[1],cornersPoints[2],cornersPoints[3]);
    
    NSArray *temp = cornersPoints[1];
    pfA = Point2f([temp[0] floatValue]/(scale*scaleX), [temp[1] floatValue]/(scale*scaleY));
    temp = cornersPoints[0];
    pfB = Point2f([temp[0] floatValue]/(scale*scaleX), [temp[1] floatValue]/(scale*scaleY));
    temp = cornersPoints[3];
    pfC = Point2f([temp[0] floatValue]/(scale*scaleX), [temp[1] floatValue]/(scale*scaleY));
    temp = cornersPoints[2];
    pfD = Point2f([temp[0] floatValue]/(scale*scaleX), [temp[1] floatValue]/(scale*scaleY));
    
    img_pts.push_back(pfB);
    img_pts.push_back(pfA);
    img_pts.push_back(pfD);
    img_pts.push_back(pfC);
    
    
    // 尺寸变换
    for (size_t i = 0; i < img_pts.size(); i++) {
        img_pts[i].x *= scale;
        img_pts[i].y *= scale;
    }
    
    //1.初始化投射变换前后的交点向量
    int w = _originalImage.size.width, h = _originalImage.size.height;
    CGFloat lineAB = sqrt(pow((pfA.x-pfB.x),2)+pow((pfA.y-pfB.y),2));
    CGFloat lineAD = sqrt(pow((pfA.x-pfD.x),2)+pow((pfA.y-pfD.y),2));
    //长宽比例
    //int w_a4 = 1654, h_a4 = 2339;
    CGFloat w_a4=0, h_a4=0;
    w_a4 = w;
    h_a4 = w*lineAD/lineAB;
    if (h_a4>h){
        h_a4 = h;
        w_a4 = h*lineAB/lineAD;
    }
    
    // corners of destination image with the sequence [tlA, trB, blC, brD]
    vector<Point2f> dst_pts;
    dst_pts.push_back(cv::Point(0, 0));              //A
    dst_pts.push_back(cv::Point(w_a4 - 1, 0));       //B
    dst_pts.push_back(cv::Point(w_a4 - 1, h_a4 - 1));//C
    dst_pts.push_back(cv::Point(0, h_a4 - 1));       //D
    
    // 3.计算转化矩阵
    Mat transmtx = getPerspectiveTransform(img_pts, dst_pts);
    // 4.调用转化矩阵进行拉伸
    Mat dst = Mat::zeros(h_a4, w_a4, CV_8UC3);
    warpPerspective(img, dst, transmtx, dst.size());
    
    //清空之前的绘制
    [_pointView clearBeforeCircleAndLines];
    //清空页面缓存
    [_originalCornerPoints removeAllObjects];
    
    //输出图片
    UIImage *resultImg = MatToUIImage(dst); //>OpenCV3.0.0
    //IplImage iplResImg = dst.operator _IplImage();//OpenCV2.4.9
    //UIImage *resultImg = [self convertToUIImage:&iplResImg];
    
    //返回主线程 - 传回裁剪后的图像
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic =@{@"image":resultImg, @"name":@"PerspectiveTransform"};
        [self performSelector:@selector(doDelegateActionWithInfoDic:) withObject:dic afterDelay:0.001];
    });
}

#pragma mark TJPointCircleViewDelegate
-(void)changeDetectRect
{
    if ([self.delegate respondsToSelector:@selector(changeDetectRect)]) {
        [self.delegate changeDetectRect];
    }
}

#pragma mark 自定义方法
//代理传回图片
-(void)doDelegateActionWithInfoDic:(NSDictionary*)dic
{
    UIImage *resultImg = [dic objectForKey:@"image"];
    NSString *name = [dic objectForKey:@"name"];
    
    if ([name isEqualToString:@"PerspectiveTransform"]) {
        
        if ([self.delegate respondsToSelector:@selector(opencvTransformImage:transformName:)])
        {
            NSLog(@"名称:%@", name);
            //resultImg = [resultImg fixRotateImage];
            [self.delegate opencvTransformImage:resultImg transformName:name];
        }
    }else
    {
        //显示图片
        self.imageView.image = resultImg;
        [self resetSubviewsFrameWithImage:resultImg];
        
    }
}

//第二种检测四边形边缘的OpenCV算法
-(void)detectRectEdge_SecondMethodWithImage:(UIImage*)oriImg
{
    UIImageToMat(oriImg, img);
    Mat img_proc;
    int w = img.size().width, h = img.size().height, min_w = 200;
    scale = min(10.0, w * 1.0 / min_w);
    int w_proc = w * 1.0 / scale, h_proc = h * 1.0 / scale;
    resize(img, img_proc, cv::Size(w_proc, h_proc));

    //
    vector<vector<cv::Point> > squares;
    // blur will enhance edge detection
    Mat blurred(img_proc);
    //(1)medianBlur 执行中值滤波操作,中值滤波将图像的每个像素用邻域 (以当前像素为中心的正方形区域)像素的 中值 代替
    //medianBlur(img_proc, blurred, 9);
    //(2)change from median blur to gaussian for more accuracy of square detection
    GaussianBlur(img_proc, blurred, cvSize(11,11), 0);
    
    Mat gray0(blurred.size(), CV_8U), gray;
    vector<vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 1; c++) { // 3-->1 wzt20170405
        int ch[] = {c, 0};
        //mixChannels主要就是把输入的矩阵（或矩阵数组）的某些通道拆分复制给对应的输出矩阵（或矩阵数组）的某些通道中，
        //其中的对应关系就由fromTo参数制定.
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++) {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0) {
                Canny(gray0, gray, 10, 20, 3); //
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, Mat(), cv::Point(-1, -1));
            } else {
                gray = gray0 >= (l + 1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++) {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(Mat(contours[i]), approx, arcLength(Mat(contours[i]), true) * 0.02,
                             true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(Mat(approx))) > 1000 &&
                    isContourConvex(Mat(approx))) {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++) {
                        double cosine = fabs(angle(approx[j % 4], approx[j - 2], approx[j - 1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.7)//0.3-->0.7 wzt20170401
                        squares.push_back(approx);
                }
            }
        }
        
        double largest_area = -1;
        int largest_contour_index = 0;
        for (int i = 0; i < squares.size(); i++) {
            double a = contourArea(squares[i], false);
            if (a > largest_area) {
                largest_area = a;
                largest_contour_index = i;
            }
        }
        
        vector<cv::Point> points;
        if (squares.size() > 0) {
            points = squares[largest_contour_index];
        } else {
            points.push_back(cv::Point(0, 0));
            points.push_back(cv::Point(w_proc, 0));
            points.push_back(cv::Point(0, h_proc));
            points.push_back(cv::Point(w_proc, h_proc));
        }
        
        // 边缘检测计算得到的四边形边缘 交点
        cv::Point tlA, trB, blC, brD;
        //尺寸比例
        CGFloat img_W = _imageView.bounds.size.width;
        CGFloat img_H = _imageView.bounds.size.height;
        CGFloat scaleX = img_W/oriImg.size.width;
        CGFloat scaleY = img_H/oriImg.size.height;
        CGFloat scale_x = scaleX*scale;
        CGFloat scale_y = scaleY*scale;
        CGFloat ax = points[0].x*scale_x; //* scale
        CGFloat ay = points[0].y*scale_y;
        CGFloat bx = points[1].x*scale_x;
        CGFloat by = points[1].y*scale_y;
        CGFloat cx = points[2].x*scale_x;//
        CGFloat cy = points[2].y*scale_y;
        CGFloat dx = points[3].x*scale_x;
        CGFloat dy = points[3].y*scale_y;
        NSLog(@"\nA(x:%d,y:%d)\nB(x:%d,y:%d)\nC(x:%d,y:%d)\nD(x:%d,y:%d)",points[0].x,points[0].y,points[1].x,points[1].y,points[2].x,points[2].y,points[3].x,points[3].y);
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:
                                @[
                                  
                                  @[[NSNumber numberWithFloat:bx],[NSNumber numberWithFloat:by]],
                                  @[[NSNumber numberWithFloat:ax],[NSNumber numberWithFloat:ay]],
                                  @[[NSNumber numberWithFloat:dx],[NSNumber numberWithFloat:dy]],
                                  @[[NSNumber numberWithFloat:cx],[NSNumber numberWithFloat:cy]],
                                  
                                  ]];
        
        if (c==0)
        {
            //回到主线程 - 画出四个边角点
            dispatch_async(dispatch_get_main_queue(), ^{
                //第一次边缘检测的四个边角点
                _originalCornerPoints = temp;
                //赋值给绘图视图
                self.pointView.pointsArray = temp;
            });
        }
        
    }
    
    
}
double angle(cv::Point pt1, cv::Point pt2, cv::Point pt0) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1 * dx2 + dy1 * dy2) /
    sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}








-(void)showToastTips{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, (View_Height-50)/2, View_Width-40, 50)];
    label.text = @"温馨提示\n请选择有效裁剪区域";
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:label];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    [self addSubview:label];
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}








@end
