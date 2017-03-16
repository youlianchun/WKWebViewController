//
//  WKWebView+CrashFix.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

/*
 //注意，禁用使用一下代码进行NSURLProtocol拦截，操作将导致页面上的form.submit()请求丢失post参数
 Class cls = NSClassFromString(@"WKBrowsingContextController");
 SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
 if ([(id)cls respondsToSelector:sel]) {
 // 注册http(s) scheme, 把 http和https请求交给 NSURLProtocol处理
 [(id)cls performSelector:sel withObject:@"http"];
 [(id)cls performSelector:sel withObject:@"https"];
 }
 */


