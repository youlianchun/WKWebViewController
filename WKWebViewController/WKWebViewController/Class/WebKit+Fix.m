//
//  WKWebView+CrashFix.m
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WebKit+Fix.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@interface WKWebView (CrashFix)
@end

@implementation WKWebView (CrashFix)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self fixEvaluateJavaScriptCrash];
        [self fixProgressWKContentViewCrash];
        [self fixLoadPostRequest];
    });
}

#pragma mark- fixEvaluateJavaScriptCrash
/**
 WKWebView 退出前调用：-[WKWebView evaluateJavaScript: completionHandler:]
 执行JS代码的情况下。WKWebView 退出并被释放后导致completionHandler变成野指针，而此时 javaScript Core 还在执行JS代码，待 javaScript Core 执行完毕后会调用completionHandler()，导致 crash。这个 crash 只发生在 iOS 8 系统上，参考Apple Open Source，在iOS9及以后系统苹果已经修复了这个bug
 */
+(void)fixEvaluateJavaScriptCrash {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
//    if (([[[UIDevice currentDevice] systemVersion] doubleValue] <= 9.0)) {
        Class class = [self class];
        SEL originalSelector = @selector(evaluateJavaScript:completionHandler:);
        SEL swizzledSelector = @selector(fix_evaluateJavaScript:completionHandler:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
//    }
#endif
}
- (void)fix_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    id strongSelf = self;
    [self fix_evaluateJavaScript:javaScriptString completionHandler:^(id object, NSError *error) {
        [strongSelf title];
        if (completionHandler) {
            completionHandler(object, error);
        }
    }];
}


#pragma mark- fixProgressWKContentViewCrash
/**
 处理WKContentView的crash，实现场景长安选中部分页面内容后再在空白区域双击
 -[WKContentView isSecureTextEntry]: unrecognized selector sent to instance 0x...
 */
+ (void)fixProgressWKContentViewCrash {
//    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)) {
        Class class = NSClassFromString(@"WKContentView");
        SEL isSecureTextEntry = NSSelectorFromString(@"isSecureTextEntry");
        SEL secureTextEntry = NSSelectorFromString(@"secureTextEntry");
        BOOL addIsSecureTextEntry = class_addMethod(class, isSecureTextEntry, (IMP)fix_secureTextEntryIMP, "B@:");
        BOOL addSecureTextEntry = class_addMethod(class, secureTextEntry, (IMP)fix_secureTextEntryIMP, "B@:");
        if (!addIsSecureTextEntry || !addSecureTextEntry) {
            NSLog(@"WKContentView-Crash->修复失败");
        }
//    }
}

/**
 实现WKContentView对象secureTextEntry, isSecureTextEntry方法
 @return NO
 */
BOOL fix_secureTextEntryIMP(id sender, SEL cmd) {
    return NO;
}



#pragma mark - scrollView delegate调整滚动速率
/**
 调整滚动速率
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

#pragma mark- fixLoadPostRequest
/**
 [WKWebView loadRequest:] 支持POST请求
 */
+(void) fixLoadPostRequest {
    Class class = [self class];
    SEL originalSelector = @selector(loadRequest:);
    SEL swizzledSelector = @selector(fix_loadRequest:);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

-(WKNavigation *)fix_loadRequest:(NSURLRequest *)request {
    if ([[request.HTTPMethod uppercaseString] isEqualToString:@"POST"]){
        NSString *url = request.URL.absoluteString;
        NSString *params = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if ([params containsString:@"="]) {
            params = [params stringByReplacingOccurrencesOfString:@"=" withString:@"\":\""];
            params = [params stringByReplacingOccurrencesOfString:@"&" withString:@"\",\""];
            params = [NSString stringWithFormat:@"{\"%@\"}", params];
        }else{
            params = @"{}";
        }
        NSString *postJavaScript = [NSString stringWithFormat:@"\
                                    var url = '%@';\
                                    var params = %@;\
                                    var form = document.createElement('form');\
                                    form.setAttribute('method', 'post');\
                                    form.setAttribute('action', url);\
                                    for(var key in params) {\
                                    if(params.hasOwnProperty(key)) {\
                                    var hiddenField = document.createElement('input');\
                                    hiddenField.setAttribute('type', 'hidden');\
                                    hiddenField.setAttribute('name', key);\
                                    hiddenField.setAttribute('value', params[key]);\
                                    form.appendChild(hiddenField);\
                                    }\
                                    }\
                                    document.body.appendChild(form);\
                                    form.submit();", url, params];
        __weak typeof(self) wself = self;
        [self evaluateJavaScript:postJavaScript completionHandler:^(id object, NSError * _Nullable error) {
            if (error && [wself.navigationDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself.navigationDelegate webView:wself didFailProvisionalNavigation:nil withError:error];
                });
            }
        }];
        return nil;
    }else{
        return [self fix_loadRequest:request];
    }
}

#pragma mark-
@end
