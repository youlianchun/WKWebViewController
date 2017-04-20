//
//  WebProcessPlant.h
//  WebViewController
//
//  Created by YLCHUN on 2017/3/2.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNull [[NSNull alloc] init]]

@interface WebProcessPlant : NSObject
+(NSString* )urlEncoding:(NSString *)url;
+(void)setCookieWithRequest:(NSMutableURLRequest *)request;
+(NSURL*)urlWithString:(NSString*)url;

+(void)addUserAgent:(NSString *)userAgent;

+ (void)deleteWebCache;
@end
