//
//  ELNearbyViewController.h
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "IMPhotoAlbumLayout.h"
#import "IMAlbumPhotoCell.h"
#import "ELFeature.h"
#import "ELFeatureViewController.h"
#import "ELBridgingApp.h"
#import "ELConstants.h"
#import "ELRESTful.h"
#import "JMImageCache.h"
#import "CoreLocationUtils/CLLocation+measuring.h"


/*
 *  Mosaic View
 *
 *  Discussion:
 *      Display geo-features in a grid of 3XN called mosaic view which is vertically scrolable. It is based on the UICollectionView Controller.
 *  Main Functions:
 *      1 - display POIs thumbnails on mosaic within Rectangular geographical region termed as Bounding Box provided by the Map View.
 *      2 - display POIs thumbnails on mosaic accordingn to user location and update the view as the user move
 *  Classes Used:
 *      IMPhotoAlbumLayout  : define how the mosaic view should look.
 *      IMAlbumPhotoCell    : a custom cell view for each item in the mosaic.
 *      ELFeature           : a model class to hold the feature object recived from Json response from server
 *      ELFeatureViewController :   the view controller shows the details description and high resolution image of the selected POI
 *      ELBridgingApp       : this class take advantage of cocoa touch Custom URL Schema and transfer controll from one app to another app or within one app.
 *      ELConstants         : most of the application constants are defined inside this class
 *      ELRESTful           : This handle all sort of client/server communication, also responsible for parsing json response to Feature Model
 *      JMImageCache        : NSCache based remote-image caching and downloading mechanism for iOS.
 *      CoreLocationUtils/CLLocation+measuring : Adds capabilities to measure distance and direction from other locations, define bounding box, and more.
 */
@interface ELContentViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
}

//availble to start location service from other classes
-(void) startLocationServices;


@end
