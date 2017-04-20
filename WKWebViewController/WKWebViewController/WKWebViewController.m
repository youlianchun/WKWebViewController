//
//  WebViewController.m
//  WebViewController
//
//  Created by YLCHUN on 2017/2/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WKWebViewController.h"
#import "WebProcessPlant.h"
#import "WKWebView+EvaluatingJavaScript.h"
#import "JSExport.h"
#import "PlayerPause.h"
#import "UIViewController+FullScreen.h"

#define kWebViewEstimatedProgress @"estimatedProgress"
#define kWebViewCanGoBack @"canGoBack"
#define kWebViewCanGoForward @"canGoForward"

@interface WKWebViewController ()<WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, retain) WKWebView *webView;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableURLRequest *urlRequest;
@property (nonatomic, retain) NSDictionary *params;
//@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@property (nonatomic, retain) WebBarView *barView;
@property (nonatomic, retain) UIProgressView * progressView;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) BOOL observerEnabled;

@end

@implementation WKWebViewController

+(NSArray*)infoUrlSchemes{
    static NSMutableArray *kInfoUrlSchemes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kInfoUrlSchemes = [NSMutableArray array];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSMutableDictionary *dict  = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSArray *urlTypes = dict[@"CFBundleURLTypes"];
        for (NSDictionary *urlType in urlTypes) {
            [kInfoUrlSchemes addObjectsFromArray:urlType[@"CFBundleURLSchemes"]];
        }
    });
    return kInfoUrlSchemes;
}

+(NSArray*)infoOpenURLs{
    static NSMutableArray *kInfoOpenURLs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kInfoOpenURLs = [NSMutableArray array];
        [kInfoOpenURLs addObject:@"tel"];
        [kInfoOpenURLs addObject:@"telprompt"];
        [kInfoOpenURLs addObject:@"sms"];
        [kInfoOpenURLs addObject:@"mailto"];
    });
    return kInfoOpenURLs;
}

-(instancetype)initWithUrl:(id)url params:(NSDictionary*)params {
    WKWebViewController *vc = [self initWithUrl:url];
    self.params = params;
    return vc;
}

-(instancetype)initWithUrl:(id)url {
    NSString *tmpStr;
    if ([url isKindOfClass:[NSURL class]]) {
        tmpStr = ((NSURL*)url).absoluteString;
    }else if ([url isKindOfClass:[NSString class]]) {
        tmpStr = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    NSURL *anUrl = [WebProcessPlant urlWithString:tmpStr];
    if (anUrl) {
        self = [super init];
        if (self) {
            self.url = anUrl;
            [self construction];
        }
        return self;
    }
    return nil;
}

-(void)construction  {
    self.hidesBottomBarWhenPushed = YES;
}

-(void)dealloc {
    self.observerEnabled = NO;
    [self.webView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    ScriptMessageManager *smm = (ScriptMessageManager*)[self.webView configuration].userContentController;
    [smm removeAllScriptMessageHandler];
    [smm removeAllScriptMessageHandlerModel];
    self.urlRequest = nil;
    self.url = nil;
    self.webView = nil;
}

#pragma mark - GET SET

//-(UIActivityIndicatorView *)activityView {
//    if (!_activityView) {
//        _activityView = [[UIActivityIndicatorView alloc]init];
//        [self.view addSubview:_activityView];
//        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//        _activityView.hidesWhenStopped = YES;
//        _activityView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_activityView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
//        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_activityView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
//    }
//    return _activityView;
//}

-(NSURL *)currentURL {
    NSURL *url;
    if (self.webView.URL) {
        url = self.webView.URL;
    }else{
        url = self.url;
    }
    return url;
}


-(WKPreferences *)preferences {
    return self.webView.configuration.preferences;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.tintColor = [UIColor greenColor];
        [self.view addSubview:_progressView];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    }
    return _progressView;
}

-(WebBarView *)barView {
    if (!_barView) {
        _barView = [[WebBarView alloc] initWithHeight:0];
        [self.view insertSubview:_barView atIndex:0];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_barView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_barView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_barView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    }
    return _barView;
}

-(WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        // 允许在线播放
        configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        configuration.selectionGranularity = YES;
        // web内容处理池
        configuration.processPool = [[WKProcessPool alloc] init];
        // 是否支持记忆读取
        configuration.suppressesIncrementalRendering = YES;
        // 设置是否允许自动播放
        configuration.mediaPlaybackRequiresUserAction = YES;//一定要在 WKWebView 初始化之前设置，在 WKWebView 初始化之后设置无效。
        // 偏好设置
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptCanOpenWindowsAutomatically = NO;
        configuration.preferences = preferences;
        //        preferences.minimumFontSize = 40.0;
        ScriptMessageManager *jsmm = [self scriptMessageManagerWhenWebViewInit];
        if (jsmm) {
            configuration.userContentController = jsmm;
        }
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        //开启手势触摸
        _webView.allowsBackForwardNavigationGestures = true;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [self.view insertSubview:_webView atIndex:0];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.barView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        
    }
    return _webView;
}

