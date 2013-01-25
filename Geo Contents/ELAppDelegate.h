//
//  ELAppDelegate.h
//  Geo Contents
//
//  Created by spider on 09.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>



@interface ELAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *contentNavController;
@property (strong, nonatomic) UINavigationController *searchNavController;
@property (strong, nonatomic) UINavigationController *nearbyNavController;
@property (strong, nonatomic) UINavigationController *recentNavController;

@property (strong, nonatomic) UITabBarController *tabBarController;


@property (strong,nonatomic) NSArray *features;
@property (strong,nonatomic) NSDictionary *overlayBoundingBox;


@end
