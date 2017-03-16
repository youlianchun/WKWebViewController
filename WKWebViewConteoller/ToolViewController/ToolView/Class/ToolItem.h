//
//  ToolItem.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToolItem : NSObject
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, readonly) void(^action)();

+(ToolItem*)itemWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)())action;

@end