-(void)setObserverEnabled:(BOOL)observerEnabled {
    if (_observerEnabled == observerEnabled) {
        return;
    }
    _observerEnabled = observerEnabled;
    if (observerEnabled) {
        [self.webView addObserver:self forKeyPath:kWebViewEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:kWebViewCanGoBack options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:kWebViewCanGoForward options:NSKeyValueObservingOptionNew context:nil];
    }else{
        [self.webView removeObserver:self forKeyPath:kWebViewEstimatedProgress];
        [self.webView removeObserver:self forKeyPath:kWebViewCanGoBack];
        [self.webView removeObserver:self forKeyPath:kWebViewCanGoForward];
    }
}

-(BOOL)canGoBack {
    return _webView.canGoBack;
}

-(BOOL)canGoForward {
    return _webView.canGoForward;
}

#pragma mark -

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.progressView.hidden = YES;
    self.observerEnabled = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:kWebViewEstimatedProgress]) {
        self.progressView.progress = self.webView.estimatedProgress;
        return;
    }
    if ([keyPath isEqualToString:kWebViewCanGoBack]) {
        [self canGoBackChange:self.webView.canGoBack];
        return;
    }
    if ([keyPath isEqualToString:kWebViewCanGoForward]) {
        [self canGoForwardChange:self.webView.canGoForward];
        return;
    }
}

-(void)loadData {
    NSURL *url = [self willLoadRequestWithUrl:self.url];
    if (!url) {
        url = self.url;
    }else{
        url = [WebProcessPlant urlWithString:url.absoluteString];
    }
    NSString *str = [url.absoluteString lowercaseString];
    BOOL loactionUrl = [str hasPrefix:@"/"] || [str hasPrefix:@"file://"];
    if (loactionUrl) {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
            [self.webView loadFileURL:url allowingReadAccessToURL:url];
        }else{
            NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [self.webView loadRequest:request];
        }
    }else{
        [self loadRequestWithUrl:url];
    }
}

- (void)loadRequestWithUrl:(NSURL *)url {
    self.urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [WebProcessPlant setCookieWithRequest:self.urlRequest];
//    [self.activityView startAnimating];
    if (self.params) {
        self.urlRequest.HTTPMethod = @"POST";
        [self.urlRequest setHTTPBody:[[self postParams] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self.webView loadRequest:self.urlRequest];
}

-(NSString*)postParams{
    NSArray *allKeys = self.params.allKeys;
    if(allKeys.count==0){
        return @"";
    }
    NSMutableArray *keyValue = [NSMutableArray array];
    for (NSString* key in allKeys) {
        [keyValue addObject:[NSString stringWithFormat:@"%@=%@", key, self.params[key]]];
    }
    NSString* param = [keyValue componentsJoinedByString:@"&"];
    return param;
}

-(void)disableUserInteractionWithView:(UIView*)view time:(double)interval {//视图禁止响应
    if(!view || time<=0) {
        return;
    }
    view.userInteractionEnabled = NO;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
    });
    dispatch_source_set_cancel_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            view.userInteractionEnabled = YES;
        });
    });
    dispatch_resume(timer);
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // 类似UIWebView的 -webViewDidStartLoad:
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [self.activityView startAnimating];
    self.progressView.hidden = NO;
    [self didStartProvisionalNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self didCommitNavigation:navigation];
