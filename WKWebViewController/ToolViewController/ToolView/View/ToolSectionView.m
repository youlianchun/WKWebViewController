//
//  ToolSectionView.m
//  WKWebViewController
//
//  Created by YLCHUN on 2017/3/9.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ToolSectionView.h"
#import "ToolItemView.h"
static NSUInteger kDisplatItemCount = 4;
@interface ToolSectionView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, retain) UICollectionView *sectionCollectionView;
@property (nonatomic, retain) ToolSectionItem *sectionItem;
@property (nonatomic, retain) ToolItemView *clsObj_itemView;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) ToolItemSize size;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, copy) void(^didSelectItemAction)(NSUInteger index);
@end

@implementation ToolSectionView

-(instancetype)initWithToolItemViewClass:(Class)cls reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        NSString *str = [NSString stringWithFormat:@"%@ 必须继承ToolItemView", NSStringFromClass(cls)] ;
        NSCAssert([cls isSubclassOfClass:[ToolItemView class]], str);
        self.clsObj_itemView = [[cls alloc] init];
        self.size = [[self.clsObj_itemView class] itemSize];
        self.itemHeight = self.size.maxHeight;
        self.offset = ([UIScreen mainScreen].bounds.size.width - kDisplatItemCount*self.size.minWidth)/(2*(kDisplatItemCount+1));
        self.itemSize = CGSizeMake(self.offset+self.offset+self.size.minWidth, self.size.maxHeight);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark- GET SET
-(UICollectionView *)sectionCollectionView {
    if (!_sectionCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = self.itemSize;
        _sectionCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _sectionCollectionView.showsHorizontalScrollIndicator = NO;
        _sectionCollectionView.showsVerticalScrollIndicator = NO;
        [_sectionCollectionView registerClass:[self.clsObj_itemView  class] forCellWithReuseIdentifier:[[self.clsObj_itemView  class] identifier]];
        _sectionCollectionView.backgroundColor = [UIColor clearColor];
        _sectionCollectionView.delegate = self;
        _sectionCollectionView.dataSource = self;
        [self.contentView addSubview:_sectionCollectionView];
        _sectionCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_sectionCollectionView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_sectionCollectionView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_sectionCollectionView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_sectionCollectionView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
    return _sectionCollectionView;
}

#pragma mark- UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectItemAction) {
        self.didSelectItemAction(indexPath.row);
    }
    void(^itemAction)() = self.sectionItem.items[indexPath.row].action;
    if(itemAction) {
        itemAction();
    }
}

#pragma mark- UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sectionItem.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ToolItemView *toolItemView = [collectionView dequeueReusableCellWithReuseIdentifier:[[self.clsObj_itemView  class] identifier] forIndexPath:indexPath];
    toolItemView.imageView.image = self.sectionItem.items[indexPath.row].image;
    toolItemView.textLabel.text = self.sectionItem.items[indexPath.row].title;
    return toolItemView;
}

#pragma mark - UICollectionViewDelegateFlowLayout method

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.itemSize;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{

    return UIEdgeInsetsMake(0, self.offset, 0, self.offset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark-
-(void)setSectionItem:(ToolSectionItem*)sectionItem didSelectItem:(void(^)(NSUInteger index)) action{
    self.sectionItem = sectionItem;
    self.didSelectItemAction = action;
    [self.sectionCollectionView reloadData];
}

@end
