//
//  HMJSeeBigImgViewController.h
//  ClickWebImageAmplification
//
//  Created by MJHee on 16/5/10.
//  Copyright © 2016年 MJHee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMJSeeBigImgViewController : UIViewController

- (void)webViewWithJavaScript:(UIWebView *)aWebView;
- (void)WebView:(UIWebView *)webView LoadWithSeeBigImageRequest:(NSString *)requestString;

@end
