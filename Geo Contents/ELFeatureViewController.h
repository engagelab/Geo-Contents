//
//  ELTestActionSheetViewController.h
//  Geo Contents
//
//  Created by spider on 23.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELFeature.h"
#import "RCLabel.h"


@interface ELFeatureViewController : UIViewController<UIActionSheetDelegate, CLLocationManagerDelegate, RTLabelDelegate>
{
    
//    UIImageView *userprofileImageView;
//    UILabel *usernameLabel;
//    UILabel *creationTime;
//    UIImageView *standardResolutionImageview;
//    UILabel *descriptionLabel;

}

//@property (nonatomic, strong) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UIImageView *userprofileImageView;
@property (strong, nonatomic) IBOutlet RCLabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeDistance;
@property (strong, nonatomic) IBOutlet UIImageView *standardResolutionImageview;
@property (retain, nonatomic) IBOutlet RCLabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sourceTypeImageView;

@property (strong, nonatomic) IBOutlet UIScrollView *scroll;


-(IBAction)showActionSheet:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;

@property (strong, nonatomic) ELFeature *feature;


//@property (strong, nonatomic) CLLocation *nLocation;





@end
