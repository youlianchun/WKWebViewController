//
//  ToolSectionItem.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToolItem.h"
@interface ToolSectionItem : NSObject
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSArray<ToolItem*> *items;

+(NSArray<ToolSectionItem*>*)filtraterWith:(NSArray<ToolSectionItem*>*)sectionItems;

@end
