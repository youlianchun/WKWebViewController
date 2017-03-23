//
//  ToolSectionHeaderView.h
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//  自定义标题布局需需要继承ToolSectionHeaderView

#import <UIKit/UIKit.h>

@interface ToolSectionHeaderView : UITableViewHeaderFooterView
@property(nonatomic,assign)UIColor *lineColor;
+(CGFloat)height;//继承后需要重写
+(NSString*)identifier;//继承后需要重写
@end
