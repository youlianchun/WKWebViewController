//
//  ToolPanelView.h
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolSectionItem.h"
#import "ToolItemView.h"
#import "ToolSectionHeaderView.h"
@class ToolPanelView;

@protocol ToolPanelViewDelegate <NSObject>

@optional
-(void)toolPanelView:(ToolPanelView*)view didiSelectToolItemItem:(ToolItem*)toolItem;
@end

@interface ToolPanelView : UIView
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, copy) NSArray<ToolSectionItem*> *sections;
@property (nonatomic, weak) id <ToolPanelViewDelegate> delegate;
-(instancetype)initWithToolItemViewClass:(Class)itemClass ToolSectionHeaderViewClass:(Class)headerClass ;

@end
