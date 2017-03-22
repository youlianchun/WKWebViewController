//
//  WebViewController.h
//  WebViewController
//
//  Created by YLCHUN on 2017/2/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScriptMessageManager.h"
#import "WebBarView.h"

@interface WKWebViewController : UIViewController

@property (nonatomic, readonly) WKWebView *webView;
@property (nonatomic, readonly) WebBarView *barView;
@property (nonatomic, readonly) NSURL *currentURL;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;

@property (nonatomic, readonly) WKPreferences *preferences;


/**
 GET发起请求

 @param url 请求地址
 @return WKWebViewController
 */
-(instancetype)initWithUrl:(id)url;

/**
 POST发起请求

 @param url 请求地址，非网络地址将采用GET方式请求
 @param params 参数，无参数将采用GET方式请求
 @return WKWebViewController
 */
-(instancetype)initWithUrl:(id)url params:(NSDictionary*)params;

-(instancetype)init NS_UNAVAILABLE;

-(void)pausePlayer;
- (void)loadData;
- (BOOL)goBack;
- (BOOL)goForward;
- (void)reload;

@end

@interface WKWebViewController (Realize)

- (NSURL*)willLoadRequestWithUrl:(NSURL*)url;
    
- (void)javaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame;
- (void)javaScriptAlertPanelWithMessage:(NSString *)message action:(BOOL)action initiatedByFrame:(WKFrameInfo *)frame;
- (NSString*)javaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText inputText:(NSString*)inputText initiatedByFrame:(WKFrameInfo *)frame;

- (void)didStartProvisionalNavigation:(WKNavigation *)navigation;
- (void)didCommitNavigation:(WKNavigation *)navigation;
- (void)didFinishNavigation:(WKNavigation *)navigation;
- (void)didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;
- (BOOL)decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse;
- (BOOL)decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction;
- (ScriptMessageManager*)scriptMessageManagerWhenWebViewInit;//webView未创建
- (void)canGoBackChange:(BOOL)canGoBack;
- (void)canGoForwardChange:(BOOL)canGoForward;
@end

