//
//  ToolViewController.h
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//
//  每行完全显示最大按钮数 4
//  自定义界面需要继承 ToolItemView 和 ToolSectionHeaderView，并重写指定方法
//  重写 -(Class)ToolItemViewClass;返回自定义ToolItemView类
//  重写 -(Class)ToolSectionHeaderViewClass;返回自定义ToolSectionHeaderView类

#import <UIKit/UIKit.h>
#import "ToolSectionItem.h"
#import "ToolItemView.h"
#import "ToolSectionHeaderView.h"

@interface ToolViewController : UIViewController
@property (nonatomic, readonly) UIView* backgroundView;

+(instancetype)showWithAnimated: (BOOL)flag completion:(void (^)(void))completion;

-(void)showWithAnimated: (BOOL)flag completion:(void (^)(void))completion;

-(void)hidenWithAnimated: (BOOL)flag completion:(void (^)(void))completio;

@end

@interface ToolViewController(Realize)

/**
 子类实现，设置自定义按钮类（可选实现）
 
 @return ToolItemView 子类
 */
-(Class)ToolItemViewClass;

/**
 子类实现，设置自定义组标题类（可选实现）
 
 @return ToolSectionHeaderView 子类
 */
-(Class)ToolSectionHeaderViewClass;

/**
 子类实现，设置toolItemSections，不可单独调用（必须实现）
 
 @return 为空时候不会显示
 */
-(NSArray<ToolSectionItem *> *)toolItemSections;

/**
 
 隐藏窗口调用
 
 @param flag 是否点击背景
 */
-(void)hidenByBackgroundTouch:(BOOL)flag;
@end
