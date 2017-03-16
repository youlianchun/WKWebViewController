//
//  WKWebView+EvaluatingJavaScript.h
//  WebViewController
//
//  Created by YLCHUN on 2017/2/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (EvaluatingJavaScript)
-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString;
//-(id)jsActionWithName:(NSString*)name params:(id)value;
-(id)evaluateJSFunc:(NSString*)func arguments:(NSArray*)arguments;

@end
