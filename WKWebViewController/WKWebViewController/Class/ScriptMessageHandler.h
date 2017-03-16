//
//  ScriptMessageHandler.h
//  WebViewController
//
//  Created by YLCHUN on 2017/2/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, ScriptReturnType) {
    VoidReturn,
    SyncReturn,
    AsyncReturn
};

typedef void(^ScriptAsyncReturnHandler)(id result);

typedef void(^ScriptMessageVoidHandler)(id params);
typedef id(^ScriptMessageReturnHandler)(id params);
typedef void(^ScriptMessageAsyncReturnHandler)(id params, ScriptAsyncReturnHandler asyncReturn);

@interface ScriptMessageHandler : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *returnName;
@property (nonatomic, readonly) id handler;
@property (nonatomic, readonly) ScriptReturnType returnType;

-(instancetype)initWithName:(NSString*)name voidHandler:(ScriptMessageVoidHandler)voidHandler;

-(instancetype)initWithName:(NSString*)name returnName:(NSString*)returnName returnHandler:(ScriptMessageReturnHandler)returnHandler;

-(instancetype)initWithName:(NSString*)name asyncReturnName:(NSString*)asyncReturnName returnHandler:(ScriptMessageAsyncReturnHandler)returnHandler;


@end
