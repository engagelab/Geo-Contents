//
//  ELFeatureCListViewController.h
//  Geo Contents
//
//  Created by spider on 21.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Cell.h"
#import "ELRESTful.h"
#import "ELFeature.h"
#import "JMImageCache.h"
#import "ELConstants.h"
#import "NSString+Distance.h"
#import "RCLabel.h"
#import "ELTweetGenerator.h"
#import "ELHashedFeatureCVController.h"
#import "ELUserFeaturesCVController.h"




/*
 *  Nearby List View
 *
 *  Discussion:
 *      Display geo-features  nearby to user current location in a list view which is vertically scrollable. It is based on the UICollectionView Controller.
 *  Main Functions:
 *      1 - display POIs in list view near to user location
 *      2 - update the list view as the user pressed the refresh button
 *  Classes Used:
 *      Cell                : a custom cell view for each item in the list.
 *      ELFeature           : a model class to hold the feature object recived from Json response from server
 *      ELRESTful           : This handle all sort of client/server communication, also responsible for parsing json response to Feature Model
 *      JMImageCache        : NSCache based remote-image caching and downloading mechanism for iOS.
 *      ELConstants         : most of the application constants are defined inside this class
 *      NSString+Distance   : extenion that allow to display distance in intervals of m and km.
 *      RCLabel             : a custome UILabel class with Useful callback function for link tapping event and image tapping event
 *      ELTweetGenerator    : convert tweet into clickable html formated text.
 *      ELHashedFeatureCVController :   the view controller that enlist all the feature avialbe by selected hashtag from any view controller
 *      ELUserFeaturesCVController.h :  the view controller that enlist all the feature avialbe by selected username from any view controller
 */
@interface ELNearbyListViewController : UICollectionViewController<UICollectionViewDelegate, UICollectionViewDataSource, RTLabelDelegate>

@end
