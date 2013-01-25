//
//  ELFeatureViewController.h
//  Geo Contents
//
//  Created by spider on 11.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELFeature.h"

@interface OldFeatureViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *creationTime;
@property (strong, nonatomic) IBOutlet UIImageView *standardResolutionImageview;
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextView;

-(IBAction)showActionSheet:(id)sender;

@property (strong, nonatomic) ELFeature *feature;
@end
