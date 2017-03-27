//
//  EvaluatingJavaScript.m
//  WebViewController
//
//  Created by YLCHUN on 2017/3/3.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "EvaluatingJavaScript.h"

@implementation EvaluatingJavaScript

+(NSString*)argumentsJS:(NSArray*)arguments {
    NSMutableArray *argumentArray = [NSMutableArray arrayWithCapacity:arguments.count];
    for (int i = 0; i<arguments.count; i++) {
        if ([arguments[i] isKindOfClass:[NSDictionary class]]||[arguments[i] isKindOfClass:[NSArray class]]) {
            NSString *paramsJSON = [self convertToJSONData:arguments[i]];
            paramsJSON = [self JSONString:paramsJSON];
            argumentArray[i] = paramsJSON;
        }else{
            NSString *str = [NSString stringWithFormat:@"'%@'",arguments[i]];
            argumentArray[i] = str;
        }
    }
    NSString *paramStr = [argumentArray componentsJoinedByString:@","];
    return paramStr;
}

+(NSString*)argumentsJSON:(NSArray*)arguments {
    NSString *paramsJSON = [self convertToJSONData:arguments];
    NSRange range= NSMakeRange(1,paramsJSON.length-2);
    paramsJSON = [paramsJSON substringWithRange:range];
    paramsJSON = [self JSONString:paramsJSON];
    return paramsJSON;
}

+(NSString*)JSONString:(NSString*)string{
    NSString *paramsJSON = string;
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    return paramsJSON;


};

+ (NSString*)convertToJSONData:(id)dictOrArr {
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
