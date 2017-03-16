//
//  ScriptMessageHandler.m
//  WebViewController
//
//  Created by YLCHUN on 2017/2/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ScriptMessageHandler.h"
@interface ScriptMessageHandler()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *returnName;
@property (nonatomic, copy) id handler;
@property (nonatomic, assign) ScriptReturnType returnType;

@end

@implementation ScriptMessageHandler
-(instancetype)initWithName:(NSString*)name voidHandler:(void(^)(id params))voidHandler {
    self = [super init];
    if (self) {
        self.name = name;
        self.handler = voidHandler;
        self.returnType = VoidReturn;
    }
    return self;
}

-(instancetype)initWithName:(NSString*)name returnName:(NSString*)returnName returnHandler:(id(^)(id params))returnHandler {
    self = [super init];
    if (self) {
        self.name = name;
        self.returnName = returnName;
        self.handler = returnHandler;
        self.returnType = SyncReturn;
    }
    return self;
}

-(instancetype)initWithName:(NSString*)name asyncReturnName:(NSString*)asyncReturnName returnHandler:(ScriptMessageAsyncReturnHandler)returnHandler {
    self = [super init];
    if (self) {
        self.name = name;
        self.returnName = asyncReturnName;
        self.handler = returnHandler;
        self.returnType = AsyncReturn;
    }
    return self;
}

@end
