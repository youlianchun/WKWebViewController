//
//  JSExportModel.h
//  WKWebView_JSExport
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void(^JSExportCallBack) (id object);

/**
 JSExportProtocol 
 多个JSExportProtocol协议只支持第一个
 函数最多 一个object参数 和 一个callBack返回值
 */
@protocol JSExportProtocol <NSObject>

//接受的四种函数格式
//-(void)func0;                                 //window.<#spaceName#>.func0();
//-(void)func1:(id)p;                           //window.<#spaceName#>.func1(<#param#>);
//-(void)func2:(JSExportCallBack)cb;            //window.<#spaceName#>.func2(function(param){});
//-(void)func3:(id)p cb:(JSExportCallBack)cb;   //window.<#spaceName#>.func3(<#param#>, function(param){});

@end

@interface WKWebView (JavaScript)

-(id)jsFunc:(NSString*)func arguments:(NSArray*)arguments;

@end

@interface JSExportModel : NSObject


/**
 js调用代码 window.<#spaceName#>.func()
 */
@property (nonatomic, readonly) NSString* spaceName;

/**
 webView 弱引用，当JSExportProtocol函数被响应时候才会有值
 */
@property (nonatomic, weak, readonly) WKWebView *webView;

-(instancetype)initWithSpaceName:(NSString*)name;

- (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue;

@end
