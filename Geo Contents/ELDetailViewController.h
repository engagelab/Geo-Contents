//
//  ELDetailViewController.h
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELDetailViewController : UIViewController<UIScrollViewDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *creationTimeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *standardResulationImageView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;


@property (strong, nonatomic) NSURL *imageURL;

@end
