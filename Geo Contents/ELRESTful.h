//
//  ELRESTful.h
//  Geo Contents
//
//  Created by spider on 21.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ELFeature.h"



@interface ELRESTful : NSObject

+(NSMutableArray*)  fetchRecentlyAddedFeatures:(CLLocationCoordinate2D)coordinate2D;
+(NSMutableArray*)  fetchPOIsAtLocation:(CLLocationCoordinate2D)coordinate2D;
+(NSMutableArray*)  fetchPOIsInBoundingBox:(NSDictionary*)bbox;
+(ELFeature*)       featureForDic:(NSDictionary*)featureDic;
+(NSDictionary *)   getJSONResponsetWithURL:(NSURL*)requestURL;
+(NSMutableArray*)  fetchPOIsByUserID:(NSString *)userID;
+(ELFeature*)       fetchPOIsByID:(NSString *)featureId withSource:(NSString*)source;
+(NSMutableArray*)  fetchFeaturesWithHashtag:(NSString*)hashTag;
+ (NSDictionary *)  parseQueryString:(NSString *)query ;
+(NSMutableArray*)  fetchPOIsByUserName:(NSString *)userName;





@property (nonatomic, strong) NSMutableDictionary *requestCode;

@end
