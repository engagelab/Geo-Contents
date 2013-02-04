//
//  ELFeatureCListViewController.h
//  Geo Contents
//
//  Created by spider on 21.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ELNearbyListViewController : UICollectionViewController<UICollectionViewDelegate, UICollectionViewDataSource,CLLocationManagerDelegate>
{
      BOOL haveLocation;
    NSMutableArray *images;
}



@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *nLocation;

@end
