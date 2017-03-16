//
//  WebBarView.h
//  WebViewController
//
//  Created by YLCHUN on 2017/3/2.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBarView : UIView

@property (nonatomic, assign) CGFloat height;

-(instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithHeight:(CGFloat)height;

@end
