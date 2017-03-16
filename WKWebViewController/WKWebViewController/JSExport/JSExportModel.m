//
//  JSExportModel.m
//  WKWebView_JSExport
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportModel.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@implementation WKWebView (JavaScript)

-(id)callJSFunc:(NSString*)func arguments:(NSArray*)arguments {
    NSString *paramsJSON = [self argumentsJSON:arguments];
    NSString *jsString = [NSString stringWithFormat:@"%@('%@')", func, paramsJSON];
    __block id retuenValue;
    __block BOOL isExecuted = NO;
    [self evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        retuenValue = result;
        isExecuted = YES;
    }];
    while (isExecuted == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return retuenValue;
}

-(NSString*)argumentsJSON:(NSArray*)arguments {
    NSString *paramsJSON = [self serializeMessageToJSONData:arguments];
    NSRange range= NSMakeRange(1,paramsJSON.length-2);
    paramsJSON = [paramsJSON substringWithRange:range];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    return paramsJSON;
}

- (NSString*)serializeMessageToJSONData:(id)dictOrArr {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOrArr
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = @"";
    if (jsonData){
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    }
    return jsonString;
}

@end

@interface JSExportModel ()
@property (nonatomic, copy) NSString* spaceName;
@property (nonatomic) NSDictionary *methodDict;
@property (nonatomic, weak) WKWebView *webView;
@end

@implementation JSExportModel

-(instancetype)initWithSpaceName:(NSString*)name {
    self = [super init];
    if (self) {
        if (name.length == 0) {
            self.spaceName = NSStringFromClass([self class]);
        }else{
            self.spaceName = name;
        }
    }
    return self;
}

+(NSArray*)jsExportMethodsWithModel:(JSExportModel<JSExportProtocol>*)model {
    Protocol *jsProtocol = objc_getProtocol("JSExportProtocol");
    Class cls = [model class];
    if (class_conformsToProtocol(cls,jsProtocol)){
        unsigned int listCount = 0;
        Protocol * __unsafe_unretained *protocolList =  class_copyProtocolList(cls, &listCount);
        for (int i = 0; i < listCount; i++) {
            Protocol *protocol = protocolList[i];
            if(protocol_conformsToProtocol(protocol, jsProtocol)) {
                jsProtocol = protocol;
                break;
            }
        }
        free(protocolList);
        struct objc_method_description * methodList = protocol_copyMethodDescriptionList(jsProtocol, YES, YES, &listCount);
        NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:listCount];
        for(int i=0;i<listCount;i++) {
            SEL sel = methodList[i].name;
            char *type = methodList[i].types;
            NSString *selName = NSStringFromSelector(sel);
            NSString *selKey = [selName componentsSeparatedByString:@":"][0];
            NSString *selTypes = [NSString stringWithUTF8String:type];
            NSDictionary *method = @{@"key":selKey,@"name":selName,@"types":selTypes};
            methodArray[i] = method;
        }
        free(methodList);
        return methodArray;
    }else{
        return nil;
    }
}
+(NSString*)jsExportCallBackCode {
    NSMutableString *jsExportModelString = [[NSMutableString alloc] init];
    [jsExportModelString appendString:@"var _JSExportModel_callBackHandlers = {};\n"];
    [jsExportModelString appendString:@"function _JSExportModel_holdCallBack(key, callBack) {\n\
     if ((callBack && key) && (_JSExportModel_callBackHandlers[key] != callBack)){\n\
     _JSExportModel_callBackHandlers[key] = callBack;\n\
     }\n}\n\n"];
    
    [jsExportModelString appendString:@"function _JSExportModel_callBack (paramsJSON) {\n\
     var params = JSON.parse(paramsJSON);\n\
     var key = params.key;\n\
     var param = params.param;\n\
     var callBack = _JSExportModel_callBackHandlers[key];\n\
     if (callBack) {\n\
     callBack(param);\n\
     }\n}\n\n"];
    
    return jsExportModelString;
}

