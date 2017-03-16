//
//  UIApplication+UIOrientation.m
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "UIApplication+UIOrientation.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark - _AppDelegate
@interface _AppDelegate : NSObject
@property (nonatomic, readwrite, weak) id<UIApplicationDelegate> receiver;
@end
@implementation _AppDelegate
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return self;
    }
    if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString*selName=NSStringFromSelector(aSelector);
    if (![selName hasPrefix:@"keyboardInput"] && ![selName isEqualToString:@"customOverlayContainer"]) {//键盘输入代理过滤
        if ([super respondsToSelector:aSelector]) {
            return YES;
        }
        if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return false;
}

//解决横屏模式下播放视频不能横屏的问题
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    Class cls = NSClassFromString(kPlayerViewControllerClassName);
    if ([[window.rootViewController presentedViewController] isKindOfClass:cls] || [[window.rootViewController presentedViewController] isKindOfClass:NSClassFromString(@"MPInlineVideoFullscreenViewController")] || [[window.rootViewController presentedViewController] isKindOfClass:NSClassFromString(@"AVFullScreenViewController")]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else {
        if ([[window.rootViewController presentedViewController] isKindOfClass:[UINavigationController class]]) {
            // look for it inside UINavigationController
            UINavigationController *nc = (UINavigationController *)[window.rootViewController presentedViewController];
            // is at the top?
            if ([nc.topViewController isKindOfClass:cls]) {
                return UIInterfaceOrientationMaskAllButUpsideDown;
                // or it's presented from the top?
            } else if ([[nc.topViewController presentedViewController] isKindOfClass:cls]) {
                return UIInterfaceOrientationMaskAllButUpsideDown;
            }
        }
    }
    
    UIInterfaceOrientationMask mask;
    if ([self.receiver respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)]) {
        mask = [self.receiver application:application supportedInterfaceOrientationsForWindow:window];
    }else{
        mask = UIInterfaceOrientationMaskPortrait;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    return mask;
}

@end
#pragma mark -
#pragma mark - UIApplication+UIOrientation
@interface UIApplication()
@property (nonatomic, retain)_AppDelegate *o_delegate;
@end
@implementation UIApplication(UIOrientation)

+ (void)load {
    [super load];
    if (kOrientationEnabled) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self class];
            SEL originalSelector = @selector(setDelegate:);
            SEL swizzledSelector = @selector(o_setDelegate:);
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            if (success) {
                class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        });
    }
}

-(void)o_setDelegate:(id<UIApplicationDelegate>)delegate {
    self.o_delegate = [[_AppDelegate alloc] init];
    self.o_delegate.receiver = delegate;
    [self o_setDelegate:(id<UIApplicationDelegate>)self.o_delegate];
}

-(_AppDelegate *)o_delegate {
   return objc_getAssociatedObject(self, @selector(o_delegate));
}

-(void)setO_delegate:(_AppDelegate *)o_delegate {
    objc_setAssociatedObject(self, @selector(o_delegate), o_delegate, OBJC_ASSOCIATION_RETAIN);
}

@end

