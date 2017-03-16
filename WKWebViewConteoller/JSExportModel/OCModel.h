//
//  OCModel.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSExportModel.h"

@protocol OCModelProtocol <JSExportProtocol>

-(void)func0;
-(void)func1:(NSString*)p;
-(void)funcN:(NSString*)p1 p2:(NSString*)p2;
@optional
-(void)pf0;

@end

@interface OCModel : NSObject <OCModelProtocol>
@property (nonatomic ) NSString* str;
-(void)ff;

@end
