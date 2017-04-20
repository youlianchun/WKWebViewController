//
//  WKWebView+EvaluatingJavaScript.m
//  WebViewController
//
//  Created by YLCHUN on 2017/2/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WKWebView+EvaluatingJavaScript.h"
#import "EvaluatingJavaScript.h"

@implementation WKWebView (EvaluatingJavaScript)

-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString {
    __block NSString* result = nil;
    if (javaScriptString.length>0) {
        __block BOOL isExecuted = NO;
        [self evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
            result = obj;
            isExecuted = YES;
        }];
        
        while (isExecuted == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return result;
}
/*
Number	NSNumber
String	NSString
Date	NSDate
Array	NSArray
Dictionary	NSDictionary
null	NSNul
*/
//-(id)jsActionWithName:(NSString*)name params:(id)value {
//    NSString *jsStr = @"";
//    __block id retuenValue = nil;
//    if ([value isKindOfClass:[NSString class]]) {
//        jsStr = [NSString stringWithFormat:@"%@('%@')", name, value];
//    }
//    else if ([value isKindOfClass:[NSNumber class]]) {
//        jsStr = [NSString stringWithFormat:@"%@(%@)", name, value];
//    }
//    else if ([value isKindOfClass:[NSArray class]]) {
//        jsStr = [NSString stringWithFormat:@"%@(%@)", name, [WebProcessPlant convertToJSONData:value]];
//    }
//    else if ([value isKindOfClass:[NSDictionary class]]) {
//        jsStr = [NSString stringWithFormat:@"%@(%@)", name, [WebProcessPlant convertToJSONData:value]];
//    }
//#warning _______??_______
//    else if ([value isKindOfClass:[NSDate class]]) {
//        jsStr = [NSString stringWithFormat:@"%@(%@)", name, value];//类型转换待验证
//    }
//    else if ([value isKindOfClass:[NSNull class]]) {
//        jsStr = [NSString stringWithFormat:@"%@(null)", name];
//    }
//    else if (value == nil) {
//        jsStr = [NSString stringWithFormat:@"%@()", name];
//    }
//    if (jsStr.length>0) {
//        __block BOOL isExecuted = NO;
//        [self evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            retuenValue = result;
//            isExecuted = YES;
//        }];
//        while (isExecuted == NO) {
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        }
//    }
//    return retuenValue;
//}

-(id)evaluateJSFunc:(NSString*)func arguments:(NSArray*)arguments {
    NSString *paramsJSON = [EvaluatingJavaScript argumentsJS:arguments];
    
    NSString *jsString = [NSString stringWithFormat:@"%@('%@')", func, paramsJSON];
    
    __block id retuenValue;
    
    if ([func containsString:@"."]) {
        NSString *jsonString=[self stringByEvaluatingJavaScriptFromString:jsString];
        if (jsonString.length>0) {
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            retuenValue = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        }
    }else{
        __block BOOL isExecuted = NO;
        [self evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            retuenValue = result;
            isExecuted = YES;
        }];
        while (isExecuted == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return retuenValue;
}



@end
