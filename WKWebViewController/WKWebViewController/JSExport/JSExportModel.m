//
//  JSExportModel.m
//  WKWebView_JSExport
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportModel.h"
#import <objc/runtime.h>

@implementation WKWebView (JavaScript)

-(id)jsFunc:(NSString*)func arguments:(NSArray*)arguments {
    return [self callJSFunc:func arguments:arguments];
}

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
    NSString *paramsJSON = [self serializeMessageToJSON:arguments];
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

- (NSString*)serializeMessageToJSON:(id)dictOrArr {
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

typedef NS_ENUM(NSUInteger, _JSExportMethodType) {
    param0_return0 = 0x100,
    param0_return1 = 0x101,
    param1_return0 = 0x110,
    param1_return1 = 0x111
};
@interface _JSExportMethod : NSObject
@property (nonatomic) SEL sel;
@property (nonatomic) NSString *selName;
@property (nonatomic) NSString *selKey;
@property (nonatomic) NSString *selTypes;
@property (nonatomic) _JSExportMethodType methodType;
@end
@implementation _JSExportMethod
-(void)setSelTypes:(NSString *)selTypes {
    _selTypes = selTypes;
    if ([selTypes hasSuffix:@"@0:8"]) {//无参数,无返回值
        _methodType = param0_return0;
    }else{//有参数
        if ([selTypes containsString:@"@0:8@?"]) {//无参数，有返回值
            _methodType = param0_return1;
        }else{
            if ([selTypes containsString:@"@?"]) {//有参数有返回值
                _methodType = param1_return1;
            }else{//有参数，无返回值
                _methodType = param1_return0;
            }
        }
    }
}
@end

@interface JSExportModel ()
@property (nonatomic, copy) NSString* spaceName;
@property (nonatomic) NSDictionary <NSString*,_JSExportMethod*>*methodDict;
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


-(NSDictionary*)stringDictWithDict:(NSDictionary*)dict {
    NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
    NSArray * allKeys = [dict allKeys];
    for (id key in allKeys) {
        id value = dict[key];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = ((NSNumber*)value).description;
        }else
            if ([value isKindOfClass:[NSDictionary class]]) {
                value = [self stringDictWithDict:value];
            }else
                if ([value isKindOfClass:[NSArray class]]) {
                    value = [self stringArrWithArr:value];
                }else
                    if ([value isEqualToString:@"<null>"]) {
                        value = @"";
                    }
        resDict[key] = value;
    }
    return resDict;
}

-(NSArray *)stringArrWithArr:(NSArray*)arr {
    NSMutableArray *resArr = [NSMutableArray arrayWithCapacity:arr.count];
    for (long i = 0; i<arr.count; i++) {
        id value = arr[i];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = ((NSNumber*)value).description;
        }else
            if ([value isKindOfClass:[NSDictionary class]]) {
                value = [self stringDictWithDict:value];
            }else
                if ([value isKindOfClass:[NSArray class]]) {
                    value = [self stringArrWithArr:value];
                }else
                    if ([value isEqualToString:@"<null>"]) {
                        value = @"";
                    }
        resArr[i] = value;
    }
    return resArr;
}

- (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (!jsonData) {
        return nil;
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        if (toStringValue) {
            if ([jsonObject isKindOfClass:[NSArray class]]) {
                jsonObject = [self stringArrWithArr:jsonObject];
            }
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                jsonObject = [self stringDictWithDict:jsonObject];
            }
        }
        return jsonObject;
    }else{
        NSLog(@"unserializeJSON: %@ \n\neror: %@",jsonString, error.description);
        // 解析错误
        return nil;
    }
}

#pragma mark - classMethods

+(NSArray*)jsExportMethodsWithModel:(JSExportModel<JSExportProtocol>*)model {
    Protocol *jsProtocol = @protocol(JSExportProtocol);
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
            _JSExportMethod *method = [[_JSExportMethod alloc] init];
            method.sel = sel;
            method.selTypes = selTypes;
            method.selName  = selName;
            method.selKey = selKey;
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
    for (_JSExportMethod *method in methods) {
        NSString* name = method.selKey;
        NSString* key = [NSString stringWithFormat:@"%@_%@", model.spaceName, name];
        methodDict[key] = method;
        NSString *jsFunctionBody;
        switch (method.methodType) {
            case param0_return0:{
                NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                                  var key = '%@';\n\
                                  window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key});\n",model.spaceName, key, [self kJSExportModelKey]];
                jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (){\n%@\n}", key, body];
            }break;
            case param0_return1:{
                NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                                  var key = '%@';\n\
                                  _JSExportModel_holdCallBack(key, callBack);\n\
                                  window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key});\n",model.spaceName, key, [self kJSExportModelKey]];
                jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (callBack){\n%@\n}", key, body];
            }break;
            case param1_return0:{
                NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                                  var key = '%@';\n\
                                  window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key,'param':param});\n",model.spaceName, key, [self kJSExportModelKey]];
                jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (param){\n%@\n}", key, body];
            }break;
            case param1_return1:{
                NSString *body = [NSString stringWithFormat:@"var spaceName = '%@';\n\
                                  var key = '%@';\n\
                                  _JSExportModel_holdCallBack(key, callBack);\n\
                                  window.webkit.messageHandlers.%@.postMessage({'spaceName':spaceName,'key':key,'param':param});\n",model.spaceName, key, [self kJSExportModelKey]];
                jsFunctionBody = [NSString stringWithFormat:@"function _JSExportModel_%@ (param, callBack){\n%@\n}", key, body];
            }break;
            default:
                break;
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
    model.webView = message.webView;
    NSDictionary *methodDict = model.methodDict;
    _JSExportMethod *method = methodDict[key];
    SEL sel = method.sel;
    __weak WKWebView *webView = message.webView;
    JSExportCallBack callBack;
    if (method.methodType & 1) {
        callBack = ^(id param){
            NSDictionary *dict = @{@"key":key,@"param":param};
            [webView callJSFunc:@"_JSExportModel_callBack" arguments:@[dict]];
        };
    }
    if ([model respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        switch (method.methodType) {
            case param0_return0:{
                [model performSelector:sel];
            }break;
            case param0_return1:{
                [model performSelector:sel withObject:callBack];
            }break;
            case param1_return0:{
                [model performSelector:sel withObject:param];
            }break;
            case param1_return1:{
                [model performSelector:sel withObject:param withObject:callBack];
            }break;
            default:
                break;
        }
#pragma clang diagnostic pop
    }
}



+(NSString*)kJSExportModelKey{
    static NSString* kJSExportModel = @"_JSExportModel_";
    return kJSExportModel;
}
@end

