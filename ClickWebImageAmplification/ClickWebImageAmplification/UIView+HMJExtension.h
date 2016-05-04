//
//  UIView+HMJExtension.h
//  hmj-百思不得姐
//
//  Created by qudanjiang on 15/10/20.
//  Copyright © 2015年 HeMengjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HMJExtension)
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

+ (instancetype)viewFromXib;
@end
