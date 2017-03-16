//
//  ToolItemView.m
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolItemView.h"

@implementation ToolItemView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self construction];
    }
    return self;
}

-(void)construction {
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.textColor = [UIColor colorWithWhite:50/255.0 alpha:1];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.textLabel];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    self.imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTop multiplier:1 constant:-10]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
}

+(NSString*) identifier {
    static NSString*kIdentifier = @"ToolItemView";
    return kIdentifier;
}


+(ToolItemSize) itemSize {
    return ToolItemSizeMake(50, 80);
}

@end
