//
//  JSExportModelManager.h
//  JSTrade
//
//  Created by YLCHUN on 2017/3/15.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportModel.h"
#import <WebKit/WKUserContentController.h>

@interface WKUserContentController (JSExport)

- (void)addScriptMessageHandlerModel:(JSExportModel<JSExportProtocol>*)handler;
- (void)removeScriptMessageHandlerModelForSpaceName:(NSString *)spaceName;

- (void)removeAllScriptMessageHandlerModel;

@end;
