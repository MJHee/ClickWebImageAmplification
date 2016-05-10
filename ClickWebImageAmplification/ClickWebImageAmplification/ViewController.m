//
//  ViewController.m
//  ClickWebImageAmplification
//
//  Created by MJHee on 16/5/3.
//  Copyright © 2016年 MJHee. All rights reserved.
//

#import "ViewController.h"
#import "HMJSeeBigImgViewController.h"

@interface ViewController ()<UIWebViewDelegate, UIScrollViewDelegate>
/** webView */
@property (strong, nonatomic) UIWebView *webView;
/** 看大图的控制器 */
@property (strong, nonatomic) HMJSeeBigImgViewController *seeBigImgVC;
@end


@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupWebView];
}
- (void)setupWebView
{
	_webView = [[UIWebView alloc] initWithFrame:self.view.frame];
	NSURL *url = [NSURL URLWithString:@"http://api.51zzzs.cn?r=news/detail&id=365"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	_webView.delegate = self;
	[_webView loadRequest:request];
	[self.view addSubview:_webView];
}

- (void) dealloc
{
	self.webView.delegate = nil;
}
#pragma mark -  UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {

	[self.seeBigImgVC webViewWithJavaScript:aWebView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	//将url转换为string
	NSString *requestString = [[request URL] absoluteString];
	NSLog(@"requestString is %@",requestString);

	//hasPrefix 判断创建的字符串内容是否以pic:字符开始
	if ([requestString hasPrefix:@"myweb:imageClick:"]) {

		[self.seeBigImgVC WebView:webView LoadWithSeeBigImageRequest:requestString];
		[self presentViewController:self.seeBigImgVC animated:YES completion:nil];
		return NO;
	}
	return YES;
}
#pragma mark - 懒加载
- (HMJSeeBigImgViewController *)seeBigImgVC
{
	if (_seeBigImgVC == nil) {
		_seeBigImgVC = [[HMJSeeBigImgViewController alloc] init];
	}
	return _seeBigImgVC;
}

@end
