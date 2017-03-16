//
//  ToolSectionItem.m
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolSectionItem.h"

@implementation ToolSectionItem

+(NSArray<ToolSectionItem*>*)filtraterWith:(NSArray<ToolSectionItem*>*)sectionItems {
    NSMutableArray * arr = [NSMutableArray array];
    for (ToolSectionItem *item in sectionItems) {
        if (item.items.count > 0) {
            [arr addObject:item];
        }
    }
    return arr;
}

@end
