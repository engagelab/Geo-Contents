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

@implementation ELRESTful




+(NSMutableArray*) fetchPOIsAtLocation:(CLLocationCoordinate2D)coordinate2D
{
    NSString *path = @"/geo/radius/";
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,path];
    NSString *lng = [NSString stringWithFormat:@"%f",coordinate2D.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate2D.latitude];
    NSString *distanceInMeters = [NSString stringWithFormat:@"%f",100.0f];
    
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

    
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", requestUrl, userID];
    
    NSDictionary *json = [ELRESTful getJSONResponsetWithURL:stringURL];
    
    NSArray *features = [json objectForKey:@"features"];
    
    return [self jsonToFeatureArray:features];
}


+(ELFeature*) fetchPOIsByID:(NSString *)featureId :(NSString*)source
{
    NSString *path;
    
    if ([source isEqualToString:@"overlay"]) {
        path = @"/overlay/";
    }
    else if ([source isEqualToString:@"Instagram"])
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
    NSDictionary *properties = [featureDic valueForKey:@"properties"];
    //search for thumbnail
    NSString *thumbnail =[properties valueForKey:@"thumbnail"];
    feature.thumbnail = [NSURL URLWithString:thumbnail];
    NSString *standardResolution =[properties valueForKey:@"standard_resolution"];
    feature.standard_resolution = [NSURL URLWithString:standardResolution];

    feature.idd = [featureDic valueForKey:@"id"];
    feature.timeDistance = [properties valueForKey:@"created_time"];
    feature.description = [properties valueForKey:@"description"];
    feature.source_type = [properties valueForKey:@"source_type"];
    ELUser *user = [[ELUser alloc]init];
    NSDictionary *userD = [properties valueForKey:@"user"];
    user.idd = [userD valueForKey:@"id"];
    user.full_name = [userD valueForKey:@"full_name"];
    user.profile_picture = [userD valueForKey:@"profile_picture"];
    feature.user = user;
    
    NSArray *location = [[featureDic objectForKey:@"geometry"] objectForKey:@"coordinates"];

   feature.fLocation = [[CLLocation alloc]initWithLatitude:[[location objectAtIndex:1] doubleValue] longitude:[[location objectAtIndex:0] doubleValue]];
    
    return  feature;
}



+(NSDictionary *)getJSONResponsetWithURL:(NSString*)url
{
    
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

@end
