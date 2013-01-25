//
//  ENCListLayout.h
//  MyCollectionView
//
//  Created by spider on 12.12.12.
//  Copyright (c) 2012 spider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENCListLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;


@end
