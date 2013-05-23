//
//  ELUserFeaturesCVController.h
//  Geo Contents
//
//  Created by spider on 07.03.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCLabel.h"


@interface ELUserFeaturesCVController : UICollectionViewController<UICollectionViewDelegate, UICollectionViewDataSource, RTLabelDelegate>

@property (strong, nonatomic) NSString *userName;


@end
