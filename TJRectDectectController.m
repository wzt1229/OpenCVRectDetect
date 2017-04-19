//
//  TJRectDectectController.m
//  OpenCVRectDectectDemo
//
//  Created by TJ-iOS on 2017/3/20.
//  Copyright © 2017年 TJ-iOS. All rights reserved.
//

#import "TJRectDectectController.h"
#import "TJRectDectectPreviewController.h"


@interface TJRectDectectController ()<TJRectDectectViewDelegate>

@property (nonatomic, strong) TJRectDectectView *rectDetectView;

//开始检测 并 裁剪-透射成矩形
- (IBAction)beginRectDectectBtnAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetRectDetectBtn;
- (IBAction)resetRectDetectBtnAction:(UIButton *)sender;


@end

@implementation TJRectDectectController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.view.backgroundColor = [UIColor blackColor];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //边缘检测视图
    self.rectDetectView.frame = CGRectMake(20, 64, self.view.frame.size.width-40, self.view.frame.size.height-64-50);
    self.rectDetectView.originalImage = _originalImage;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //边缘检测视图
    self.rectDetectView.frame = CGRectMake(20, 64, self.view.frame.size.width-40, self.view.frame.size.height-64-50);
}


#pragma mark set get
-(void)setOriginalImage:(UIImage *)originalImage
{
    _originalImage = originalImage;
}
-(TJRectDectectView*)rectDetectView
{
    if (!_rectDetectView) {
        _rectDetectView = [[TJRectDectectView alloc]init];
        _rectDetectView.delegate = self;
        [self.view addSubview:_rectDetectView];
    }
    return _rectDetectView;
}

#pragma mark 按钮事件
- (IBAction)beginRectDectectBtnAction:(UIButton *)sender {
    //开始检测
    [self.rectDetectView cutRectImageMat];
}

- (IBAction)resetRectDetectBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        //放大检测边缘
        [self.rectDetectView resetBiggestRectDetectPoints];
    }else{
        //恢复至算法检测边缘
        [self.rectDetectView resetFirstRectDetectPoints];
    }
    
}



#pragma mark TJRectDectectViewDelegate
-(void)opencvTransformImage:(UIImage *)image transformName:(NSString *)transform
{
    TJRectDectectPreviewController *preview = [TJRectDectectPreviewController new];
    preview.resultImage = image;
    if (self.getImageRectDectectPreviewBlock){
        preview.getImageRectDectectPreviewBlock = self.getImageRectDectectPreviewBlock;
    }
    [self.navigationController pushViewController:preview animated:YES];
}
-(void)changeDetectRect
{
    if (!_resetRectDetectBtn.selected) {
        _resetRectDetectBtn.selected = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
