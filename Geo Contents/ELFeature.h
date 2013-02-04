//
//  ELFeature.h
//  Geo Contents
//
//  Created by spider on 15.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELUser.h"
#import <CoreLocation/CoreLocation.h>

@interface ELFeature : NSObject

@property (nonatomic, strong) NSString *idd;
@property (nonatomic, strong) NSString *source_type;
@property (nonatomic, strong) NSURL *standard_resolution;
@property (nonatomic, strong) NSURL *thumbnail;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) ELUser *user;
@property (nonatomic, strong) CLLocation *fLocation;

@end
