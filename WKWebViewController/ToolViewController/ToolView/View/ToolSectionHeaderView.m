//
//  ToolSectionHeaderView.m
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolSectionHeaderView.h"

@interface ToolSectionHeaderView ()
{
    UILabel *_textLabel;
    UIView *_lLineView, *_rLineView;
    UIColor *_lineColor;
    
}
@end

@implementation ToolSectionHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
    }
    return self;
}

-(UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textColor = [UIColor colorWithWhite:50/255.0 alpha:1];
        _lLineView = [[UIView alloc] init];
        _rLineView = [[UIView alloc] init];
        _lLineView.backgroundColor = self.lineColor;
        _rLineView.backgroundColor = self.lineColor;
        [self.contentView addSubview:_lLineView];
        [self.contentView addSubview:_rLineView];
        [self.contentView addSubview:_textLabel];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _lLineView.translatesAutoresizingMaskIntoConstraints = NO;
        _rLineView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_textLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_lLineView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lLineView attribute:NSLayoutAttributeLeft multiplier:1 constant:-10]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_lLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_textLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:-20]];
        [_lLineView addConstraint:[NSLayoutConstraint constraintWithItem:_lLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_lLineView attribute:NSLayoutAttributeTop multiplier:1 constant:-25]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rLineView attribute:NSLayoutAttributeRight multiplier:1 constant:10]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_textLabel attribute:NSLayoutAttributeRight multiplier:1 constant:20]];
        [_rLineView addConstraint:[NSLayoutConstraint constraintWithItem:_rLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_rLineView attribute:NSLayoutAttributeTop multiplier:1 constant:-25]];
    }
    return _textLabel;
}

-(UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = [UIColor colorWithWhite:220/255.0 alpha:1];
    }
    return _lineColor;
}
-(void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
}

+(CGFloat)height {
    return 34;
}
+(NSString*)identifier {
    static NSString*kIdentifier = @"ToolSectionHeaderView";
    return kIdentifier;
}
@end
