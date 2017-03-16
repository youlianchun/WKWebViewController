//
//  ToolSectionView.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolSectionItem.h"

@interface ToolSectionView : UITableViewCell
-(void)setSectionItem:(ToolSectionItem*)sectionItem didSelectItem:(void(^)(NSUInteger index)) action;
-(instancetype)initWithToolItemViewClass:(Class)cls reuseIdentifier:(NSString *)reuseIdentifier;
@end
