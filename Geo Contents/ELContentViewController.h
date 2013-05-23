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
    BOOL gpsButtonCurrentStatus;
    NSTimer *autoTimer;
    UIButton *gpsButton;
}

+(NSNumber*)getDistanceBetweenPoint1:(CLLocation *)point1 Point2:(CLLocation *)point2;

@property (readonly) UIButton *gpsButton;

@end
