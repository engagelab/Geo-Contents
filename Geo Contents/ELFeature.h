//
//  ELFeature.h
//  Geo Contents
//
//  Created by spider on 15.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ELUser.h"
#import "ELImages.h"

@interface ELFeature : NSObject

@property (nonatomic, strong) NSString *idd;
@property (nonatomic, strong) NSString *source_type;
@property (nonatomic, strong) NSNumber *time;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *mapper_description;
@property (nonatomic, strong) CLLocation *fLocation;
@property (nonatomic, strong) ELUser *user;
@property (nonatomic, strong) ELUser *mapper;
@property (nonatomic, strong) ELImages *images;



@end
