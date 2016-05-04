//
//  ViewController.m
//  ClickWebImageAmplification
//
//  Created by MJHee on 16/5/3.
//  Copyright © 2016年 MJHee. All rights reserved.
//

#import "BorderViewController.h"
#import "UIImageView+WebCache.h"

@interface BorderViewController ()<UIWebViewDelegate>
/** webView */
@property (strong, nonatomic) UIWebView *webView;
/** 图片View */
@property (strong, nonatomic) UIImageView *imgView;
/** 背景图片 */
@property (strong, nonatomic) UIView *bgView;
@end

@implementation BorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setWebView];
}
- (void)setWebView
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURL *url = [NSURL URLWithString:@"http://api.51zzzs.cn?r=news/detail&id=365"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _webView.delegate = self;
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
}
#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    
    //调整字号
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
    [aWebView stringByEvaluatingJavaScriptFromString:str];
    
    //js方法遍历图片添加点击事件 返回图片个数
    static NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    for(var i=0;i<objs.length;i++){\
    objs[i].onclick=function(){\
    document.location=\"myweb:imageClick:\"+this.src;\
    };\
    };\
    return objs.length;\
    };";
    
    [aWebView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    
    //注入自定义的js方法后别忘了调用 否则不会生效（不调用也一样生效了，，，不明白）
    NSString *resurlt = [aWebView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    //调用js方法
    NSLog(@"---调用js方法--%@  %s  jsMehtods_result = %@",self.class,__func__,resurlt);
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"requestString is %@",requestString);
    
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        NSLog(@"image url------%@", imageUrl);
        
        if (self.bgView) {
            //设置不隐藏，还原放大缩小，显示图片
            self.bgView.hidden = NO;
            self.imgView.frame = CGRectMake(10, 10, ScreenW-40, 220);
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"1.jpg"]];
        }
        else
            [self showBigImage:imageUrl]; //创建视图并显示图片
        
        return NO;
    }
    return YES;
}
#pragma mark 显示大图片
-(void)showBigImage:(NSString *)imageUrl {
    //创建灰色透明背景，使其背后内容不可操作
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW,ScreenH)];
    [self.bgView setBackgroundColor:[UIColor colorWithRed:0.3
                                                    green:0.3
                                                     blue:0.3
                                                    alpha:0.7]];
    [self.view addSubview:self.bgView];
    
    //创建边框视图
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW-20, 240)];
    //将图层的边框设置为圆脚
    borderView.layer.cornerRadius = 1;
    borderView.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    borderView.layer.borderWidth = 1;
    borderView.layer.borderColor = [[UIColor colorWithRed:0.9
                                                    green:0.9
                                                     blue:0.9
                                                    alpha:0.7] CGColor];
    [borderView setCenter:self.bgView.center];
    [self.bgView addSubview:borderView];
    
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor redColor];
    [closeBtn addTarget:self action:@selector(removeBigImage) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(borderView.frame.origin.x+borderView.frame.size.width-20, borderView.frame.origin.y-6, 26, 27)];
    [self.bgView addSubview:closeBtn];
    
    //创建显示图像视图
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(borderView.frame)-20, CGRectGetHeight(borderView.frame)-20)];
    imgView.userInteractionEnabled = YES;
    [imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"1"]];
    [borderView addSubview:imgView];
    
    //添加捏合手势
    [imgView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)]];
    
}
//关闭按钮
-(void)removeBigImage
{
    self.bgView.hidden = YES;
}

- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    //缩放:设置缩放比例
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}
@end
