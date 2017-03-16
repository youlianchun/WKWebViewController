//
//  ToolPanelView.m
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolPanelView.h"
#import "ToolSectionView.h"


@interface ToolPanelView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *panelTableView;
@property (nonatomic) Class ToolItemViewClass;
//@property (nonatomic, copy) NSArray<ToolSectionItem*> *sections;
@property (nonatomic, retain) ToolSectionHeaderView *clsObj_headerView;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, retain) NSLayoutConstraint *heightConstraint;
@end

@implementation ToolPanelView

-(instancetype)initWithToolItemViewClass:(Class)itemClass ToolSectionHeaderViewClass:(Class)headerClass {
    self = [super init];
    if (self) {
        Class cls = itemClass;
        BOOL b = [cls isSubclassOfClass:[ToolItemView class]];
        if (!b) {
            NSString *str = [NSString stringWithFormat:@"%@ 必须继承ToolItemView", NSStringFromClass(cls)] ;
            NSCAssert(b, str);
            cls = [ToolItemView class];
        }
        ToolItemView *itemView = [[cls alloc] init];
        self.itemHeight = [[itemView class] itemSize].maxHeight;
        
        self.ToolItemViewClass = cls;
        
        
        cls = headerClass;
        b = [cls isSubclassOfClass:[ToolSectionHeaderView class]];
        if (!b) {
            NSString *str = [NSString stringWithFormat:@"%@ 必须继承ToolSectionHeaderView", NSStringFromClass(cls)] ;
            NSCAssert(b, str);
            cls = [ToolSectionHeaderView class];
        }
        self.clsObj_headerView = [[cls alloc] init];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark- GET SET
-(CGFloat)height {
    return self.heightConstraint.constant;
}

-(void)setSections:(NSArray<ToolSectionItem *> *)sections {
    _sections = sections;
    self.heightConstraint.constant = sections.count * ([[self.clsObj_headerView class] height]+self.itemHeight)+25;
    [self.panelTableView reloadData];
}

-(NSLayoutConstraint *)heightConstraint {
    if (!_heightConstraint) {
        _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:_heightConstraint];
    }
    return _heightConstraint;
}

-(UITableView *)panelTableView {
    if (!_panelTableView) {
        _panelTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _panelTableView.bounces = NO;
        _panelTableView.delegate = self;
        _panelTableView.dataSource = self;
        _panelTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _panelTableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_panelTableView];
        [_panelTableView registerClass:[self.clsObj_headerView class] forHeaderFooterViewReuseIdentifier:[[self.clsObj_headerView class] identifier]];
        _panelTableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_panelTableView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_panelTableView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_panelTableView attribute:NSLayoutAttributeBottom multiplier:1 constant:25]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_panelTableView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
    return _panelTableView;
}

#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [[self.clsObj_headerView class] height];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ToolSectionHeaderView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[[self.clsObj_headerView class] identifier]];
    headerView.textLabel.text = self.sections[section].title;
    return headerView;
}

#pragma mark- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ToolSectionView_identifier";
    ToolSectionView *toolSectionView = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!toolSectionView) {
        toolSectionView = [[ToolSectionView alloc] initWithToolItemViewClass:self.ToolItemViewClass reuseIdentifier:identifier];
    }
    __weak typeof(self) wself = self;
    NSUInteger sectionIndex = indexPath.section;
    [toolSectionView setSectionItem:self.sections[sectionIndex] didSelectItem:^(NSUInteger index) {
        if ([wself.delegate respondsToSelector:@selector(toolPanelView:didiSelectToolItemItem:)]) {
            [wself.delegate toolPanelView:wself didiSelectToolItemItem:wself.sections[sectionIndex].items[index]];
        }
    }];
    return toolSectionView;
}
#pragma mark- 

@end
