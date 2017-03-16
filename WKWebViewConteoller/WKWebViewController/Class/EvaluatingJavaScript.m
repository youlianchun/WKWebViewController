//
//  EvaluatingJavaScript.m
//  WebViewController
//
//  Created by YLCHUN on 2017/3/3.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "EvaluatingJavaScript.h"

@implementation EvaluatingJavaScript

+(NSString*)argumentsJSON:(NSArray*)arguments {
    NSString *paramsJSON = [self convertToJSONData:arguments];
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

+ (NSString*)convertToJSONData:(id)dictOrArr {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOrArr
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = @"";
    
    if (!jsonData){
        
    }else{
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    return jsonString;
}

@end
