//
//  ToolViewController.m
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolViewController.h"
#import "ToolPanelView.h"

@interface ToolViewController ()<ToolPanelViewDelegate>
@property (nonatomic, retain) ToolPanelView *toolPanelView;
@property (nonatomic, retain) UIView* backgroundView;
@property (nonatomic, copy) void (^showCompletion)(void);
@end

@implementation ToolViewController

+(ToolViewController*)showWithAnimated: (BOOL)flag completion:(void (^)(void))completion {
    ToolViewController *vc = [[self alloc] init];
    if (vc.toolPanelView.sections.count == 0) {
        return nil;
    }
    vc.showCompletion = completion;
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:vc animated:NO completion:nil];
    return vc;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

#pragma mark- GET SET
-(ToolPanelView *)toolPanelView {
    if (!_toolPanelView) {
        _toolPanelView = [[ToolPanelView alloc] initWithToolItemViewClass:[self ToolItemViewClass] ToolSectionHeaderViewClass:[self ToolSectionHeaderViewClass]];
        _toolPanelView.delegate = self;
        [self.view addSubview:_toolPanelView];
        _toolPanelView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_toolPanelView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_toolPanelView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_toolPanelView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
    return _toolPanelView;
}

-(UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:_backgroundView atIndex:0];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTpaAction)];
        [_backgroundView addGestureRecognizer:tap];
    }
    return _backgroundView;
}

#pragma mark-
- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.toolPanelView.sections = [self toolItemSections];
    self.toolPanelView.transform = CGAffineTransformMakeTranslation (0, self.toolPanelView.height);
}

#pragma mark- show hide animated
-(void)showWithAnimated:(BOOL)flag {
    self.toolPanelView.userInteractionEnabled = YES;
    if (flag) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.toolPanelView.transform = CGAffineTransformMakeTranslation (0, 0);
        } completion:^(BOOL finished) {
            if (self.showCompletion) {
                self.showCompletion();
            }
        }];
    }else{
        self.toolPanelView.transform = CGAffineTransformMakeTranslation (0, 0);
        if (self.showCompletion) {
            self.showCompletion();
        }
    }
}

-(void)hidenWithAnimated:(BOOL)flag completion:(void (^)(void))completio{
    self.toolPanelView.userInteractionEnabled = NO;
    if(flag){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.toolPanelView.transform = CGAffineTransformMakeTranslation (0, self.toolPanelView.height);
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:completio];
        }];
    }else{
        self.toolPanelView.transform = CGAffineTransformMakeTranslation (0, self.toolPanelView.height);
        [self dismissViewControllerAnimated:flag completion:completio];
    }
}

#pragma mark-
-(void)backgroundTpaAction {
    __weak typeof(self) wself = self;
    [self hidenWithAnimated:YES completion:^{
        [wself hidenByBackgroundTouch:YES];
    }];
}

-(void)toolPanelView:(ToolPanelView*)view didiSelectToolItemItem:(ToolItem*)toolItem {
    __weak typeof(self) wself = self;
    [self hidenWithAnimated:YES completion:^{
        [wself hidenByBackgroundTouch:NO];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showWithAnimated:YES];
}

@end


#pragma mark -
#pragma mark - Realize
@implementation ToolViewController(Realize)
-(Class)ToolItemViewClass {return [ToolItemView class];}
-(Class)ToolSectionHeaderViewClass {return [ToolSectionHeaderView class];}
-(NSArray<ToolSectionItem *> *)toolItemSections{return @[];}
-(void)hidenByBackgroundTouch:(BOOL)flag{}
@end
