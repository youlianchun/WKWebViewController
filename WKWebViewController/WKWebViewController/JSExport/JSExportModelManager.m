//
//  JSExportModelManager.m
//  WKWebView_JSExport
//
//  Created by YLCHUN on 2017/3/15.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportModelManager.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@interface JSExportModel()
@property (nonatomic, copy) NSString* spaceName;
+(NSString*)kJSExportModelKey;
+(NSString*)jsExportCallBackCode;
+(NSString*)jsExportCodeWithModel:(JSExportModel<JSExportProtocol>*)model;
+(void)jsExportCallWithScriptModelDict:(NSDictionary*)scriptModelDict message:(WKScriptMessage*)message;
@end

@interface _JSExportModelManager : NSObject <WKScriptMessageHandler>
@property (nonatomic, retain) NSMutableDictionary *jsExportCodeDict;
@property (nonatomic, retain) NSMutableDictionary *scriptModelDict;
@end

@implementation _JSExportModelManager

-(void)dealloc {
    [self.jsExportCodeDict removeAllObjects];
    [self.scriptModelDict removeAllObjects];
}

-(NSMutableDictionary *)jsExportCodeDict {
    if (!_jsExportCodeDict) {
        _jsExportCodeDict = [NSMutableDictionary dictionary];
    }
    return _jsExportCodeDict;
}

-(NSMutableDictionary *)scriptModelDict {
    if (!_scriptModelDict) {
        _scriptModelDict = [NSMutableDictionary dictionary];
    }
    return _scriptModelDict;
}

-(WKUserScript*)addScriptMessageHandlerModel:(JSExportModel<JSExportProtocol> *)handler {
    NSString* spaceName = handler.spaceName;
    WKUserScript *userScript = self.jsExportCodeDict[spaceName];
    if (!userScript) {
        NSString *javaScriptSource = [JSExportModel jsExportCodeWithModel:handler];
        userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];// forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
        self.jsExportCodeDict[spaceName] = userScript;
        self.scriptModelDict[spaceName] = handler;
    }
    return userScript;
}

- (WKUserScript*)removeScriptMessageHandlerModelForSpaceName:(NSString *)spaceName {
    WKUserScript *userScript = self.jsExportCodeDict[spaceName];
    [self.jsExportCodeDict removeObjectForKey:spaceName];
    [self.scriptModelDict removeObjectForKey:spaceName];
    return userScript;
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:[JSExportModel kJSExportModelKey]]) {
        [JSExportModel jsExportCallWithScriptModelDict:self.scriptModelDict message:message];
    }
}

+(WKUserScript*)jsExportCallBackUserScript {
    static WKUserScript *userScript  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *javaScriptSource = [JSExportModel jsExportCallBackCode];
        userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];// forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
    });
    return userScript;
}

@end

@interface WKUserContentController ()
@property (nonatomic) _JSExportModelManager *jsExportModelManager;
@end

@implementation WKUserContentController(JSExport)
-(_JSExportModelManager *)jsExportModelManager {
    return objc_getAssociatedObject(self, @selector(jsExportModelManager));
}

-(void)setJsExportModelManager:(_JSExportModelManager *)jsExportModelManager {
    objc_setAssociatedObject(self, @selector(jsExportModelManager), jsExportModelManager, OBJC_ASSOCIATION_RETAIN);
}

- (void)addScriptMessageHandlerModel:(JSExportModel<JSExportProtocol>*)handler {
    if (![handler conformsToProtocol:@protocol(JSExportProtocol)]) {
        NSAssert(false, @"%@未实现JSExportProtocol子协议", NSStringFromClass([handler class]));
        return;
    }
    if (!self.jsExportModelManager) {
        self.jsExportModelManager = [[_JSExportModelManager alloc] init];
        WKUserScript * userScript = [_JSExportModelManager jsExportCallBackUserScript];
        [self addUserScript:userScript];
        [self addScriptMessageHandler:self.jsExportModelManager name:[JSExportModel kJSExportModelKey]];
    }
    WKUserScript * userScript = [self.jsExportModelManager addScriptMessageHandlerModel:handler];
    [self addUserScript:userScript];
}

- (void)removeScriptMessageHandlerModelForSpaceName:(NSString *)spaceName {
    WKUserScript *userScript = [self.jsExportModelManager removeScriptMessageHandlerModelForSpaceName:spaceName];
    if (userScript) {
        NSMutableArray *userScripts = [self.userScripts mutableCopy];
        if ([userScripts containsObject:userScript]) {
            [userScripts removeObject:userScript];
            [self removeAllUserScripts];
            for (WKUserScript *userScript in userScripts) {
                [self addUserScript:userScript];
            }
        }
    }
}

- (void)removeAllScriptMessageHandlerModel {
    [self removeScriptMessageHandlerForName:[JSExportModel kJSExportModelKey]];
    NSMutableArray *_userScripts = [[self.jsExportModelManager.jsExportCodeDict allValues] mutableCopy];
    NSMutableArray *userScripts = [self.userScripts mutableCopy];
    NSInteger uCount = userScripts.count;
    for (WKUserScript *userScript in _userScripts){
        if ([userScripts containsObject:userScript]) {
            [userScripts removeObject:userScript];
        }
    }
    WKUserScript * userScript = [_JSExportModelManager jsExportCallBackUserScript];
    if ([userScripts containsObject:userScript]) {
        [userScripts removeObject:userScript];
    }
    if (uCount != userScripts.count) {
        [self removeAllUserScripts];
        for (WKUserScript *userScript in userScripts) {
            [self addUserScript:userScript];
        }
    }
    self.jsExportModelManager = nil;
}

@end
