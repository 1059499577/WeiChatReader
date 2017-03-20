//
//  XMLayout.m
//  仿微信阅读
//
//  Created by RenXiangDong on 17/1/10.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "XMLayout.h"

@implementation XMLayout
{
    CGRect _myRect;
    
}
- (void)prepareLayout {
    [super prepareLayout];
    CGFloat insetX = (kScreenWidth - self.itemSize.width) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, insetX, 0, insetX);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
     CGFloat cllCent=self.collectionView.contentOffset.x+self.collectionView.frame.size.width*0.5;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        CGFloat scal=1;
        CGFloat temp;
        CGFloat distance=attrs.center.x-cllCent;
        temp=distance;
        if (distance<0) {
            distance=-distance;
        }
        scal= 1-distance/5000.0;
        attrs.transform=CGAffineTransformMakeScale(scal, scal);
    }
    return array;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    _myRect=CGRectMake(proposedContentOffset.x, 0, kScreenWidth, kScreenWidth);
    NSArray *array=[super layoutAttributesForElementsInRect:_myRect];
    CGFloat cllCent=proposedContentOffset.x+self.collectionView.frame.size.width*0.5;
    UICollectionViewLayoutAttributes *target=[array firstObject];
    CGFloat smallest=MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        CGFloat distance=attrs.center.x-cllCent;
        if (ABS(distance)<ABS(smallest)) {
            smallest=distance;
            target=attrs;
        }
    }
    proposedContentOffset.x+=smallest;
    return  proposedContentOffset;
}

@end
