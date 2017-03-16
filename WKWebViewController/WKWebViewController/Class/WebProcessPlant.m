//
//  WebProcessPlant.m
//  WebViewController
//
//  Created by YLCHUN on 2017/3/2.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WebProcessPlant.h"
#import <UIKit/UIKit.h>

@implementation WebProcessPlant
+(NSString* )urlEncoding:(NSString *)url {
    NSString *_url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return _url;
}


+ (void)setCookieWithRequest:(NSMutableURLRequest *)request {
    // 在此处获取返回的cookie
    //document.cookie()无法跨域设置 cookie
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    
    [request addValue:cookieValue forHTTPHeaderField:@"Cookie"];
}

+(NSURL*)urlWithString:(NSString*)url {
    NSString *tmpStr = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tmpStr.length == 0) {
        return nil;
    }
    NSString *str = [tmpStr lowercaseString];
    if ([str hasPrefix:@"/"] ) {
        tmpStr = [NSString stringWithFormat:@"file://%@", tmpStr];
    }else if([str hasPrefix:@"file://"]){
    }else {
        if (![str hasPrefix:@"http"]) {
            tmpStr = [NSString stringWithFormat:@"http://%@", url];
        }
    }
    NSURL *anUrl = [NSURL URLWithString:tmpStr];
    return anUrl;
}


+(void)addUserAgent:(NSString *)userAgent {
    NSString *tmpStr = [userAgent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tmpStr.length == 0) {
        return;
    }
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newAgent = [oldAgent stringByAppendingFormat:@" %@", tmpStr];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

@end
