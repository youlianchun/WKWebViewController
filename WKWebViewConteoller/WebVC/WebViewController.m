//
//  WebViewController.m
//  WebViewController
//
//  Created by YLCHUN on 2017/3/2.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WebViewController.h"
#import "WebToolViewController.h"
#import "UIBarButtonItem+Back.h"
#import "OCModel.h"

@interface WebViewController ()
@property(nonatomic,strong)UIBarButtonItem * backItem;

@property(nonatomic,strong)UIBarButtonItem * closeItem;

@property(nonatomic,strong)UIBarButtonItem * toolItem;

@property(nonatomic,strong)NSMutableArray * leftItems;

@property(nonatomic,strong)NSMutableArray * rightItems;

@end

@implementation WebViewController

- (UIBarButtonItem *)closeItem{
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    }
    return _closeItem;
}

- (UIBarButtonItem *)backItem{
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] initBackItemWithTitle:@"返回" target:self action:@selector(back:)];
    }
    return _backItem;
}

-(UIBarButtonItem *)toolItem {
    if (!_toolItem) {
        _toolItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gengduo"] style:UIBarButtonItemStylePlain target:self action:@selector(tool:)];
        _toolItem.imageInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        
    }
    return _toolItem;
}

- (void)setLeftItems:(NSMutableArray *)leftItems{
    _leftItems = leftItems;
    [self setLeftItems];
}

- (void)setLeftItems{
    self.navigationItem.leftBarButtonItems = _leftItems;
}

- (void)showCloseItem{
    if (![_leftItems containsObject:_closeItem]) {
        [self.leftItems addObject:_closeItem];
    }
    [self setLeftItems];
}

- (void)hiddenCloseItem{
    if ([_leftItems containsObject:_closeItem]) {
        [self.leftItems removeObject:_closeItem];
    }
    [self setLeftItems];
}

-(void)setRightItems:(NSMutableArray *)rightItems {
    _rightItems = rightItems;
    [self setRightItems];
}

- (void)setRightItems{
    self.navigationItem.rightBarButtonItems = _rightItems;
}

#pragma mark - BarButtonAction

- (void)close:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)back:(UIBarButtonItem *)sender{
    if (![self goBack]) {
        [self close:nil];
    }
}

- (void)tool:(UIBarButtonItem *)sender{
    [WebToolViewController showWithSelectedCallBack:^(WebToolType type) {
        [self toolAction:type];
    }];
}

#pragma mark - WebToolViewControllerAction
-(void)toolAction:(WebToolType)type {
    switch (type) {
        case WebToolType_s_WX:
            
            break;
        case WebToolType_s_PYQ:
            
            break;
        case WebToolType_s_QQ:
            
            break;
        case WebToolType_s_XLWB:
            
            break;
        case WebToolType_f_Refresh:
            [self reload];
            break;
        case WebToolType_f_Copy:{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.webView.URL.absoluteString;
        }
            break;
        default:
            break;
    }
}
-(void)shareAction {
    
}
#pragma mark - 

- (void)viewDidLoad {
    [super viewDidLoad];
    //左items
    self.leftItems = [NSMutableArray arrayWithObject:self.backItem];
    self.rightItems = [NSMutableArray arrayWithObject:self.toolItem];

    self.closeItem.tintColor = self.navigationController.navigationBar.tintColor;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
    });
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL*)willLoadRequestWithUrl:(NSURL *)url {
    NSString *urlStr  = url.absoluteString;
    if (![urlStr containsString:@"get_wp_ct"]) {
        if ([urlStr containsString:@"from=post"]) {
            urlStr = [NSString stringWithFormat:@"http://www.upbox.com.cn/get_wp_ct/html/?type=post&url=%@",urlStr];
        }else if([urlStr containsString:@"from=page"]) {
            urlStr = [NSString stringWithFormat:@"http://www.upbox.com.cn/get_wp_ct/html/?type=page&url=%@",urlStr];
        }
    }
    NSURL*newUrl = [NSURL URLWithString:urlStr];
    return newUrl;
}


#pragma mark - overwrite
- (ScriptMessageManager*)scriptMessageManagerWhenWebViewInit{
    ScriptMessageManager *smm = [[ScriptMessageManager alloc] init];
    __weak typeof(self) wself = self;
    [smm addScriptMessageHandlerForName:@"randomTitle" handler:^(id params) {
        static NSArray* titles;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            titles = @[@"哈哈",@"呵呵",@"嘿嘿",@"吼吼",@"哑哑",@"嘎嘎",@"咕咕",@"咯咯",@"咔咔",@"咚咚",@"叮叮",@"嘟嘟",@"呜呜",@"呼呼"];
        });
        int i = arc4random() % titles.count;
        wself.title = titles[i];
    }];
    
    [smm addScriptMessageHandlerForName:@"setTitle" handler:^(id params) {
        wself.title = params[0];
    }];

    [smm addScriptMessageHandlerForName:@"getAppVersion" returnName:@"appVersionRes" handler:^id(id params) {
        return @"1.0";
    }];
    
    [smm addScriptMessageHandlerForName:@"sumAB" asyncReturnName:@"resAB" handler:^(id params, ScriptAsyncReturnHandler asyncReturn) {
        NSInteger a = [params[0] integerValue];
        NSInteger b = [params[1] integerValue];
        NSInteger sum = a+b;
        asyncReturn(@(sum));
    }];
    
    [smm addScriptMessageHandlerForName:@"subAB" returnName:@"resAB" handler:^id(id params) {
        NSInteger a = [params[0] integerValue];
        NSInteger b = [params[1] integerValue];
        NSInteger sub = a-b;
        return @(sub);
    }];
    
    [smm addAdjustScreenSizeAndZooming:NO];
    OCModel *ocModel = [[OCModel alloc] initWithSpaceName:@"ocModel"];
    ocModel.vc = self;
    [smm addScriptMessageHandlerModel:ocModel];
    
    return smm;
}

- (NSString *)htmlForPNGImage:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imageSource = [NSString stringWithFormat:@"data:image/png;base64,%@",[imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]];
    return imageSource;
}

-(void)canGoBackChange:(BOOL)canGoBack {
    if (canGoBack) {
        [self showCloseItem];
    }else{
        [self hiddenCloseItem];
    }
}

@end
