//
//  ScriptMessageManager.m
//  WebViewController
//
//  Created by YLCHUN on 2017/2/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ScriptMessageManager.h"
#import "ScriptMessageHandler.h"
#import "WKWebView+EvaluatingJavaScript.h"


@interface ScriptMessageManager ()<WKScriptMessageHandler>
@property (nonatomic, retain) NSMutableDictionary *scriptCallBackDict;
@property (nonatomic, retain) NSMutableArray *scriptNameArray;
@end

@implementation ScriptMessageManager
-(instancetype)init {
    self = [super init];
    if (self) {
        self.recent = YES;
    }
    return self;
}

-(void)dealloc {
    [self _removeAllScriptMessageHandler];
    [_scriptCallBackDict removeAllObjects];
    [_scriptNameArray removeAllObjects];
    _scriptCallBackDict = nil;
    _scriptNameArray = nil;
}

-(NSMutableDictionary *)scriptCallBackDict {
    if (!_scriptCallBackDict) {
        _scriptCallBackDict = [NSMutableDictionary dictionary];
    }
    return _scriptCallBackDict;
}

-(NSMutableArray *)scriptNameArray {
    if (!_scriptNameArray) {
        _scriptNameArray = [NSMutableArray array];
    }
    return _scriptNameArray;
}

#pragma mark - WKScriptMessageHandler

//在这个方法里实现注册的供js调用的oc方法
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
        ScriptMessageHandler *h = [self.scriptCallBackDict objectForKey:message.name];
        switch (h.returnType) {
            case VoidReturn:
            {
                ScriptMessageVoidHandler handler = h.handler;
                if (handler) {
                    handler(message.body);
                }
            } break;
            case SyncReturn:
            {
                ScriptMessageReturnHandler handler = h.handler;
                if (handler) {
                    __weak WKWebView *webView = message.webView;
                    id result = handler(message.body);
                    NSArray*arguments;
                    if (result) {
                        arguments = @[result];
                    }else{
                        arguments = @[];
                    }
                    [webView evaluateJSFunc:h.returnName  arguments:arguments];
                    //            [message.webView jsActionWithName:h.returnName params:result];
                }
            }
                break;
            case AsyncReturn:
            {
                ScriptMessageAsyncReturnHandler handler = h.handler;
                if (handler) {
                    __weak WKWebView *webView = message.webView;
                    ScriptAsyncReturnHandler returnHandler = ^(id result){
                        NSArray*arguments;
                        if (result) {
                            arguments = @[result];
                        }else{
                            arguments = @[];
                        }
                        [webView evaluateJSFunc:h.returnName  arguments:arguments];
                    };
                    handler(message.body, returnHandler);
                    //            [message.webView jsActionWithName:h.returnName params:result];
                }
                
            }
                break;
            default:
                break;
        }
}

#pragma mark -
- (void)_addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name {
    [super addScriptMessageHandler:scriptMessageHandler name:name];
    [self.scriptNameArray addObject:name];
}

- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name {
    if (name.length==0 || scriptMessageHandler == nil) {
        return ;
    }
    if (!self.recent && [self.scriptNameArray containsObject:name]) {
        return ;
    }
    [self removeScriptMessageHandlerForName:name];
    [self _addScriptMessageHandler:scriptMessageHandler name:name];
}

- (void)addScriptMessageHandlerForName:(NSString *)name returnName:(NSString*)returnName handler:(ScriptMessageReturnHandler)handler {
    if (name.length==0 || handler == nil) {
        return ;
    }
    if (!self.recent && [self.scriptNameArray containsObject:name]) {
        return ;
    }
    ScriptMessageHandler *h = [[ScriptMessageHandler alloc] initWithName:name returnName:returnName returnHandler:handler];
    [self addScriptMessageHandlerHandler:h];
}
- (void)addScriptMessageHandlerForName:(NSString *)name asyncReturnName:(NSString*)returnName handler:(ScriptMessageAsyncReturnHandler)handler {
    if (name.length==0 || handler == nil) {
        return ;
    }
    if (!self.recent && [self.scriptNameArray containsObject:name]) {
        return ;
    }
    ScriptMessageHandler *h = [[ScriptMessageHandler alloc] initWithName:name asyncReturnName:returnName returnHandler:handler];
    [self addScriptMessageHandlerHandler:h];
}
- (void)addScriptMessageHandlerForName:(NSString *)name handler:(ScriptMessageVoidHandler)handler {
    if (name.length==0 || handler == nil) {
        return ;
    }
    if (!self.recent && [self.scriptNameArray containsObject:name]) {
        return ;
    }
    ScriptMessageHandler *h = [[ScriptMessageHandler alloc] initWithName:name voidHandler:handler];
    [self addScriptMessageHandlerHandler:h];
}

- (void)addScriptMessageHandlerHandler:(ScriptMessageHandler *)handler {
    [self removeScriptMessageHandlerForName:handler.name];
    [self.scriptCallBackDict setObject:handler forKey:handler.name];
    [self _addScriptMessageHandler:self name:handler.name];
}

- (void)removeScriptMessageHandlerForName:(NSString *)name {
    [super removeScriptMessageHandlerForName:name];
    [self.scriptCallBackDict removeObjectForKey:name];
    [self.scriptNameArray removeObject:name];
}

-(void)_removeAllScriptMessageHandler {
    NSArray *names = [self.scriptNameArray mutableCopy];
    for (NSString* name in names) {
        [self removeScriptMessageHandlerForName:name];
    }
}

-(void)removeAllScriptMessageHandler {
    [self _removeAllScriptMessageHandler];
}

-(void)addCookieWithDict:(NSDictionary*)dict {
    // 将所有cookie以document.cookie = 'key=value';形式进行拼接 无法跨域设置 cookie
    NSMutableString *cookieString = [[NSMutableString alloc] init];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString*cookie = [NSString stringWithFormat:@"document.cookie = '%@=%@'; ", key, obj];
        [cookieString appendString:cookie];
    }];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: cookieString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self addUserScript:cookieScript];
}

-(void)addAdjustScreenSizeAndZooming:(BOOL)zooming {
    // 自适应屏幕宽度js
    NSString *adjustString;
    if (zooming) {
        adjustString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    }else{
        adjustString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'); document.getElementsByTagName('head')[0].appendChild(meta);";
    }
    WKUserScript *adjustScript = [[WKUserScript alloc] initWithSource:adjustString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [self addUserScript:adjustScript];
}

-(void)addJSFunctionWithName:(NSString*)name {
    NSString *javaScriptSource = [NSString stringWithFormat:@"function js_%@Func(param){\
                                  window.webkit.messageHandlers.%@.postMessage(param)\
                                  }", name, name];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];// forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
    [self addUserScript:userScript];
}

//-(void)addDisableCreateWebView {
//    NSString *disableString = @"function js_disableCreateWebViewFunc(){\
//        var a = document.getElementsByTagName('a');\
//        for(var i=0;i<a.length;i++){\
//            var target = a[i].getAttribute('target')\
//            if (target == 'view_window' || target == '_blank') {\
//                a[i].setAttribute('target','');\
//            }\
//        }\
//    }";
//    WKUserScript *disableScript = [[WKUserScript alloc] initWithSource:disableString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//    [self addUserScript:disableScript];
//
//}


@end

