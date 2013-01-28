//
//  ELRESTful.h
//  Geo Contents
//
//  Created by spider on 21.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



@interface ELRESTful : NSObject

+(NSMutableArray*) fetchPOIsAtLocation:(CLLocationCoordinate2D)coordinate2D;
+(NSMutableArray*) fetchPOIsInBoundingBox:(NSDictionary*)bbox;



@end