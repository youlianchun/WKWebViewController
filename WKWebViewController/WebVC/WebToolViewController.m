//
//  WebToolViewController.m
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WebToolViewController.h"

@interface WebToolViewController ()
@property (nonatomic, copy)void (^selectedCallBack)(WebToolType type);
@end

@implementation WebToolViewController

+(WebToolViewController*)showWithSelectedCallBack:(void (^)(WebToolType type))callBack {
    WebToolViewController *vc = [self showWithAnimated:YES completion:nil];
    vc.selectedCallBack = callBack;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(NSArray<ToolSectionItem *> *)toolItemSections{
    ToolItem *WXItem = [ToolItem itemWithTitle:@"微信" image:[UIImage imageNamed:@"weixin"] action:^{
        [self doCallBack:WebToolType_s_WX];
    }];
    ToolItem *PYQItem = [ToolItem itemWithTitle:@"朋友圈" image:[UIImage imageNamed:@"pengyouquan"] action:^{
        [self doCallBack:WebToolType_s_PYQ];
    }];
    ToolItem *QQItem = [ToolItem itemWithTitle:@"QQ" image:[UIImage imageNamed:@"QQ"] action:^{
        [self doCallBack:WebToolType_s_QQ];
    }];
    ToolItem *XLWBItem = [ToolItem itemWithTitle:@"微博" image:[UIImage imageNamed:@"xinlang"] action:^{
        [self doCallBack:WebToolType_s_XLWB];
    }];
    ToolSectionItem * shareSectionItem = [[ToolSectionItem alloc] init];
    shareSectionItem.title = @"分享到";
    shareSectionItem.items = @[WXItem,PYQItem,QQItem,XLWBItem];
    
    ToolItem *refreshItem = [ToolItem itemWithTitle:@"刷新" image:[UIImage imageNamed:@"shuaxin"] action:^{
        [self doCallBack:WebToolType_f_Refresh];
    }];
    ToolItem *copyItem = [ToolItem itemWithTitle:@"复制链接" image:[UIImage imageNamed:@"fuzhilianjie"] action:^{
        [self doCallBack:WebToolType_f_Copy];
    }];
    ToolSectionItem * functionSectionItem = [[ToolSectionItem alloc] init];
    functionSectionItem.title = @" 功能 ";
    functionSectionItem.alignmentCenter = YES;
    functionSectionItem.items = @[refreshItem,copyItem];
    
    NSArray<ToolSectionItem *> *sections = @[shareSectionItem,functionSectionItem];
    return sections;
}

-(void)doCallBack:(WebToolType)type {
    if (self.selectedCallBack) {
        self.selectedCallBack(type);
    }
}

//-(Class)ToolItemViewClass {
//    return [super ToolItemViewClass];
//}
//
//-(Class)ToolSectionHeaderViewClass {
//    return [super ToolSectionHeaderViewClass];
//}
-(void)hidenByBackgroundTouch:(BOOL)flag {
    if (flag) {
        [self doCallBack:WebToolType_cancel];
    }

}
@end


