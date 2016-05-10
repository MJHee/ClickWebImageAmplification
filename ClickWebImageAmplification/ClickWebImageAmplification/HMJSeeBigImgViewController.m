//
//  HMJSeeBigImgViewController.m
//  ClickWebImageAmplification
//
//  Created by MJHee on 16/5/10.
//  Copyright © 2016年 MJHee. All rights reserved.
//

#import "HMJSeeBigImgViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+HMJExtension.h"

@interface HMJSeeBigImgViewController () <UIScrollViewDelegate>
/** 图片View */
@property (strong, nonatomic) UIImageView *imgView;
/** 滚动背景图 */
@property (strong, nonatomic) UIScrollView *scrollView;

@end
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

@implementation HMJSeeBigImgViewController
- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor redColor];
}


- (void)setupScrollView
{
    //添加scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //代理
    _scrollView.delegate = self;
    //防止scrollView遮盖住其他控件
    //	[self.view insertSubview:self.scrollView atIndex:0];
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:self.imgView];
    
}
- (void)webViewWithJavaScript:(UIWebView *)aWebView
{
    //调整字号
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
    [aWebView stringByEvaluatingJavaScriptFromString:str];
    
    [aWebView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    
    //注入自定义的js方法后别忘了调用 否则不会生效（不调用也一样生效了，，，不明白）
    NSString *resurlt = [aWebView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    //调用js方法
    NSLog(@"---调用js方法--%@  %s  jsMehtods_result = %@",self.class,__func__,resurlt);
}
- (void)WebView:(UIWebView *)webView LoadWithSeeBigImageRequest:(NSString *)requestString
{
    NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
    NSLog(@"image url------%@", imageUrl);
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    
    
    CGFloat imgWidth = [self getImageSizeWithURL:imageUrl].width;
    CGFloat imgHeight = [self getImageSizeWithURL:imageUrl].height;
    if (imgWidth == 0) {
        imgWidth = ScreenW;
    } if (imgHeight == 0) {
        imgHeight = ScreenH;
    }
    CGFloat scale = imgWidth * 1.0 / imgHeight;
    CGFloat imageHeight =  ScreenW * 1.0 / scale;
    self.imgView.width = ScreenW;
    self.imgView.height = imageHeight;
    
    if (self.scrollView) {
        //设置不隐藏，还原放大缩小，显示图片
        self.scrollView.hidden = NO;
        if (self.imgView.height > ScreenH - 20) {
            //图片很长
            self.imgView.y = 20;
            self.scrollView.contentSize = CGSizeMake(0, self.imgView.height);
        }else
        {
            self.imgView.centerY = ScreenH * 0.5;
        }
        
        //缩放
        CGFloat maxScale = imgWidth / self.scrollView.width;
        if (maxScale > 1.0)
        {
            //最大缩放比例
            self.scrollView.maximumZoomScale = maxScale;
        }
    }
    else
        [self showBigImage:imageUrl]; //创建视图并显示图片
    
    [webView stopLoading];
}
#pragma mark 显示大图片
-(void)showBigImage:(NSString *)imageUrl {
    
    [self setupScrollView];
    
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removeBigImage) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(CGRectGetMaxX(self.scrollView.frame) - 26, self.scrollView.y + 30, 26, 27)];
    [self.scrollView addSubview:closeBtn];
    
    //创建显示图像视图
    if (self.imgView.height > ScreenH - 20) {
        //图片很长
        self.imgView.y = 20;
        self.scrollView.contentSize = CGSizeMake(0, self.imgView.height);
    }else
    {
        self.imgView.centerY = ScreenH * 0.5;
    }
    
    //缩放
    CGFloat maxScale = self.imgView.width / self.scrollView.width;
    if (maxScale > 1.0)
    {
        //最大缩放比例
        self.scrollView.maximumZoomScale = maxScale;
    }
    
    //添加捏合手势
    [self.imgView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)]];
    
}
//关闭按钮
-(void)removeBigImage
{
    self.scrollView.hidden = YES;
    [self popoverPresentationController];
}

- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    //缩放:设置缩放比例
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}
#pragma mark - <UIScrollViewDelegate>
//滚动的是哪个view
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}

#pragma mark - 根据图片url获取图片尺寸
- (CGSize)getImageSizeWithURL:(id)imageURL
{
    NSURL* URL = nil;
    if([imageURL isKindOfClass:[NSURL class]]) {
        URL = imageURL;
    }
    if([imageURL isKindOfClass:[NSString class]]) {
        URL = [NSURL URLWithString:imageURL];
    }
    if(URL == nil)
        return CGSizeZero;  // url不正确返回CGSizeZero
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString* pathExtendsion = [URL.pathExtension lowercaseString];
    
    CGSize size = CGSizeZero;
    if([pathExtendsion isEqualToString:@"png"]) {
        size =  [self getPNGImageSizeWithRequest:request];
    }
    else if([pathExtendsion isEqual:@"gif"])
    {
        size =  [self getGIFImageSizeWithRequest:request];
    }
    else{
        size = [self getJPGImageSizeWithRequest:request];
    }
    if(CGSizeEqualToSize(CGSizeZero, size))            // 如果获取文件头信息失败,发送异步请求请求原图
    {
        NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
        UIImage* image = [UIImage imageWithData:data];
        if(image)
        {
            size = image.size;
        }
    }
    return size;
}
//  获取PNG图片的大小
- (CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取gif图片的大小
- (CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取jpg图片的大小
- (CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}
#pragma mark - 懒加载
- (UIImageView *)imgView
{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = CGRectMake(0, 0, ScreenW, 300);
        _imgView.userInteractionEnabled = YES;
    }
    return _imgView;
}

@end