+(NSString*)jsExportCodeWithModel:(JSExportModel<JSExportProtocol>*)model {
    NSArray *methods = [self jsExportMethodsWithModel:model];
    NSMutableArray *jsFunctionNameArray = [NSMutableArray array];
    NSMutableArray *jsFunctionBodyArray = [NSMutableArray array];
    NSMutableDictionary *methodDict = [NSMutableDictionary dictionary];
    for (NSDictionary *method in methods) {
        NSString* name = method[@"key"];
        NSString* key = [NSString stringWithFormat:@"%@_%@", model.spaceName, name];
        methodDict[key] = method;
        NSString* types = method[@"types"];
        NSString *jsFunctionBody;
        if ([types hasSuffix:@"@0:8"]) {//无参数,无返回值
            NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                              var key = '%@';\n\
                              window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key});\n",model.spaceName, key, [self kJSExportModelKey]];
            jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (){\n%@\n}", key, body];
        }else{//有参数
            if ([types containsString:@"@0:8@?"]) {//无参数，有返回值
                NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                                  var key = '%@';\n\
                                  _JSExportModel_holdCallBack(key, callBack);\n\
                                  window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key});\n",model.spaceName, key, [self kJSExportModelKey]];
                jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (callBack){\n%@\n}", key, body];
            }else{
                if ([types containsString:@"@?"]) {//有参数有返回值
                    NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                                      var key = '%@';\n\
                                      _JSExportModel_holdCallBack(key, callBack);\n\
                                      window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key,'param':param});\n",model.spaceName, key, [self kJSExportModelKey]];
                    jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (param, callBack){\n%@\n}", key, body];
                }else{//有参数，无返回值
                    NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                                      var key = '%@';\n\
                                      window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key,'param':param});\n",model.spaceName, key, [self kJSExportModelKey]];
                    jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (param){\n%@\n}", key, body];
                }
            }
        }
        [jsFunctionNameArray addObject:[NSString stringWithFormat:@"%@ : _JSExportModel_%@ ", name, key]];
        [jsFunctionBodyArray addObject:jsFunctionBody];
    }
    model.methodDict = methodDict;
    NSMutableString *jsExportModelString = [[NSMutableString alloc] init];
    [jsExportModelString appendFormat:@"window.%@ = ", model.spaceName];
    [jsExportModelString appendString:@"{\n"];
    NSString * jsFunctionName = [jsFunctionNameArray componentsJoinedByString:@",\n"];
    [jsExportModelString appendString:jsFunctionName];
    [jsExportModelString appendString:@"\n}\n\n"];
    
    
    NSString * jsFunctionBody = [jsFunctionBodyArray componentsJoinedByString:@"\n\n"];
    [jsExportModelString appendString:jsFunctionBody];
    return jsExportModelString;
};

+(void)jsExportCallWithScriptModelDict:(NSDictionary*)scriptModelDict message:(WKScriptMessage*)message {
    NSDictionary *dict = message.body;
    NSString *spaceName = dict[@"spaceName"];
    id param = dict[@"param"];
    NSString* key = dict[@"key"];
    JSExportModel *model = scriptModelDict[spaceName];
    NSDictionary *methodDict = model.methodDict;
    NSString *selName = methodDict[key][@"name"];
    NSString *types = methodDict[key][@"types"];
    SEL sel = NSSelectorFromString(selName);
    JSExportCallBack callBack;
    __weak WKWebView *webView = message.webView;
    model.webView = webView;
    if ([types containsString:@"@?"]) {
        callBack = ^(id param){
            NSDictionary *dict = @{@"key":key,@"param":param};
            [webView callJSFunc:@"_JSExportModel_callBack" arguments:@[dict]];
        };
    }
    if ([model respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([types hasSuffix:@"@0:8"]) {//无参数,无返回值
            [model performSelector:sel];
        }else{//有参数
            if ([types containsString:@"@0:8@?"]) {//无参数，有返回值
                [model performSelector:sel withObject:callBack];
            }else{
                if ([types containsString:@"@?"]) {//有参数有返回值
                    [model performSelector:sel withObject:param withObject:callBack];
                }else{//有参数，无返回值
                    [model performSelector:sel withObject:param];
                }
            }
        }
#pragma clang diagnostic pop
    }
}

+(NSString*)kJSExportModelKey{
    static NSString* kJSExportModel = @"_JSExportModel_";
    return kJSExportModel;
}
@end

