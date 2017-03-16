//
//  ToolItemView.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//  自定义按钮布局需需要继承ToolItemView

#import <UIKit/UIKit.h>
struct ToolItemSize {
    CGFloat minWidth;
    CGFloat maxHeight;
};
typedef struct ToolItemSize ToolItemSize;
CG_INLINE ToolItemSize ToolItemSizeMake(CGFloat minWidth, CGFloat maxHeight)
{
    ToolItemSize size; size.minWidth = minWidth; size.maxHeight = maxHeight; return size;
}

@interface ToolItemView : UICollectionViewCell
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *textLabel;
+(NSString*) identifier; //继承后需要重写
+(ToolItemSize) itemSize; //继承后需要重写
@end
