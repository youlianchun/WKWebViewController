//
//  ToolItem.m
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolItem.h"
@interface ToolItem ()
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic) void(^action)();

-(instancetype)initWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)())action;
@end
@implementation ToolItem
-(instancetype)initWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)())action {
    self = [super init];
    if (self) {
        self.title = title;
        self.image = image;
        self.action = action;
    }
    return self;
}

+(ToolItem*)itemWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)())action {
    return [[self alloc] initWithTitle:title image:image action:action];
}

@end
