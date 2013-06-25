//
//  ELUserFeaturesCVController.h
//  Geo Contents
//
//  Created by spider on 07.03.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Cell.h"
#import "ELRESTful.h"
#import "JMImageCache.h"
#import "ELConstants.h"
#import "NSDate+Helper.h"
#import "RCLabel.h"
#import "ELTweetGenerator.h"
#import "ELHashedFeatureCVController.h"
#import "ELUserFeaturesCVController.h"

/*
 *  User List View
 *
 *  Discussion:
 *      Display geo-features in chronological order added by  selected user in a list view which is vertically scrollable. It is based on the UICollectionView Controller.
 *  Main Functions:
 *      1 - display POIs in list view in chronological order added by the selected user
 *      2 - update the list view as the user pressed the refresh button
 *  Classes Used:
 *      Cell                : a custom cell view for each item in the list.
 *      ELFeature           : a model class to hold the feature object recived from Json response from server
 *      ELRESTful           : This handle all sort of client/server communication, also responsible for parsing json response to Feature Model
 *      JMImageCache        : NSCache based remote-image caching and downloading mechanism for iOS.
 *      ELConstants         : most of the application constants are defined inside this class
 *      NSDate+Helper       : extenion that allow to display time in intervals of hh:mm, week days, weeks, months, years.
 *      RCLabel             : a custome UILabel class with Useful callback function for link tapping event and image tapping event
 *      ELTweetGenerator    : convert tweet into clickable html formated text.
 *      ELHashedFeatureCVController :   the view controller that enlist all the feature avialbe by selected hashtag from any view controller
 *      ELUserFeaturesCVController.h :  the view controller that enlist all the feature avialbe by selected username from any view controller
 */
@interface ELUserFeaturesCVController : UICollectionViewController<UICollectionViewDelegate, UICollectionViewDataSource, RTLabelDelegate>

@property (strong, nonatomic) NSString *userName;



@end