//    NSLog(@"didCommitNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 类似 UIWebView 的 －webViewDidFinishLoad:
//    [self.activityView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (webView.title.length > 0) {
        self.title = webView.title;
    }
    self.backPanEnabled = !self.webView.canGoBack;
    self.progressView.hidden = YES;
    [self didFinishNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    NSLog(@"%s : %@",__func__ , error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    [self.activityView stopAnimating];
    self.progressView.hidden = YES;
    [self didFailProvisionalNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    //当客户端收到服务器的响应头，根据response相关信息，可以决定这次跳转是否可以继续进行。
    BOOL b = [self decidePolicyForNavigationResponse:navigationResponse];
    if (b) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }else{
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [self pausePlayer];
    NSURL *url = navigationAction.request.URL;
    UIApplication *app = [UIApplication sharedApplication];
    if([[WKWebViewController infoOpenURLs] containsObject:url.scheme]) {
        if ([app canOpenURL:url]){
            [self disableUserInteractionWithView:webView time:0.2];
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    if([[WKWebViewController infoUrlSchemes] containsObject:url.scheme] ||
       [url.absoluteString containsString:@"itunes.apple.com"] ||
       [url.absoluteString isEqualToString:UIApplicationOpenSettingsURLString]) {
        if ([app canOpenURL:url]){
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    BOOL b = [self decidePolicyForNavigationAction:navigationAction];
    decisionHandler(b);
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"createWebView: %@",navigationAction.request.URL.absoluteString);
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// https 支持
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSLog(@"https证书");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}


- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
//    当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用上面的回调函数，我们在该函数里执行[webView reload](这个时候 webView.URL 取值尚不为 nil）解决白屏问题。在一些高内存消耗的页面可能会频繁刷新当前页面，H5侧也要做相应的适配操作。
    [webView reload];
}


#pragma mark -
-(void)pausePlayer{
    pauseAllPlayer();
}

- (BOOL)goBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];//-[WKWebView goBack], 回退到上一个页面后不会触发window.onload()函数、不会执行JS。
    }
    return [self.webView canGoBack];
}

- (BOOL)goForward {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
    return [self.webView canGoForward];
}

- (void)reload {
    if (self.webView.URL) {
        [self.webView reload];
    }else{
        [self.webView loadRequest:self.urlRequest];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //到在一个高内存消耗的H5页面上 present 系统相机，拍照完毕后返回原来页面的时候出现白屏现象（拍照过程消耗了大量内存，导致内存紧张，WebContent Process 被系统挂起），但上面的回调函数并没有被调用。在WKWebView白屏的时候，另一种现象是 webView.titile 会被置空, 因此，可以在 viewWillAppear 的时候检测 webView.title 是否为空来 reload 页面
    if (!self.webView.title && self.webView.URL.absoluteString.length>0) {
        [self.webView reload];
    }
    self.isVisible = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self pausePlayer];
}

@end


#pragma mark -
#pragma mark - WKUIDelegate
@implementation WKWebViewController(WKUIDelegate)

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
//    if (!self.isVisible/*UIViewController of WKWebView has finish push or present animation*/) {//控制器还未显示完成
//        completionHandler();
//        return;
//    }
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          [self javaScriptAlertPanelWithMessage:message initiatedByFrame:frame];
                                                          completionHandler();
                                                      }]];
    
    if (self.isVisible){//控制器不在显示时候不进行弹出操作
        [self presentViewController:alertController animated:YES completion:^{}];
    }else {
        completionHandler();
    }
}


- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    void (^alertResult)(BOOL) = ^(BOOL b){
        [self javaScriptAlertPanelWithMessage:message action:b initiatedByFrame:frame];
    };
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          alertResult(NO);
                                                          completionHandler(NO);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          alertResult(YES);
                                                          completionHandler(YES);
                                                      }]];
    
    if (self.isVisible){//控制器不在显示时候不进行弹出操作
        [self presentViewController:alertController animated:YES completion:^{}];
    }else {
        completionHandler(NO);
    }
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  completionHandler([[alertController.textFields lastObject] text]);
                                              }]];
    
    if (self.isVisible){//控制器不在显示时候不进行弹出操作
        [self presentViewController:alertController animated:YES completion:^{}];
    }else {
        completionHandler(nil);
    }
}

@end
#pragma mark -
#pragma mark - Realize
@implementation WKWebViewController(Realize)
- (NSURL*)willLoadRequestWithUrl:(NSURL *)url {return url;}
- (void)javaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame {}
- (void)javaScriptAlertPanelWithMessage:(NSString *)message action:(BOOL)action initiatedByFrame:(WKFrameInfo *)frame {}
- (NSString*)javaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText inputText:(NSString*)inputText initiatedByFrame:(WKFrameInfo *)frame{return nil;}

- (void)didStartProvisionalNavigation:(WKNavigation *)navigation{}
- (void)didCommitNavigation:(WKNavigation *)navigation{}
- (void)didFinishNavigation:(WKNavigation *)navigation{}
- (void)didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{}
- (BOOL)decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse{return YES;}
- (BOOL)decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction{return YES;}
- (ScriptMessageManager*)scriptMessageManagerWhenWebViewInit{return nil;}
- (void)canGoBackChange:(BOOL)canGoBack{}
- (void)canGoForwardChange:(BOOL)canGoForward{}


@end


