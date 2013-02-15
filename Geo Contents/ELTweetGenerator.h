//
//  ELTweetGenerator.h
//  Geo Contents
//
//  Created by spider on 12.02.13.
//  Copyright (c) 2013 InterMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELFeature.h"

@interface ELTweetGenerator : NSObject

+(NSString*)createHTMLTWeet:(ELFeature*)feature;
+(NSString*)createHTMLUserString:(ELFeature*)feature;


@end
