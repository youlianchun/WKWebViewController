//
//  UIApplication+UIOrientation.h
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//  视频播放旋转处理，解决横屏模式下播放视频不能横屏的问题

#import <UIKit/UIKit.h>

static BOOL kOrientationEnabled = NO;
static NSString *kPlayerViewControllerClassName = @"WKWebViewController";

@interface UIApplication(UIOrientation)

@end

