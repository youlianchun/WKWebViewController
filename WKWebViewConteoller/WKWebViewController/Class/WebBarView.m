//
//  WebBarView.m
//  WebViewController
//
//  Created by YLCHUN on 2017/3/2.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WebBarView.h"
@interface WebBarView ()
@property (nonatomic, retain) NSLayoutConstraint *heightConstraint;
@end
@implementation WebBarView

-(instancetype)initWithFrame:(CGRect)frame {
    return [self initWithHeight:frame.size.height];
}

-(instancetype)init {
    return [self initWithHeight:0];
}

-(instancetype)initWithHeight:(CGFloat)height {
    self = [super initWithFrame:CGRectMake(0, 0, 0, height)];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height];
        [self addConstraint:self.heightConstraint];
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)setHeight:(CGFloat)height {
    if (height<0) {
        return;
    }
    _height = height;
    self.heightConstraint.constant = height;
}

@end
