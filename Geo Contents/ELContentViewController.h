//
//  ELNearbyViewController.h
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ELContentViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    UIButton *gpsButton;
    BOOL gpsButtonCurrentStatus;
    NSTimer *autoTimer;
}



@end
