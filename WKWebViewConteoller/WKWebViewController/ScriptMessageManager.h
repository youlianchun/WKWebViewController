//
//  ScriptMessageManager.h
//  WebViewController
//
//  Created by YLCHUN on 2017/2/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "ScriptMessageHandler.h"

@interface ScriptMessageManager : WKUserContentController

@property (nonatomic, assign) BOOL recent;//采用最新的,默认YES

- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;

- (void)addScriptMessageHandlerForName:(NSString *)name handler:(ScriptMessageVoidHandler)handler;

- (void)addScriptMessageHandlerForName:(NSString *)name returnName:(NSString*)returnName handler:(ScriptMessageReturnHandler)handler;

- (void)addScriptMessageHandlerForName:(NSString *)name asyncReturnName:(NSString*)returnName handler:(ScriptMessageAsyncReturnHandler)handler;

- (void)removeScriptMessageHandlerForName:(NSString *)name;

- (void)removeAllScriptMessageHandler;

- (void)addCookieWithDict:(NSDictionary*)dict;// 无法跨域设置 cookie

- (void)addAdjustScreenSizeAndZooming:(BOOL)zooming;

@end

