//
//  ELRESTful.m
//  Geo Contents
//
//  Created by spider on 21.01.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import "ELRESTful.h"
#import "ELFeature.h"
#import "ELConstants.h"
#import "ELImages.h"
#import "ELContentViewController.h"

@implementation ELRESTful



+(NSMutableArray*) fetchFeaturesWithHashtag:(NSString*)hashTag
{
    NSString *path = @"/search/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];
    
    NSString *stringURL =  [NSString stringWithFormat:@"%@%@", requestUrl, hashTag];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    NSArray *featuresNode = [json objectForKey:@"features"];
    
    CLLocationManager *manager = [CLLocationManager new];
    CLLocation *userLoc = manager.location;
    
    
    NSArray *featureArrayWithoutDistance = [NSArray arrayWithArray:[ELRESTful jsonToFeatureArray:featuresNode]];
    NSMutableArray *featureArrayWithDistance  = [[NSMutableArray alloc]init];
    
    for (ELFeature *feature in featureArrayWithoutDistance)
    {
        CLLocation *featureLoc = feature.fLocation;
        NSNumber *distance = [ELContentViewController getDistanceBetweenPoint1:userLoc Point2:featureLoc];
        feature.distance = distance;
        [featureArrayWithDistance addObject:feature];
    }
    
       
    return featureArrayWithDistance;
}



+(NSMutableArray*) fetchRecentlyAddedFeatures:(CLLocationCoordinate2D)coordinate2D
{
    NSString *path = @"/geo/recent/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];
    NSString *lng = [NSString stringWithFormat:@"%f",coordinate2D.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate2D.latitude];

    
    NSString *stringURL =  [NSString stringWithFormat:@"%@%@%@%@", requestUrl, lng, @"/",lat];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    
    NSArray *features = [json objectForKey:@"features"];
    
    return [ELRESTful jsonToFeatureArray:features];
}


+(NSMutableArray*) fetchPOIsAtLocation:(CLLocationCoordinate2D)coordinate2D
{
    NSString *path = @"/geo/radius/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];
    NSString *lng = [NSString stringWithFormat:@"%f",coordinate2D.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate2D.latitude];
    NSString *distanceInMeters = [NSString stringWithFormat:@"%f",10.0f];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@%@%@%@%@%@", requestUrl, lng, @"/",lat,@"/",distanceInMeters];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    
    NSArray *features = [json objectForKey:@"features"];
    
    return [ELRESTful jsonToFeatureArray:features];
}



+(NSMutableArray*) fetchPOIsInBoundingBox:(NSDictionary*)bbox
{
    NSString *path = @"/geo/box/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];
    NSString *stringURL = [ELRESTful addQueryStringToUrlString:requestUrl withDictionary:bbox];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    
    NSArray *features = [json objectForKey:@"features"];
    
    return [ELRESTful jsonToFeatureArray:features];
}






+(NSMutableArray*) fetchPOIsByUserID:(NSString *)userID
{
    
    NSString *path = @"/user/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];

    
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", requestUrl, [userID substringFromIndex:1]];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    
    NSArray *features = [json objectForKey:@"features"];
    
    return [self jsonToFeatureArray:features];
}

+(NSMutableArray*) fetchPOIsByUserName:(NSString *)userName
{
    
    NSString *path = @"/user/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];
    
    
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", requestUrl, [userName substringFromIndex:1]];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    
    NSArray *features = [json objectForKey:@"features"];
    
    return [self jsonToFeatureArray:features];
}




+(ELFeature*) fetchPOIsByID:(NSString *)featureId withSource:(NSString *)source
{
    NSString *path;
    
    if ([source isEqualToString:@"mappa"]) {
        path = @"/geo/";
    }
    else if ([source isEqualToString:@"instagram"])
    {
        path = @"/instagram/";

    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", requestUrl, featureId];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    
    return [self featureForDic:json];
}




+ (NSMutableArray *)jsonToFeatureArray:(NSArray *)features
{
    NSMutableArray *nFeatures = [[NSMutableArray alloc]init];

    for (NSDictionary *feature in features)
    {
                [nFeatures addObject:[ELRESTful featureForDic:feature]];
    }
    
    return nFeatures;
    
}

+(ELFeature*)featureForDic:(NSDictionary*)featureDic
{
    ELFeature *feature = [[ELFeature alloc]init];
    feature.idd = [featureDic valueForKey:@"id"];

    
    NSDictionary *properties = [featureDic valueForKey:@"properties"];
    
    feature.source_type = [properties valueForKey:@"source_type"];
    
    feature.time = [properties valueForKey:@"created_time"];
    if ([[featureDic objectForKey:@"geometry"] objectForKey:@"coordinates"] != [NSNull null])
    {
        NSArray *location = [[featureDic objectForKey:@"geometry"] objectForKey:@"coordinates"];
        feature.fLocation = [[CLLocation alloc]initWithLatitude:[[location objectAtIndex:1] doubleValue] longitude:[[location objectAtIndex:0] doubleValue]];
    }
   
    NSDictionary *images = [properties valueForKey:@"images"];

    ELImages *imagesObject = [[ELImages alloc] init];
    
    imagesObject.thumbnail = [NSURL URLWithString:[images valueForKey:@"thumbnail"]];
    imagesObject.standard_resolution = [NSURL URLWithString:[images valueForKey:@"standard_resolution"]];
    if ([images valueForKey:@"high_resolution"] != [NSNull null])
    {
        imagesObject.high_resolution = [NSURL URLWithString:[images valueForKey:@"high_resolution"]];
    }

    feature.images = imagesObject;

    if ([properties valueForKey:@"description"] == [NSNull null])
    {
        feature.description = @"";
    }
    else
    {
        feature.description = [properties valueForKey:@"description"];

    }
    
    ELUser *user = [[ELUser alloc]init];
    NSDictionary *userD = [properties valueForKey:@"user"];
    user.idd = [userD valueForKey:@"id"];
    user.full_name = [userD valueForKey:@"full_name"];
    user.profile_picture = [userD valueForKey:@"profile_picture"];
    
    if (!([userD valueForKey:@"username"] == [NSNull null]))
    {
        user.username = [userD valueForKey:@"username"];
    }
    
    feature.user = user;
    
    // if source type is mapped then store addition meta info
    if ([feature.source_type isEqualToString:@"mapped_instagram"])
    {
        
        if ([properties valueForKey:@"mapper_description"] == [NSNull null])
        {
            feature.mapper_description = @"";
        }
        else
        {
            feature.mapper_description = [properties valueForKey:@"mapper_description"];            
        }
        
        ELUser *mapper = [[ELUser alloc]init];
        NSDictionary *mapperD = [properties valueForKey:@"mapper"];
        mapper.idd = [mapperD valueForKey:@"id"];
        mapper.full_name = [mapperD valueForKey:@"full_name"];
        mapper.profile_picture = [mapperD valueForKey:@"profile_picture"];
        feature.mapper = mapper;
    }
    
    return  feature;
}



+(NSDictionary *)getJSONResponsetWithURL:(NSString*)url
{
    
    //
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSDictionary *json = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return  json;
}






+ (void) deleteASyncRequestWithURL:(NSString *) url
{
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"DELETE"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,NSData *data,
                         NSError *error) {
         if ([data length] >0 &&
             error == nil){
             NSString *html = [[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding];
             NSLog(@"HTML = %@", html);
         }
         else if ([data length] == 0 &&
                  error == nil){
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             NSLog(@"Error happened = %@", error);
         }
     }];
}






+(NSString*)urlEscapeString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}


+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}


//parse parameters to NSDictionary
+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6] ;
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

@end
