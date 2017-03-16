//
//  ViewController.m
//  WebViewController
//
//  Created by YLCHUN on 2017/2/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "OCModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, weak) id wObj;
@end

@implementation ViewController


struct objcClass {
    struct objc_protocol_list *protocols ;
};
- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    self.textView.text = urlStr;
    self.textView.text = @"https://youlianchun.github.io/HtmlFile/JSOC/index.html";
//    self.textView.text = @"https://www.baidu.com";
//    self.textView.text = @"https://dev.upbox.com.cn:3443/upboxApi/match_getRecommendMatch.do";
// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionWKWebView:(UIButton *)sender {
    NSDictionary *params = @{@"userStatus":@"-1",@"resource":@"2",@"token":@"",@"appCode":@"2.1.2",@"dataResource":@"UPMIC_IOS"};
    WebViewController *wvc = [[WebViewController alloc] initWithUrl:self.textView.text];
//    WebViewController *wvc = [[WebViewController alloc] initWithUrl:self.textView.text params:params];
    [self.navigationController pushViewController:wvc animated:YES];
}


@end
