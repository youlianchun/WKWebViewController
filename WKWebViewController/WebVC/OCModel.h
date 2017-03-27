//
//  OCModel.h
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSExport.h"

@protocol OCModelProtocol <JSExportProtocol>

-(void)randomTitle;
-(void)setTitle:(id)params;
-(void)getAppVersion:(JSExportCallBack)cb;
-(void)sumAB:(id)params cb:(JSExportCallBack)cb;
-(void)subAB:(id)params cb:(JSExportCallBack)cb;

-(void)getImage:(JSExportCallBack)cb;


@end

@interface OCModel : JSExportModel <OCModelProtocol>
@property (nonatomic, weak) UIViewController *vc ;
@end
