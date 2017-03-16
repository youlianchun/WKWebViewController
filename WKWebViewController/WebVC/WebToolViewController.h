//
//  WebToolViewController.h
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolViewController.h"

//WebToolType_s_..分享 WebToolType_f_..功能
typedef NS_ENUM(NSUInteger, WebToolType) {
    /**无操作*/
    WebToolType_cancel,
    /**分享 微信*/
    WebToolType_s_WX,
    /**分享 朋友圈*/
    WebToolType_s_PYQ,
    /**分享 QQ*/
    WebToolType_s_QQ,
    /**分享 新浪微薄*/
    WebToolType_s_XLWB,
    /**功能 刷新*/
    WebToolType_f_Refresh,
    /**功能 复制链接*/
    WebToolType_f_Copy
};

@interface WebToolViewController : ToolViewController

+(instancetype)showWithSelectedCallBack:(void (^)(WebToolType type))callBack;

@end
