//
//  OCModel.m
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "OCModel.h"
#import <objc/runtime.h>

@implementation OCModel


-(void)randomTitle {
    static NSArray* titles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titles = @[@"哈哈",@"呵呵",@"嘿嘿",@"吼吼",@"哑哑",@"嘎嘎",@"咕咕",@"咯咯",@"咔咔",@"咚咚",@"叮叮",@"嘟嘟",@"呜呜",@"呼呼"];
    });
    int i = arc4random() % titles.count;
    self.vc.title = titles[i];
}

-(void)setTitle:(NSArray*)params {
    self.vc.title = params[0];
}

-(void)getAppVersion:(JSExportCallBack)cb {
    cb(@"1.0");
}

-(void)sumAB:(NSArray*)params cb:(JSExportCallBack)cb {
    NSInteger a = [params[0] integerValue];
    NSInteger b = [params[1] integerValue];
    NSInteger sum = a+b;
    cb(@(sum));
}

-(void)subAB:(NSArray*)params cb:(JSExportCallBack)cb {
    NSInteger a = [params[0] integerValue];
    NSInteger b = [params[1] integerValue];
    NSInteger sub = a-b;
    cb(@(sub));
}

@end
