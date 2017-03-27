//
//  EvaluatingJavaScript.h
//  WebViewController
//
//  Created by YLCHUN on 2017/3/3.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvaluatingJavaScript : NSObject
+(NSString*)argumentsJS:(NSArray*)arguments;
+(NSString*)argumentsJSON:(NSArray*)arguments;
@end
